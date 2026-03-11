# andamio-access-token

## Audit

This codebase was audited by [TxPipe](https://txpipe.io) (December 31st, 2025). The full report is available at [audits/TxPipe.pdf](audits/TxPipe.pdf).

6 findings were identified. 5 are resolved. 1 is acknowledged but not fixed:

**AND-202 (Minor)** — Missing checks in the `IndexData` fields related to the treasury fees output. The `treasuryAddr`, `mintAccessTokenValue`, and `treasuryDatum` fields are not validated against ledger rules on-chain. The impact depends on the field: a misconfigured `treasuryAddr` or `treasuryDatum` would only affect fee collection — minting access tokens would still work, the fee receiver simply would not receive the fees correctly. Only a misconfigured `mintAccessTokenValue` containing no ADA could cause a temporary freeze of minting, as the ledger requires ADA in outputs. In all cases no funds are at risk and the issue is resolvable by the admin submitting a corrective update.

The decision not to enforce these checks on-chain was intentional. Updates to `IndexData` are gated by the presence of an admin NFT (`irppMasterAdmin`). That NFT can be held in a simple wallet (currently a multisig) or locked at a validator — and it is that validator which can enforce any additional rules. This design keeps the core contract flexible and future-proof: stricter validation can be introduced at any time by moving the admin NFT into a dedicated validator, without changing the audited contracts. See the audit report (section 5.d) for full details.



## [Access Policy](andamio-access-token/src/Index/OnChain/IndexScripts/MintingScript.hs)

`mkPolicy :: CurrencySymbol -> BuiltinByteString -> ScriptContext -> Bool`
- `CurrencySymbol` = init index policy id, boarders of the link list
- `BuiltinByteString`= user name to mint

### logic
- exactly one token from index present
- exactly 3 tokens with this policy minted
    - ("g" + user name) 
    - ("u" + user name)
    - (" ")

## [Index Validator](andamio-access-token/src/Index/OnChain/IndexScripts/SpendingScript.hs)

`mkValidator :: IndexParams -> IndexDatum -> IndexAction -> ScriptContext -> Bool`

```
data IndexParams = IndexParams
  { referenceIndexCs :: !CurrencySymbol -- reference token holding fee payment data/init global observer hash
  , startEndCs       :: !CurrencySymbol -- init index policy (linked list boarders)
  , indexCs          :: !CurrencySymbol -- access token policy
  , unlockScrHash    :: !ScriptHash     -- unlock ada observer
  }
```

```
data IndexDatum = IndexDatum 
  { this :: BuiltinByteString -- this element
  , next :: BuiltinByteString -- next element
  }
```

```
data IndexAction = AddIndex BuiltinByteString -- user name (new element in linked list) 
                 | UnlockAda -- unlock ada from utxos
```

### logic 
#### AddIndex
- exactly one utxo unlocked
- exactly 2 new outputs with correct datums
- new element between `this` and `next`
- new element used as redeemer for minting `indexCs` (access policy)
- fee is paid to address with correct datum
    - data from `referenceIndexCs` (tn="IndexValidator") datum 
- init global state observer present (logic for "g" token output)
    - script hash from `referenceIndexCs` (tn="AccessPolicy") datum

#### UnlockAda 
- `unlockScrHash` = stake validator observer with logic for unlocking ada but not tokens 

## [Init Index Policy](andamio-access-token/src/Index/OnChain/InitIndexPolicy.hs)

`mkPolicy :: TxOutRef -> () -> ScriptContext -> Bool`
- `TxOutRef` = consume for uniqueness

### logic 
- exactly two tokens with " " as token name minted
- tx out ref consumed 

## [Unlock Ada Observer](andamio-access-token/src/Index/OnChain/IndexScripts/UnlockAdaObserver.hs)

`mkStakingValidator :: UnlockAdaObserverParams -> () -> ScriptContext -> Bool`

```
data UnlockAdaObserverParams = UnlockAdaObserverParams
  { uaopReferenceIndexCs :: !CurrencySymbol -- reference token to get treasury address/datum
  , uaopStartEndCs       :: !CurrencySymbol -- init index policy (linked list boarders)
  , uaopIndexCs          :: !CurrencySymbol -- access token policy
  }
```

### logic
#### Certifying
- can be registered but not staked

#### Rewarding
- inputs with `uaopStartEndCs` or `uaopIndexCs` have same output address and datum
- `uaopIndexCs` is not minted
- difference between input and output ada is send to treasury address with correct datum
    - data from `uaopReferenceIndexCs` (tn="IndexValidator") datum

## [Index Reference Policy](andamio-access-token/src/Index/OnChain/IndexRefScript.hs)

`mkPolicy :: TxOutRef -> () -> ScriptContext -> Bool`
- `TxOutRef` = consume for uniqueness

### logic 
- tx out ref consumed
- exactly 3 tokens minted
  - "AccessPolicy"
  - "IndexValidator"
  - "IndexStaking"

## [Index Reference Validator](andamio-access-token/src/Index/OnChain/IndexRef/IndexRefParams.hs)

`mkValidator :: IndexRefParamsParams -> IndexRefParamsDatum -> IndexRefParamsAction -> ScriptContext -> Bool`

```
data IndexRefParamsParams = IndexRefParamsParams
  { irppMasterAdmin :: !CurrencySymbol -- is allowed to change values in datums
  , irppParamsCs    :: !CurrencySymbol -- index ref cs, verifies correct utxos
  }
```

```
data IndexRefParamsDatum = AccessPolicy [ScriptHash] -- init global observers | locked with tn=AccessPolicy
                         | IndexValidator IndexData  -- data for minting access token/send staking rewards | locked with tn=IndexValidator
                         | IndexStaking PubKeyHash   -- stake pool id | stored with tn=IndexStaking

data IndexData = IndexData
  { treasuryAddr         :: Address     -- where to send access token minting fee/stake rewards
  , treasuryDatum        :: BuiltinData -- datum to send access token minting fee/stake rewards
  , mintAccessTokenValue :: [FlatValue] -- access token minting fee value
  }

data FlatValue = FlatValue 
  { cS :: CurrencySymbol -- fee currency symbol
  , tN :: TokenName      -- fee token name
  , iT :: Integer        -- fee amount
  }
```

```
data IndexRefParamsAction = AddAccessPolicy ScriptHash -- add init global observer
                          | ChangeIndexData IndexData  -- new data for minting access token/send staking rewards 
                          | ChangePoolId    PubKeyHash -- new stake pool id
```

### logic
- `irppMasterAdmin` present
#### AddAccessPolicy
- (tn=AccessPolicy) own in and output
- new init global observer not in input datum already
- reference script (Access Policy) in own output
- script hash added to output datum

#### ChangeIndexData
- (tn=IndexValidator) own in and output
- reference script (Index Validator) in own output
- output datum new `IndexData`
- new index data not empty

#### ChangePoolId
- (tn=IndexStaking) own in and output
- reference script (Index Validator) in own output
- pool id changed

## Build

Requires GHC 9.6.x and Cabal 3.8+.

To build:

```bash
cabal build all
```

To run tests:

```bash
cabal test all
```

To generate the compiled blueprint:

```bash
cabal run write-blueprints
```