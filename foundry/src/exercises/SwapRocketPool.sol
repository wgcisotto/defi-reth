// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IRETH} from "../interfaces/rocket-pool/IRETH.sol";
import {IRocketDepositPool} from
"../interfaces/rocket-pool/IRocketDepositPool.sol";
import {IRocketDAOProtocolSettingsDeposit} from
"../interfaces/rocket-pool/IRocketDAOProtocolSettingsDeposit.sol";
import {IRocketStorage} from "../interfaces/rocket-pool/IRocketStorage.sol";
import {
RETH,
ROCKET_STORAGE,
ROCKET_DEPOSIT_POOL,
ROCKET_DAO_PROTOCOL_SETTINGS_DEPOSIT
} from "../Constants.sol";

/// @title SwapRocketPool
/// @notice This contract facilitates swapping between ETH and rETH using RocketPool.
/// @dev The contract interacts with RocketPool's deposit pool, rETH token, and protocol settings.
contract SwapRocketPool {
    IRETH public constant reth = IRETH(RETH);
    IRocketStorage public constant rStorage = IRocketStorage(ROCKET_STORAGE);
    IRocketDepositPool public constant depositPool =
    IRocketDepositPool(ROCKET_DEPOSIT_POOL);
    IRocketDAOProtocolSettingsDeposit public constant protocolSettings =
    IRocketDAOProtocolSettingsDeposit(ROCKET_DAO_PROTOCOL_SETTINGS_DEPOSIT);

    uint256 constant CALC_BASE = 1e18;

    /// @notice Calculates the amount of rETH received and fee charged for a given ETH amount.
    /// @param ethAmount The amount of ETH to be converted to rETH.
    /// @return rEthAmount The calculated amount of rETH to be received.
    /// @return fee The deposit fee deducted from the ETH amount.
    function calcEthToReth(uint256 ethAmount)
    external
    view
    returns (uint256 rEthAmount, uint256 fee)
    {
        // Write your code here
    }

    /// @notice Calculates the amount of ETH for a given rETH amount.
    /// @param rEthAmount The amount of rETH to be converted to ETH.
    /// @return ethAmount The calculated amount of ETH to be received.
    function calcRethToEth(uint256 rEthAmount)
    external
    view
    returns (uint256 ethAmount)
    {
        // Write your code here
    }

    /// @notice Retrieves the deposit availability status and maximum deposit amount.
    /// @return depositEnabled Whether deposits are currently enabled.
    /// @return maxDepositAmount The maximum allowed deposit amount in ETH.
    function getAvailability() external view returns (bool, uint256) {
        // Write your code here
    }

    /// @notice Retrieves the deposit delay for rETH deposits.
    /// @return depositDelay The delay in blocks before deposits are processed.
    function getDepositDelay() public view returns (uint256) {
        // Write your code here
    }

    /// @notice Retrieves the block number of the last deposit made by a user.
    /// @param user The address of the user.
    /// @return lastDepositBlock The block number of the user's last deposit.
    function getLastDepositBlock(address user) public view returns (uint256) {
        // Write your code here
    }

    /// @notice Swaps ETH to rETH by depositing ETH into the RocketPool deposit pool.
    /// @dev The caller must send ETH with this transaction.
    function swapEthToReth() external payable {
        // Write your code here
    }

    /// @notice Swaps rETH to ETH by burning rETH.
    /// @param rEthAmount The amount of rETH to be burned.
    /// @dev The caller must approve the contract to transfer the specified rETH amount.
    function swapRethToEth(uint256 rEthAmount) external {
        // Write your code here
    }
}