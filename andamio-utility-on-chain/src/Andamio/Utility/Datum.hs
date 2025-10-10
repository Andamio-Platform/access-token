module Andamio.Utility.Datum
    ( getTxOutInlineDatumTyped
    , mkInlineDatumBuiltin
    , nothingBd
    ) where

import PlutusTx.Prelude                    (error)
import PlutusLedgerApi.V3                  (OutputDatum(..), Datum(..), BuiltinData, 
                                           UnsafeFromData, unsafeFromBuiltinData)
import PlutusTx.Builtins.Internal    as BI (mkConstr, mkCons)
import PlutusTx.Builtins.HasOpaque         (mkNil)

{-# INLINEABLE getTxOutInlineDatumTyped #-}
getTxOutInlineDatumTyped :: forall dat. (UnsafeFromData dat) => OutputDatum -> dat
getTxOutInlineDatumTyped (OutputDatum (Datum bd)) = unsafeFromBuiltinData @dat bd
getTxOutInlineDatumTyped _ = error ()

{-# INLINEABLE mkInlineDatumBuiltin #-}
mkInlineDatumBuiltin :: BuiltinData -> BuiltinData
mkInlineDatumBuiltin bd = mkConstr 2 (BI.mkCons bd mkNil)

{-# INLINEABLE nothingBd #-}
nothingBd :: BuiltinData
nothingBd = mkConstr 1 mkNil