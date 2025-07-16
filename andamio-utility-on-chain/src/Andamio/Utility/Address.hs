module Andamio.Utility.Address
    ( scriptCredFromScrHash
    , scriptCredFromScrHashBd
    , justScriptHashBd
    , justBdScriptHashBd
    , addressFromScriptHashesBd
    , getAddressBdScriptHash
    , getAddressBdScriptHashBd
    ) where

import PlutusTx.Prelude                    (($), (.))
import PlutusLedgerApi.V3                  (ScriptHash(..), BuiltinData, 
                                           toBuiltinData, unsafeFromBuiltinData)
import PlutusTx.Builtins.Internal    as BI (mkConstr, mkNilData, mkCons, head)
import Andamio.Utility.LazyContextV3       (unitval, constrArgs)

{-# INLINEABLE scriptCredFromScrHash #-}
scriptCredFromScrHash :: ScriptHash -> BuiltinData
scriptCredFromScrHash sh = BI.mkConstr 1 (BI.mkCons (toBuiltinData sh) (BI.mkNilData unitval))

{-# INLINEABLE addressFromScriptHashesBd #-}
addressFromScriptHashesBd :: BuiltinData -> BuiltinData -> BuiltinData
addressFromScriptHashesBd pkh spkh = BI.mkConstr 0 (BI.mkCons (scriptCredFromScrHashBd pkh) (BI.mkCons (stakingScriptBdCredFromScriptCredBd spkh) (BI.mkNilData unitval)))

{-# INLINEABLE scriptCredFromScrHashBd #-}
scriptCredFromScrHashBd :: BuiltinData -> BuiltinData
scriptCredFromScrHashBd sh = BI.mkConstr 1 (BI.mkCons sh (BI.mkNilData unitval))

{-# INLINEABLE stakingScriptBdCredFromScriptCredBd #-}
stakingScriptBdCredFromScriptCredBd:: BuiltinData -> BuiltinData
stakingScriptBdCredFromScriptCredBd sh = BI.mkConstr 0 $ BI.mkCons (BI.mkConstr 0 $ BI.mkCons (scriptCredFromScrHashBd sh) (BI.mkNilData unitval)) (BI.mkNilData unitval)

{-# INLINEABLE justScriptHashBd #-}
justScriptHashBd :: ScriptHash -> BuiltinData
justScriptHashBd sh = mkConstr 0 (BI.mkCons (toBuiltinData sh) (BI.mkNilData unitval))

{-# INLINEABLE justBdScriptHashBd #-}
justBdScriptHashBd :: BuiltinData -> BuiltinData
justBdScriptHashBd sh = mkConstr 0 (BI.mkCons sh $ BI.mkNilData unitval)

{-# INLINEABLE getAddressBdScriptHash #-}
getAddressBdScriptHash :: BuiltinData -> ScriptHash
getAddressBdScriptHash = unsafeFromBuiltinData . head . constrArgs . head . constrArgs

{-# INLINEABLE getAddressBdScriptHashBd #-}
getAddressBdScriptHashBd :: BuiltinData -> BuiltinData
getAddressBdScriptHashBd = head . constrArgs . head . constrArgs