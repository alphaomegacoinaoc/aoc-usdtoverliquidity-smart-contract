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

    uint256 public bonusInAOC;

    mapping(address => UserInfo) public userInfo;

    mapping(address => mapping(address => bool))
        public isAOCReferralBonusEarned;

    IERC20Upgradeable private usdtToken;

    Phase[] public phases;

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
        uint256 contributedAmountInUSDT;
        bool isPhaseFinalized;
    }

    event Contribution(
        address indexed contributor,
        uint256 amount,
        uint256 tokens
    );
    event UpdatePhaseWhilePhaseLive(uint256 rate, uint256 usdtBonusPercentage);
    event UpdatePhaseWhileRestart(
        uint256 phaseIndex,
        uint256 rate,
        uint256 usdtBonusPercentage,
        uint256 duration,
        uint256 phaseStartTime
    );
    event WithdrawUSDTReferalBonus(address indexed contributor, uint256 amount);
    event UpdateBonusInAOC(uint256 aocInTokens);
    event WithdrawToken(address token, address to, uint256 amount); // Event for Withdraw token from contract
    event WithdrawNative(uint256 native);
    event FinalizeCurrentPhase(bool isCurrentPhaseFinalized);

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
    /// @param usdt The address of the USDT token contract
    function initialize(address usdt) external initializer {
        usdtToken = IERC20Upgradeable(usdt);
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
    /// @dev Can add phases one by one when previous phase is finalized
    /// @param rate Array of rates at which tokens are distributed per USDT
    /// @param userBonus Array of bonus amounts in USDT for referring others
    /// @param duration Array of phase durations in seconds
    /// @param phaseStartTime Start time of the first phase
    function setPhaseData(
        uint256 rate,
        uint256 userBonus,
        uint256 duration,
        uint256 phaseStartTime
    ) external onlyOwner nonReentrant {
        if (phases.length > 0) {
            uint256 currentPhaseIndex = getCurrentPhase();
            require(
                phases[currentPhaseIndex].isPhaseFinalized,
                "Previous phase not finalized"
            );
        }
        phases.push(
            Phase({
                rate: rate,
                bonusInUSDT: userBonus,
                duration: duration,
                phaseStartTime: phaseStartTime,
                phaseEndTime: phaseStartTime + duration,
                contributedAmountInUSDT: 0,
                isPhaseFinalized: false
            })
        );
    }

    /// @notice Determines the current active phase based on phase index
    function getCurrentPhase() public view returns (uint256) {
        for (uint256 i = 0; i < phases.length; i++) {
            if (!phases[i].isPhaseFinalized) {
                return i;
            }
        }
        if (phases.length > 0) {
            return phases.length - 1; // If no phase is active, return the last phase index
        }
        return phases.length;
    }

    /// @dev Finalizes the current phase of the contract.
    /// Sets the `isPhaseFinalized` flag of the current phase to true to indicate
    /// that this phase can no longer be modified or reverted.
    /// Emits a `FinalizeCurrentPhase` event with a status of true upon successful finalization.
    ///
    /// Requirements:
    /// - The function must be called by the contract owner.
    /// - The function cannot be reentered during its execution.
    function finalizeCurrentPhase() external onlyOwner nonReentrant {
        uint256 currentPhaseIndex = getCurrentPhase();
        phases[currentPhaseIndex].isPhaseFinalized = true;
        emit FinalizeCurrentPhase(true);
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
        uint256 currentPhaseIndex = getCurrentPhase();

        uint256 rate = (phases[currentPhaseIndex].rate * 10 ** 18) / 10000;

        uint256 tokens = ((usdtAmount * 10 ** 18) * rate);

        uint256 userBalance = tokens / 10 ** 18;

        userInfo[msg.sender].balanceInAOC += userBalance;
        userInfo[msg.sender].contribution += usdtAmount * 10 ** 18;
        totalRaised += usdtAmount;
        phases[currentPhaseIndex].contributedAmountInUSDT += usdtAmount;
        if (referrer != address(0)) {
            // calculation for referral usdt bonus (ie) calculated from contribution amount
            uint256 bonusInUSDT = ((usdtAmount * 10 ** 18) *
                phases[currentPhaseIndex].bonusInUSDT) / 100;

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
    /// @param newUsdtToken The new USDT token contract address
    function setUsdtToken(
        address newUsdtToken
    ) external onlyOwner nonReentrant {
        require(newUsdtToken != address(0), "Invalid USDT token address");
        usdtToken = IERC20Upgradeable(newUsdtToken);
    }

    /// @notice Retrieves information about all phases in the crowdsale
    /// @dev This function returns an array containing details of all phases, including their rates, bonuses, durations, start and end times, contribution limits, and total contributed amount in USDT
    /// @return An array of Phase structs containing information about each phase
    function getAllPhases() external view returns (Phase[] memory) {
        return (phases);
    }

    /// @notice Updates the configuration of phase in the crowdsale when sale ends while restart phase
    /// @dev This function updates the rate, USDT bonus for phase
    /// @dev Can only be called by the owner of the contract
    /// @param phaseIndex index of the re-initiating phase
    /// @param rate rate to be set for phase - 1USDT = ? AOC
    /// @param usdtBonusPercentage new USDT bonus to be set for phase
    /// @param duration phase durations in seconds
    /// @param phaseStartTime Start time of the phase
    function updatePhaseWhileRestart(
        uint256 phaseIndex,
        uint256 rate,
        uint256 usdtBonusPercentage,
        uint256 duration,
        uint256 phaseStartTime
    ) external onlyOwner nonReentrant {
        uint256 currentPhaseIndex = getCurrentPhase();
        require(
            phases[currentPhaseIndex].isPhaseFinalized,
            "Previous phase not finalized"
        );
        phases[phaseIndex].rate = rate;
        phases[phaseIndex].bonusInUSDT = usdtBonusPercentage;
        phases[phaseIndex].duration = duration;
        phases[phaseIndex].phaseStartTime = phaseStartTime;
        phases[phaseIndex].phaseEndTime = phaseStartTime + duration;
        phases[phaseIndex].isPhaseFinalized = false;

        emit UpdatePhaseWhileRestart(
            phaseIndex,
            rate,
            usdtBonusPercentage,
            duration,
            phaseStartTime
        );
    }

    /// @notice Updates the configuration of phase in the crowdsale while phase live
    /// @dev This function updates the rate, USDT bonus for phase
    /// @dev Can only be called by the owner of the contract
    /// @param rate rate to be set for phase - 1USDT = ? AOC
    /// @param usdtBonusPercentage new USDT bonus to be set for phase
    function updatePhaseWhilePhaseLive(
        uint256 rate,
        uint256 usdtBonusPercentage
    ) external onlyOwner nonReentrant {
        uint256 currentPhaseIndex = getCurrentPhase();

        phases[currentPhaseIndex].rate = rate;
        phases[currentPhaseIndex].bonusInUSDT = usdtBonusPercentage;
        emit UpdatePhaseWhilePhaseLive(rate, usdtBonusPercentage);
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
    /// @param aocInTokens The new bonus amount in AOC tokens
    function updateBonusInAOC(
        uint256 aocInTokens
    ) external onlyOwner nonReentrant {
        bonusInAOC = aocInTokens; // 1000 = 0.1 referral AOC bonus
        emit UpdateBonusInAOC(aocInTokens);
    }

    /// @notice Allows the owner to withdraw tokens from a specified token contract.
    /// @dev Can only be called by the owner.
    /// @param tokenAddress The address of the token contract.
    /// @param amount The amount of tokens to withdraw.
    /// Requirements:
    /// - `tokenAddress` cannot be the zero address.
    /// - The contract must have sufficient balance to transfer.
    /// Emits a {WithdrawToken} event.
    function withdrawToken(
        address tokenAddress,
        uint256 amount
    ) external onlyOwner nonReentrant {
        require(tokenAddress != address(0), "Address cant be zero address");
        IERC20Upgradeable tokenContract = IERC20Upgradeable(tokenAddress);
        bool success = tokenContract.transfer(msg.sender, amount);
        require(success, "Transfer failed");
        emit WithdrawToken(tokenAddress, msg.sender, amount);
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
        emit WithdrawNative(nativeBalance);
        require(payable(msg.sender).send(nativeBalance), "Transfer failed");
    }
}
