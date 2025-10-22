module Index.OnChain.IndexRef.IndexData
                    ( IndexData(..)
                    , NewIndexData(..)
                    ) where

import           GHC.Generics                  (Generic)

import           PlutusLedgerApi.V3            (BuiltinData)
import           PlutusTx                      (makeLift, makeIsDataSchemaIndexed)
import           PlutusTx.Blueprint.Definition (HasBlueprintDefinition, definitionRef)
import           Andamio.Utility.OnChain       (FlatValue(..))                     

data IndexData = IndexData
  { treasuryAddr         :: BuiltinData   -- Address, where to send access token minting fee/stake rewards (porotcol treasury)
  , treasuryDat          :: BuiltinData   -- OutputDatum, output datum as BuiltinData
  , mintAccessTokenValue :: [FlatValue]   -- access token minting fee value
  , initGSObsShList      :: [BuiltinData] -- observer script credential list
  } deriving stock (Generic)
    deriving anyclass HasBlueprintDefinition
    
PlutusTx.makeIsDataSchemaIndexed ''IndexData [('IndexData, 0)]
PlutusTx.makeLift ''IndexData

data NewIndexData = NewIndexData
  { newTreasuryAddr         :: BuiltinData   --Address, where to send access token minting fee/stake rewards (porotcol treasury)
  , newTreasuryDat          :: BuiltinData   -- OutputDatum, output datum as BuiltinData
  , newMintAccessTokenValue :: [FlatValue]   -- access token minting fee value
  , newInitGSObsSh          :: BuiltinData    -- maybe new observer script credential
  } deriving stock (Generic)
    deriving anyclass HasBlueprintDefinition

PlutusTx.makeIsDataSchemaIndexed ''NewIndexData [('NewIndexData, 0)]
PlutusTx.makeLift ''NewIndexData