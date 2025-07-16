{-# LANGUAGE DeriveDataTypeable #-}

module Index.OnChain.IndexScripts.IndexParams
                    ( IndexParams(..)
                    ) where

import           Prelude                       (Show, Ord(..), Eq(..))
import           GHC.Generics                  (Generic)

import           PlutusTx                      (makeLift, makeIsDataSchemaIndexed)
import           PlutusTx.Prelude              (BuiltinData)
import           PlutusTx.Blueprint.Definition (HasBlueprintDefinition, definitionRef)

data IndexParams = IndexParams
  { referenceIndexCs :: !BuiltinData -- CurrencySymbol, reference token cs holding fee payment data/init global observer hashes
  , startEndCs       :: !BuiltinData -- CurrencySymbol, init index policy cs (linked list boarders)
  , stakingScrHash   :: !BuiltinData -- ScriptHash, staking part script hash of the address
  } deriving stock (Eq, Ord, Show, Generic)
    deriving anyclass HasBlueprintDefinition

PlutusTx.makeIsDataSchemaIndexed ''IndexParams [('IndexParams, 0)]
PlutusTx.makeLift ''IndexParams