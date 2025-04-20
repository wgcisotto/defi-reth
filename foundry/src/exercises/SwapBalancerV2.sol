// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import {IRETH} from "../interfaces/rocket-pool/IRETH.sol";
import {IERC20} from "../interfaces/IERC20.sol";
import {IVault} from "../interfaces/balancer/IVault.sol";
import {
    RETH,
    WETH,
    BALANCER_VAULT,
    BALANCER_POOL_ID_RETH_WETH
} from "../Constants.sol";

/// @title SwapBalancerV2
/// @notice This contract facilitates swaps between rETH and WETH using Balancer V2.
/// @dev The contract interacts with the Balancer Vault for token swaps.
contract SwapBalancerV2 {
    IRETH constant reth = IRETH(RETH);
    IERC20 constant weth = IERC20(WETH);
    IVault constant vault = IVault(BALANCER_VAULT);

    /// @notice Executes a token swap using the Balancer Vault.
    /// @param tokenIn The address of the token to swap from.
    /// @param tokenOut The address of the token to swap to.
    /// @param amountIn The amount of `tokenIn` to be swapped.
    /// @param amountOutMin The minimum amount of `tokenOut` to be received.
    /// @param poolId The Balancer pool ID for the swap.
    /// @return amountOut The amount of `tokenOut` received from the swap.
    /// @dev Uses the `GIVEN_IN` swap kind to specify the input token amount.
    function swap(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 amountOutMin,
        bytes32 poolId
    ) private returns (uint256 amountOut) {
        return vault.swap({
            singleSwap: IVault.SingleSwap({
                poolId: poolId,
                kind: IVault.SwapKind.GIVEN_IN,
                assetIn: tokenIn,
                assetOut: tokenOut,
                amount: amountIn,
                userData: ""
            }),
            funds: IVault.FundManagement({
                sender: address(this),
                fromInternalBalance: false,
                recipient: address(this),
                toInternalBalance: false
            }),
            limit: amountOutMin,
            deadline: block.timestamp
        });
    }

    /// @notice Swaps WETH to rETH using the Balancer Vault.
    /// @param wethAmountIn The amount of WETH to be swapped.
    /// @param rEthAmountOutMin The minimum amount of rETH to receive.
    /// @dev The caller must approve the contract to transfer WETH on their behalf.
    function swapWethToReth(uint256 wethAmountIn, uint256 rEthAmountOutMin)
        external
    {
        weth.transferFrom(msg.sender, address(this), wethAmountIn);
        weth.approve(BALANCER_VAULT, wethAmountIn);
        swap(
            WETH,
            RETH,
            wethAmountIn,
            rEthAmountOutMin,
            BALANCER_POOL_ID_RETH_WETH
        );
    }

    /// @notice Swaps rETH to WETH using the Balancer Vault.
    /// @param rEthAmountIn The amount of rETH to be swapped.
    /// @param wethAmountOutMin The minimum amount of WETH to receive.
    /// @dev The caller must approve the contract to transfer rETH on their behalf.
    function swapRethToWeth(uint256 rEthAmountIn, uint256 wethAmountOutMin)
        external
    {
        reth.transferFrom(msg.sender, address(this), rEthAmountIn);
        reth.approve(BALANCER_VAULT, rEthAmountIn);
        swap(
            RETH,
            WETH,
            rEthAmountIn,
            wethAmountOutMin,
            BALANCER_POOL_ID_RETH_WETH
        );
    }
}
