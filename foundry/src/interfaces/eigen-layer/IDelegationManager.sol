// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

interface IDelegationManager {
    struct SignatureWithExpiry {
        bytes signature;
        uint256 expiry;
    }

    function delegateTo(
        address operator,
        SignatureWithExpiry memory approverSignatureAndExpiry,
        bytes32 approverSalt
    ) external;

    function undelegate(address staker)
        external
        returns (bytes32[] memory withdrawalRoot);

    struct QueuedWithdrawalParams {
        address[] strategies;
        uint256[] shares;
        address withdrawer;
    }

    function queueWithdrawals(
        QueuedWithdrawalParams[] calldata queuedWithdrawalParams
    ) external returns (bytes32[] memory);

    struct Withdrawal {
        address staker;
        address delegatedTo;
        address withdrawer;
        uint256 nonce;
        uint32 startBlock;
        address[] strategies;
        uint256[] shares;
    }

    function completeQueuedWithdrawal(
        Withdrawal calldata withdrawal,
        address[] calldata tokens,
        bool receiveAsTokens
    ) external;

    function getWithdrawalDelay(address[] calldata strategies)
        external
        view
        returns (uint256);

    function delegatedTo(address staker) external view returns (address);

    function minWithdrawalDelayBlocks() external view returns (uint256);
}
