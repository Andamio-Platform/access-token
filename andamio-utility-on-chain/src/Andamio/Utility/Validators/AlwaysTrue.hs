module Andamio.Utility.Validators.AlwaysTrue
                      ( alwaysTrueSerialised
                      ) where

import           PlutusTx               (CompiledCode, compile)
import           PlutusTx.Prelude       (BuiltinUnit, BuiltinData)
import           PlutusLedgerApi.V3     (SerialisedScript, serialiseCompiledCode)
import           Andamio.Utility.LazyContextV3 (unitval)

-- Policy to have a simple token for testing

{-# INLINEABLE anyScript #-}
anyScript :: BuiltinData -> BuiltinUnit
anyScript _ = unitval

alwaysTrueCompiledCode :: CompiledCode (BuiltinData -> BuiltinUnit)
alwaysTrueCompiledCode = $$(compile [||anyScript||])

alwaysTrueSerialised :: SerialisedScript
alwaysTrueSerialised = serialiseCompiledCode alwaysTrueCompiledCode