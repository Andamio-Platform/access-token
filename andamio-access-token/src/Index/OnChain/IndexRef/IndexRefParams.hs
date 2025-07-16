module Index.OnChain.IndexRef.IndexRefParams
                    ( IndexRefParams(..)
                    ) where

import           Prelude            as Pr (Show, Ord(..), Eq(..))
import           GHC.Generics             (Generic)

import           PlutusTx                 (makeLift, BuiltinData, makeIsDataSchemaIndexed)    
import           PlutusTx.Blueprint.Definition (HasBlueprintDefinition, definitionRef)                               

-- UserIndexValidator
data IndexRefParams = IndexRefParams
  { irpAdminCs :: !BuiltinData -- CurrencySymbol, admin cs allowed to change index data
  , irpRefCs   :: !BuiltinData -- CurrencySymbol, index ref cs, where index data is attached
  } deriving stock (Pr.Eq, Pr.Ord, Pr.Show, Generic)
    deriving anyclass HasBlueprintDefinition

PlutusTx.makeIsDataSchemaIndexed ''IndexRefParams [('IndexRefParams, 0)]
PlutusTx.makeLift ''IndexRefParams