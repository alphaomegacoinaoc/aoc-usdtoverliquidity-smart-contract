// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

/// @author BLOCKCHAINX
/// @title A Crowdsale contract for distributing tokens in exchange for contributions
/// @notice This contract allows users to contribute USDT and receive AOC tokens during defined phases
/// @dev Extends functionality from OpenZeppelin's upgradeable contracts
contract USDTOverLiquidityContribution is
    Initializable,
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable,
    UUPSUpgradeable
{
    using SafeERC20Upgradeable for IERC20Upgradeable;

    uint256 public totalRaised;

    bool public isPhaseInitiated;

    uint256 public bonusInAOC;

    mapping(address => UserInfo) public userInfo;

    mapping(address => mapping(address => bool))
        public isAOCReferralBonusEarned;

    IERC20Upgradeable private usdtToken;

    Phase[] public phases;

    uint256 private currentPhase;

    struct UserInfo {
        uint256 contribution;
        uint256 balanceInAOC;
        uint256 bonusInUSDT;
        address referrer;
        uint256 bonusInAOC;
    }

    struct Phase {
        uint256 rate;
        uint256 bonusInUSDT;
        uint256 duration;
        uint256 phaseStartTime;
        uint256 phaseEndTime;
        uint256 maxContributionLimit;
        uint256 contributedAmountInUSDT;
    }

    event Contribution(
        address indexed contributor,
        uint256 amount,
        uint256 tokens
    );
    event UpdatePhase(
        uint256 phase,
        uint256 rate,
        uint256 maxContributionLimit
    );
    event WithdrawUSDTReferalBonus(address indexed contributor, uint256 amount);
    event UpdateBonusInAOC(uint256 aocInTokens);
    event WithdrawToken(address token, address to, uint256 amount); // Event for Withdraw token from contract
    event WithdrawNative(uint256 native);

    /// @notice Modifier to restrict operations to the active phase duration
    modifier duringContribution() {
        uint256 currentPhaseIndex = getCurrentPhase();
        require(
            block.timestamp >= phases[currentPhaseIndex].phaseStartTime &&
                block.timestamp <= phases[currentPhaseIndex].phaseEndTime,
            "Precontribution phase is not active"
        );
        _;
    }

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() initializer {}

    /// @notice Initializes the contract setting up the admin and USDT token
    /// @dev Sets the initial admin and links to the USDT token contract
    /// @param _usdt The address of the USDT token contract
    function initialize(address _usdt) external initializer {
        usdtToken = IERC20Upgradeable(_usdt);
        currentPhase = 0;
        bonusInAOC = 1000; // 1000 = 0.1 referral AOC bonus - AOC reward is only once.
        __Ownable_init_unchained();
        __ReentrancyGuard_init_unchained();
    }

    /// @notice Internal function to authorize upgrades to the contract
    /// @dev Overrides the UUPSUpgradeable version to add onlyOwner modifier
    function _authorizeUpgrade(address) internal override onlyOwner {}

    /// @notice Disables the renounceOwnership function to prevent ownership renunciation
    function renounceOwnership() public view override onlyOwner {
        revert("Renounce ownership is disabled");
    }

    /// @notice Sets the data for each phase of the crowdsale
    /// @dev Can only be called once before any phase is initiated
    /// @param rates Array of rates at which tokens are distributed per USDT
    /// @param userBonuses Array of bonus amounts in USDT for referring others
    /// @param durations Array of phase durations in seconds
    /// @param phaseStartTime Start time of the first phase
    /// @param _maxContributionLimit Array of maximum USDT contribution limits per phase
    function setPhaseData(
        uint256[] memory rates,
        uint256[] memory userBonuses,
        uint256[] memory durations,
        uint256 phaseStartTime,
        uint256[] memory _maxContributionLimit
    ) external onlyOwner nonReentrant {
        require(
            rates.length == userBonuses.length &&
                rates.length == durations.length,
            "Invalid input lengths"
        );
        require(!isPhaseInitiated, "Values are already defined");

        uint256 startTime = phaseStartTime;
        for (uint256 i = 0; i < rates.length; i++) {
            phases.push(
                Phase({
                    rate: rates[i],
                    bonusInUSDT: userBonuses[i],
                    duration: durations[i],
                    phaseStartTime: startTime,
                    phaseEndTime: startTime + durations[i],
                    maxContributionLimit: _maxContributionLimit[i],
                    contributedAmountInUSDT: 0
                })
            );
            startTime += durations[i]; // 1000 = 0.1 referral AOC bonus - AOC reward is only once.
        }
        isPhaseInitiated = true;
    }

    /// @notice Determines the current active phase based on the current time
    /// @return The index of the current phase or the index of the last phase if no active phase exists
    function getCurrentPhase() public view returns (uint256) {
        for (uint256 i = 0; i < phases.length; i++) {
            if (block.timestamp <= phases[i].phaseEndTime) {
                return i;
            }
        }
        return phases.length; // If no phase is active, return the last phase
    }

    /// @notice Allows users to contribute USDT in exchange for AOC tokens
    /// @param usdtAmount The amount of USDT to contribute
    /// @param referrer The address of the user who referred the contributor, if any
    function contribute(
        uint256 usdtAmount,
        address referrer
    ) external duringContribution nonReentrant {
        require(usdtAmount > 0, "Contribution amount must be greater than 0");
        if (userInfo[msg.sender].referrer != address(0)) {
            require(
                userInfo[msg.sender].referrer == referrer,
                "Referrer does not match expected value."
            );
        }
        require(
            phases[currentPhase].maxContributionLimit >=
                phases[currentPhase].contributedAmountInUSDT,
            "Contribution exceeds phase maximum limit."
        );
        while (
            block.timestamp > phases[currentPhase].phaseEndTime &&
            currentPhase < phases.length - 1
        ) {
            currentPhase++;
        }

        uint256 rate = (phases[currentPhase].rate * 10 ** 18) / 10000;

        uint256 tokens = ((usdtAmount * 10 ** 18) * rate);

        uint256 userBalance = tokens / 10 ** 18;

        userInfo[msg.sender].balanceInAOC += userBalance;
        userInfo[msg.sender].contribution += usdtAmount * 10 ** 18;
        totalRaised += usdtAmount;
        phases[currentPhase].contributedAmountInUSDT += usdtAmount;
        if (referrer != address(0)) {
            // calculation for referral usdt bonus (ie) calculated from contribution amount
            uint256 bonusInUSDT = ((usdtAmount * 10 ** 18) *
                phases[currentPhase].bonusInUSDT) / 100;

            userInfo[referrer].bonusInUSDT += bonusInUSDT;
            userInfo[msg.sender].referrer = referrer;

            if (!isAOCReferralBonusEarned[msg.sender][referrer]) {
                isAOCReferralBonusEarned[msg.sender][referrer] = true;
                userInfo[referrer].bonusInAOC += bonusInAOC;
            }
        }

        usdtToken.safeTransferFrom(
            msg.sender,
            address(this),
            usdtAmount * 10 ** 18
        );

        emit Contribution(msg.sender, usdtAmount, userBalance);
    }

    /// @notice Withdraws all USDT contributed to the contract
    function withdrawContibutedUSDT() external onlyOwner nonReentrant {
        usdtToken.safeTransfer(owner(), usdtToken.balanceOf(address(this)));
    }

    /// @notice Sets a new USDT token contract address
    /// @param _newUsdtToken The new USDT token contract address
    function setUsdtToken(
        address _newUsdtToken
    ) external onlyOwner nonReentrant {
        require(_newUsdtToken != address(0), "Invalid USDT token address");
        usdtToken = IERC20Upgradeable(_newUsdtToken);
    }

    /// @notice Retrieves information about all phases in the crowdsale
    /// @dev This function returns an array containing details of all phases, including their rates, bonuses, durations, start and end times, contribution limits, and total contributed amount in USDT
    /// @return An array of Phase structs containing information about each phase
    function getAllPhases() external view returns (Phase[] memory) {
        return (phases);
    }

    /// @notice Updates the configuration of each phase in the crowdsale
    /// @dev This function updates the rate, USDT bonus, and maximum contribution limit for each phase
    /// @dev Can only be called by the owner of the contract
    /// @param rates An array of new rates to be set for each phase
    /// @param userBonuses An array of new USDT bonuses to be set for each phase
    /// @param _maxContributionLimit An array of new maximum contribution limits to be set for each phase
    function updatePhase(
        uint256[] memory rates,
        uint256[] memory userBonuses,
        uint256[] memory _maxContributionLimit
    ) external onlyOwner nonReentrant {
        uint256 preSalePhaseLength = phases.length; // here need to remove current active phase
        require(
            rates.length == preSalePhaseLength &&
                userBonuses.length == preSalePhaseLength,
            "Invalid input lengths"
        );
        for (uint i = 0; i < preSalePhaseLength; i++) {
            phases[i].rate = rates[i];
            phases[i].bonusInUSDT = userBonuses[i];
            phases[i].maxContributionLimit = _maxContributionLimit[i];
            emit UpdatePhase(
                rates[i],
                userBonuses[i],
                _maxContributionLimit[i]
            );
        }
    }

    /// @notice Withdraws the USDT referral bonus for the calling user
    /// @dev Transfers the accumulated referral bonus in USDT to the caller and sets their bonus balance to zero
    /// @dev Requires the caller to have a non-zero USDT referral bonus and sufficient USDT in the contract
    function withdrawUSDTReferralBonus() external nonReentrant {
        uint256 bonusAmount = userInfo[msg.sender].bonusInUSDT;
        require(bonusAmount > 0, "No USDT referral bonus");

        uint256 contractBalance = usdtToken.balanceOf(address(this));
        require(
            contractBalance >= bonusAmount,
            "Insufficient USDT balance in contract"
        );
        userInfo[msg.sender].bonusInUSDT = 0;
        bool success = usdtToken.transfer(msg.sender, bonusAmount);
        require(success, "Transfer failed");
        emit WithdrawUSDTReferalBonus(msg.sender, bonusAmount);
    }

    /// @notice Updates the referral bonus in AOC
    /// @dev Can only be called by the owner
    /// @param _aocInTokens The new bonus amount in AOC tokens
    function updateBonusInAOC(
        uint256 _aocInTokens
    ) external onlyOwner nonReentrant {
        bonusInAOC = _aocInTokens; // 1000 = 0.1 referral AOC bonus
        emit UpdateBonusInAOC(_aocInTokens);
    }

    /// @notice Allows the owner to withdraw tokens from a specified token contract.
    /// @dev Can only be called by the owner.
    /// @param _tokenContract The address of the token contract.
    /// @param _amount The amount of tokens to withdraw.
    /// Requirements:
    /// - `_tokenContract` cannot be the zero address.
    /// - The contract must have sufficient balance to transfer.
    /// Emits a {WithdrawToken} event.
    function withdrawToken(
        address _tokenContract,
        uint256 _amount
    ) external onlyOwner nonReentrant {
        require(_tokenContract != address(0), "Address cant be zero address");
        IERC20Upgradeable tokenContract = IERC20Upgradeable(_tokenContract);
        tokenContract.transfer(msg.sender, _amount);
        emit WithdrawToken(_tokenContract, msg.sender, _amount);
    }

    /// @dev Fallback function to accept native currency (Ether).
    /// This function allows the contract to receive native currency (Ether) sent to it.
    /// It's typically used for depositing Ether into the contract.
    /// Effects:
    /// - Receives native currency (Ether) and stores it in the contract balance.
    /// - No explicit actions are performed in this function.
    receive() external payable {}

    ///@dev Allows the owner to withdraw native cryptocurrency (e.g., ETH) from this contract.
    function withdrawNative() external onlyOwner nonReentrant {
        uint256 nativeBalance = address(this).balance;
        payable(msg.sender).transfer(nativeBalance);
        emit WithdrawNative(nativeBalance);
    }
}
