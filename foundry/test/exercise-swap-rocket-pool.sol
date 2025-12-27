// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

import {Test, console} from "forge-std/Test.sol";
import {IRETH} from "@src/interfaces/rocket-pool/IRETH.sol";
import {IRocketStorage} from "@src/interfaces/rocket-pool/IRocketStorage.sol";
import {IRocketDepositPool} from
"@src/interfaces/rocket-pool/IRocketDepositPool.sol";
import {IRocketDAOProtocolSettingsDeposit} from
"@src/interfaces/rocket-pool/IRocketDAOProtocolSettingsDeposit.sol";
import {
RETH,
ROCKET_STORAGE,
ROCKET_DEPOSIT_POOL,
ROCKET_DAO_PROTOCOL_SETTINGS_DEPOSIT
} from "@src/Constants.sol";
import {SwapRocketPool} from "@src/exercises/SwapRocketPool.sol";

// forge test --fork-url $FORK_URL --match-path test/exercise-swap-rocket-pool.sol -vvv

uint256 constant CALC_BASE = 1e18;

contract RocketPoolTestBase is Test {
    IRETH internal constant reth = IRETH(RETH);
    IRocketStorage internal constant rStorage = IRocketStorage(ROCKET_STORAGE);
    IRocketDepositPool internal constant depositPool =
    IRocketDepositPool(ROCKET_DEPOSIT_POOL);
    IRocketDAOProtocolSettingsDeposit internal constant protocolSettings =
    IRocketDAOProtocolSettingsDeposit(ROCKET_DAO_PROTOCOL_SETTINGS_DEPOSIT);

    SwapRocketPool internal swap;

    function setUp() public virtual {
        swap = new SwapRocketPool();
    }

    function getLastDepositBlockKey(address user)
    public
    pure
    returns (bytes32)
    {
        return keccak256(abi.encodePacked("user.deposit.block", user));
    }

    function getLastDepositBlock(address user) public view returns (uint256) {
        return rStorage.getUint(getLastDepositBlockKey(user));
    }

    function getDepositDelay() public view returns (uint256) {
        return rStorage.getUint(
            keccak256(
                abi.encodePacked(
                    keccak256("dao.protocol.setting.network"),
                    "network.reth.deposit.delay"
                )
            )
        );
    }
}

contract RocketPoolViewTest is RocketPoolTestBase {
    function test_calcEthToReth() public view {
        uint256 rate = reth.getExchangeRate();
        console.log("Exchange rate: 1e18 rETH = %e ETH", rate);

        uint256 depositFee = protocolSettings.getDepositFee();
        uint256 ethAmount = 1e18;
        uint256 ethFee = ethAmount * depositFee / CALC_BASE;

        (uint256 rEthAmount, uint256 fee) = swap.calcEthToReth(ethAmount);

        console.log("rETH amount: %e", rEthAmount);
        console.log("Deposit fee: %e ETH", fee);

        assertEq(fee, ethFee);
        assertEq(rEthAmount, reth.getRethValue(ethAmount - fee));
    }

    function test_calcRethToEth() public view {
        uint256 rEthAmount = 1e18;
        uint256 ethAmount = swap.calcRethToEth(rEthAmount);
        console.log("ETH amount: %e", ethAmount);
        assertEq(ethAmount, reth.getEthValue(rEthAmount));
    }

    function test_getAvailability() public view {
        bool enabled = protocolSettings.getDepositEnabled();
        uint256 maxDeposit = depositPool.getMaximumDepositAmount();

        console.log("Deposit enabled:", enabled);
        console.log("Max deposit: %e", maxDeposit);

        (bool ok, uint256 max) = swap.getAvailability();

        assertEq(ok, enabled);
        assertEq(max, maxDeposit);
    }

    function test_getDepositDelay() public view {
        assertEq(swap.getDepositDelay(), getDepositDelay());
    }

    function test_getLastDepositBlock() public {
        // Slot of value = keccack256(key, slot where mapping is declared)
        bytes32 key = keccak256(
            abi.encode(getLastDepositBlockKey(address(this)), uint256(2))
        );
        uint256 blockNum = block.number;
        vm.store(address(rStorage), key, bytes32(blockNum));

        assertEq(swap.getLastDepositBlock(address(this)), blockNum);
    }
}

contract RocketPoolSwapTest is RocketPoolTestBase {
    // Set to true to forcefully enable deposit
    // Set to false to test with live contract states
    bool constant MOCK_CALLS = false;

    // Receive ETH from RocketPool
    receive() external payable {}

    function setUp() public override {
        super.setUp();

        if (MOCK_CALLS) {
            vm.mockCall(
                address(protocolSettings),
                abi.encodeCall(
                    IRocketDAOProtocolSettingsDeposit.getDepositEnabled, ()
                ),
                abi.encode(true)
            );
            vm.mockCall(
                address(depositPool),
                abi.encodeCall(IRocketDepositPool.getMaximumDepositAmount, ()),
                abi.encode(uint256(100 * 1e18))
            );
            vm.mockCall(
                address(reth),
                abi.encodeCall(IRETH.getExchangeRate, ()),
                abi.encode(uint256(1e18))
            );
        }

        console.log("Deposit enabled:", protocolSettings.getDepositEnabled());
        console.log("Dax deposit: %e", depositPool.getMaximumDepositAmount());
        console.log("Exchange rate: 1e18 rETH = %e ETH", reth.getExchangeRate());
    }

    function test_swapEthToReth() public {
        console.log("Deposit enabled:", protocolSettings.getDepositEnabled());
        uint256 ethAmount = 1e18;
        swap.swapEthToReth{value: ethAmount}();

        uint256 rEthBal = reth.balanceOf(address(swap));
        console.log("rETH balance: %e", rEthBal);

        assertGt(rEthBal, 0);
    }

    function test_swapRethToEth() public {
        // Fund ETH to rETH
        (bool ok,) = RETH.call{value: 10 * 1e18}("");
        require(ok, "Send ETH failed");

        depositPool.deposit{value: 1e18}();

        uint256 rEthAmount = reth.balanceOf(address(this));
        console.log("rETH balance: %e", rEthAmount);

        reth.approve(address(swap), rEthAmount);

        uint256 ethBalBefore = address(swap).balance;
        swap.swapRethToEth(rEthAmount);
        uint256 ethBalAfter = address(swap).balance;

        assertEq(reth.balanceOf(address(this)), 0);
        assertEq(reth.balanceOf(address(swap)), 0);
        assertGt(ethBalAfter, ethBalBefore);

        uint256 ethDelta = ethBalAfter - ethBalBefore;
        console.log("ETH received: %e", ethDelta);

        uint256 rate = reth.getExchangeRate();
        if (rate >= 1e18) {
            assertGe(ethDelta, rEthAmount);
        } else {
            assertGe(rEthAmount, ethDelta);
        }
    }
}