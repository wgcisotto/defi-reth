### How to setup wallet using cast

```shell
# Account setup
PK=...
ACCOUNT=dev
cast wallet import --private-key $PK $ACCOUNT
```

### How to execute scripts

```shell
# Forge scripts
FORK_URL=...
ETHERSCAN_API_KEY=...
MSG_SENDER=...

# Example command to deploy a proxy contract
forge script script/deploy_proxy.sol:ProxyScript \
--rpc-url $FORK_URL \
-vvv \
--keystore ~/.foundry/keystores/my_keystore.json \
--sender $MSG_SENDER \
--broadcast \
--verify \
--etherscan-api-key $ETHERSCAN_API_KEY
```

### FlashLev scripts

Theses are the setups to open and close a leveraged position using the `FlashLev` contract.

#### Important Notice ⚠️

> **Warning:**  
> Only have one active leveraged position per proxy. Otherwise Aave health factor will return the calculation of all open positions.

0. Setup wallet with `cast`
1. Edit [configuration](./script/config.sol)
2. Deploy proxy ([script](./script/deploy_proxy.sol))
3. Approve token transfers ([script](./script/approve.sol))
4. Open position ([script](./script/open.sol))
5. Monitor stats ([script](./script/stats.sol))
6. Close position ([script](./script/close.sol))
