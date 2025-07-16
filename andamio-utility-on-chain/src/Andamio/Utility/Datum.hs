module Andamio.Utility.Datum
    ( getTxOutInlineDatumTyped
    , mkInlineDatumBuiltin
    , nothingBd
    ) where

import PlutusTx.Prelude                    (error)
import PlutusLedgerApi.V3                  (OutputDatum(..), Datum(..), BuiltinData, 
                                           UnsafeFromData, unsafeFromBuiltinData)
import PlutusTx.Builtins.Internal    as BI (mkConstr, mkCons, mkNilData)
import Andamio.Utility.LazyContextV3       (unitval)

{-# INLINEABLE getTxOutInlineDatumTyped #-}
getTxOutInlineDatumTyped :: forall dat. (UnsafeFromData dat) => OutputDatum -> dat
getTxOutInlineDatumTyped (OutputDatum (Datum bd)) = unsafeFromBuiltinData @dat bd
getTxOutInlineDatumTyped _ = error ()

{-# INLINEABLE mkInlineDatumBuiltin #-}
mkInlineDatumBuiltin :: BuiltinData -> BuiltinData
mkInlineDatumBuiltin bd = mkConstr 2 (BI.mkCons bd (BI.mkNilData unitval))

{-# INLINEABLE nothingBd #-}
nothingBd :: BuiltinData
nothingBd = mkConstr 1 (BI.mkNilData unitval)