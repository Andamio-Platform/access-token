module Index.OnChain.IndexRef.IndexData
                    ( IndexData(..)
                    ) where

import           Prelude                as Pr  (Show, Ord(..), Eq(..))
import           GHC.Generics                  (Generic)

import           PlutusLedgerApi.V3            (BuiltinData)
import           PlutusTx                      (makeLift, makeIsDataSchemaIndexed)
import           PlutusTx.Prelude       as PPr (Eq(..), (&&))
import           PlutusTx.Blueprint.Definition (HasBlueprintDefinition, definitionRef)
import           Andamio.Utility.OnChain       (FlatValue(..))                     

data IndexData = IndexData
  { treasuryAddr         :: BuiltinData   --Address, where to send access token minting fee/stake rewards (porotcol treasury)
  , treasuryDat          :: BuiltinData   -- OutputDatum, output datum as BuiltinData
  , mintAccessTokenValue :: [FlatValue]   -- access token minting fee value
  , initGSObsShList      :: [BuiltinData] -- observer script credential list
  } deriving stock (Pr.Eq, Pr.Ord, Pr.Show, Generic)
    deriving anyclass HasBlueprintDefinition

instance PPr.Eq IndexData where
  {-# INLINEABLE (==) #-}
  IndexData tA tD mATV iGSSL == IndexData tA' tD' mATV' iGSSL' =
    (tA PPr.== tA') && (tD PPr.== tD') && (mATV PPr.== mATV') && (iGSSL PPr.== iGSSL')

PlutusTx.makeIsDataSchemaIndexed ''IndexData [('IndexData, 0)]
PlutusTx.makeLift ''IndexData