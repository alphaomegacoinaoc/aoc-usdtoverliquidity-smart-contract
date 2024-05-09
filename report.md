 Sūrya's Description Report

 Files Description Table


|  File Name  |  SHA-1 Hash  |
|-------------|--------------|
| /home/ruban/Desktop/Solidity-Projects/aoc_contract/contracts/USDTOverLiquidityContribution.sol | df04d1d6a4a4c28da15962897e94cd12b9f694b7 |
| /home/ruban/Desktop/Solidity-Projects/aoc_contract/node_modules/@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol | 39e51a0869ec29a2fa5cce95a04bcf3505dad498 |
| /home/ruban/Desktop/Solidity-Projects/aoc_contract/node_modules/@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol | 05598e8316056416fa82c26675d7df1f82422c56 |
| /home/ruban/Desktop/Solidity-Projects/aoc_contract/node_modules/@openzeppelin/contracts-upgradeable/token/ERC20/extensions/IERC20PermitUpgradeable.sol | 502675128b62ac543ca454d1800d293f919ad0aa |
| /home/ruban/Desktop/Solidity-Projects/aoc_contract/node_modules/@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol | ab01b1cde3da2f29e3dede5163ba19e476a13421 |
| /home/ruban/Desktop/Solidity-Projects/aoc_contract/node_modules/@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol | 2f68fc2e112235e2865dfd8e78ccb9b75fe683a7 |
| /home/ruban/Desktop/Solidity-Projects/aoc_contract/node_modules/@openzeppelin/contracts-upgradeable/utils/ContextUpgradeable.sol | 1430f94663aec1e55a42fe010c637e3e64ec9e3d |
| /home/ruban/Desktop/Solidity-Projects/aoc_contract/node_modules/@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol | fcc91dc439c6031f362774afed10b63a9a374548 |
| /home/ruban/Desktop/Solidity-Projects/aoc_contract/node_modules/@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol | 77cc24bd115230ffb3697955520cd46f08977350 |
| /home/ruban/Desktop/Solidity-Projects/aoc_contract/node_modules/@openzeppelin/contracts-upgradeable/interfaces/draft-IERC1822Upgradeable.sol | ebb0db653db26cc17742bc8047df2415b15209c6 |
| /home/ruban/Desktop/Solidity-Projects/aoc_contract/node_modules/@openzeppelin/contracts-upgradeable/proxy/ERC1967/ERC1967UpgradeUpgradeable.sol | 1fe0b163713143586d3b45b7ff9a772faaa12956 |
| /home/ruban/Desktop/Solidity-Projects/aoc_contract/node_modules/@openzeppelin/contracts-upgradeable/proxy/beacon/IBeaconUpgradeable.sol | c445b47a51bae223cbf7b47829e4d93f77a3e815 |
| /home/ruban/Desktop/Solidity-Projects/aoc_contract/node_modules/@openzeppelin/contracts-upgradeable/interfaces/IERC1967Upgradeable.sol | fec7cdfb50a6c0dfd1a9121a458db1a5d4c09dfa |
| /home/ruban/Desktop/Solidity-Projects/aoc_contract/node_modules/@openzeppelin/contracts-upgradeable/utils/StorageSlotUpgradeable.sol | 11708097980c24cc4fc48c7a76657a04f7bd3228 |
| /home/ruban/Desktop/Solidity-Projects/aoc_contract/node_modules/@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol | de6b6be4a8d19fafcda4c0b68f40b333e64beff7 |


 Contracts Description Table


|  Contract  |         Type        |       Bases      |                  |                 |
|:----------:|:-------------------:|:----------------:|:----------------:|:---------------:|
|     └      |  **Function Name**  |  **Visibility**  |  **Mutability**  |  **Modifiers**  |
||||||
| **USDTOverLiquidityContribution** | Implementation | Initializable, OwnableUpgradeable, ReentrancyGuardUpgradeable, UUPSUpgradeable |||
| └ | <Constructor> | Public ❗️ | 🛑  | initializer |
| └ | initialize | External ❗️ | 🛑  | initializer |
| └ | _authorizeUpgrade | Internal 🔒 | 🛑  | onlyOwner |
| └ | renounceOwnership | Public ❗️ |   | onlyOwner |
| └ | setPhaseData | External ❗️ | 🛑  | onlyOwner nonReentrant |
| └ | getCurrentPhase | Public ❗️ |   |NO❗️ |
| └ | finalizeCurrentPhase | External ❗️ | 🛑  | onlyOwner nonReentrant |
| └ | contribute | External ❗️ | 🛑  | duringContribution nonReentrant |
| └ | withdrawContibutedUSDT | External ❗️ | 🛑  | onlyOwner nonReentrant |
| └ | setUsdtToken | External ❗️ | 🛑  | onlyOwner nonReentrant |
| └ | getAllPhases | External ❗️ |   |NO❗️ |
| └ | updatePhase | External ❗️ | 🛑  | onlyOwner nonReentrant |
| └ | withdrawUSDTReferralBonus | External ❗️ | 🛑  | nonReentrant |
| └ | updateBonusInAOC | External ❗️ | 🛑  | onlyOwner nonReentrant |
| └ | withdrawToken | External ❗️ | 🛑  | onlyOwner nonReentrant |
| └ | <Receive Ether> | External ❗️ |  💵 |NO❗️ |
| └ | withdrawNative | External ❗️ | 🛑  | onlyOwner nonReentrant |
||||||
| **SafeERC20Upgradeable** | Library |  |||
| └ | safeTransfer | Internal 🔒 | 🛑  | |
| └ | safeTransferFrom | Internal 🔒 | 🛑  | |
| └ | safeApprove | Internal 🔒 | 🛑  | |
| └ | safeIncreaseAllowance | Internal 🔒 | 🛑  | |
| └ | safeDecreaseAllowance | Internal 🔒 | 🛑  | |
| └ | forceApprove | Internal 🔒 | 🛑  | |
| └ | safePermit | Internal 🔒 | 🛑  | |
| └ | _callOptionalReturn | Private 🔐 | 🛑  | |
| └ | _callOptionalReturnBool | Private 🔐 | 🛑  | |
||||||
| **IERC20Upgradeable** | Interface |  |||
| └ | totalSupply | External ❗️ |   |NO❗️ |
| └ | balanceOf | External ❗️ |   |NO❗️ |
| └ | transfer | External ❗️ | 🛑  |NO❗️ |
| └ | allowance | External ❗️ |   |NO❗️ |
| └ | approve | External ❗️ | 🛑  |NO❗️ |
| └ | transferFrom | External ❗️ | 🛑  |NO❗️ |
||||||
| **IERC20PermitUpgradeable** | Interface |  |||
| └ | permit | External ❗️ | 🛑  |NO❗️ |
| └ | nonces | External ❗️ |   |NO❗️ |
| └ | DOMAIN_SEPARATOR | External ❗️ |   |NO❗️ |
||||||
| **AddressUpgradeable** | Library |  |||
| └ | isContract | Internal 🔒 |   | |
| └ | sendValue | Internal 🔒 | 🛑  | |
| └ | functionCall | Internal 🔒 | 🛑  | |
| └ | functionCall | Internal 🔒 | 🛑  | |
| └ | functionCallWithValue | Internal 🔒 | 🛑  | |
| └ | functionCallWithValue | Internal 🔒 | 🛑  | |
| └ | functionStaticCall | Internal 🔒 |   | |
| └ | functionStaticCall | Internal 🔒 |   | |
| └ | functionDelegateCall | Internal 🔒 | 🛑  | |
| └ | functionDelegateCall | Internal 🔒 | 🛑  | |
| └ | verifyCallResultFromTarget | Internal 🔒 |   | |
| └ | verifyCallResult | Internal 🔒 |   | |
| └ | _revert | Private 🔐 |   | |
||||||
| **OwnableUpgradeable** | Implementation | Initializable, ContextUpgradeable |||
| └ | __Ownable_init | Internal 🔒 | 🛑  | onlyInitializing |
| └ | __Ownable_init_unchained | Internal 🔒 | 🛑  | onlyInitializing |
| └ | owner | Public ❗️ |   |NO❗️ |
| └ | _checkOwner | Internal 🔒 |   | |
| └ | renounceOwnership | Public ❗️ | 🛑  | onlyOwner |
| └ | transferOwnership | Public ❗️ | 🛑  | onlyOwner |
| └ | _transferOwnership | Internal 🔒 | 🛑  | |
||||||
| **ContextUpgradeable** | Implementation | Initializable |||
| └ | __Context_init | Internal 🔒 | 🛑  | onlyInitializing |
| └ | __Context_init_unchained | Internal 🔒 | 🛑  | onlyInitializing |
| └ | _msgSender | Internal 🔒 |   | |
| └ | _msgData | Internal 🔒 |   | |
| └ | _contextSuffixLength | Internal 🔒 |   | |
||||||
| **Initializable** | Implementation |  |||
| └ | _disableInitializers | Internal 🔒 | 🛑  | |
| └ | _getInitializedVersion | Internal 🔒 |   | |
| └ | _isInitializing | Internal 🔒 |   | |
||||||
| **UUPSUpgradeable** | Implementation | Initializable, IERC1822ProxiableUpgradeable, ERC1967UpgradeUpgradeable |||
| └ | __UUPSUpgradeable_init | Internal 🔒 | 🛑  | onlyInitializing |
| └ | __UUPSUpgradeable_init_unchained | Internal 🔒 | 🛑  | onlyInitializing |
| └ | proxiableUUID | External ❗️ |   | notDelegated |
| └ | upgradeTo | Public ❗️ | 🛑  | onlyProxy |
| └ | upgradeToAndCall | Public ❗️ |  💵 | onlyProxy |
| └ | _authorizeUpgrade | Internal 🔒 | 🛑  | |
||||||
| **IERC1822ProxiableUpgradeable** | Interface |  |||
| └ | proxiableUUID | External ❗️ |   |NO❗️ |
||||||
| **ERC1967UpgradeUpgradeable** | Implementation | Initializable, IERC1967Upgradeable |||
| └ | __ERC1967Upgrade_init | Internal 🔒 | 🛑  | onlyInitializing |
| └ | __ERC1967Upgrade_init_unchained | Internal 🔒 | 🛑  | onlyInitializing |
| └ | _getImplementation | Internal 🔒 |   | |
| └ | _setImplementation | Private 🔐 | 🛑  | |
| └ | _upgradeTo | Internal 🔒 | 🛑  | |
| └ | _upgradeToAndCall | Internal 🔒 | 🛑  | |
| └ | _upgradeToAndCallUUPS | Internal 🔒 | 🛑  | |
| └ | _getAdmin | Internal 🔒 |   | |
| └ | _setAdmin | Private 🔐 | 🛑  | |
| └ | _changeAdmin | Internal 🔒 | 🛑  | |
| └ | _getBeacon | Internal 🔒 |   | |
| └ | _setBeacon | Private 🔐 | 🛑  | |
| └ | _upgradeBeaconToAndCall | Internal 🔒 | 🛑  | |
||||||
| **IBeaconUpgradeable** | Interface |  |||
| └ | implementation | External ❗️ |   |NO❗️ |
||||||
| **IERC1967Upgradeable** | Interface |  |||
||||||
| **StorageSlotUpgradeable** | Library |  |||
| └ | getAddressSlot | Internal 🔒 |   | |
| └ | getBooleanSlot | Internal 🔒 |   | |
| └ | getBytes32Slot | Internal 🔒 |   | |
| └ | getUint256Slot | Internal 🔒 |   | |
| └ | getStringSlot | Internal 🔒 |   | |
| └ | getStringSlot | Internal 🔒 |   | |
| └ | getBytesSlot | Internal 🔒 |   | |
| └ | getBytesSlot | Internal 🔒 |   | |
||||||
| **ReentrancyGuardUpgradeable** | Implementation | Initializable |||
| └ | __ReentrancyGuard_init | Internal 🔒 | 🛑  | onlyInitializing |
| └ | __ReentrancyGuard_init_unchained | Internal 🔒 | 🛑  | onlyInitializing |
| └ | _nonReentrantBefore | Private 🔐 | 🛑  | |
| └ | _nonReentrantAfter | Private 🔐 | 🛑  | |
| └ | _reentrancyGuardEntered | Internal 🔒 |   | |


 Legend

|  Symbol  |  Meaning  |
|:--------:|-----------|
|    🛑    | Function can modify state |
|    💵    | Function is payable |
