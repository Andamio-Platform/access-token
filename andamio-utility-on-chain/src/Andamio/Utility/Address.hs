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
import PlutusTx.Builtins.Internal    as BI (mkConstr, mkCons, head)
import PlutusTx.Builtins.HasOpaque         (mkNil)
import Andamio.Utility.LazyContextV3       (constrArgs)

{-# INLINEABLE scriptCredFromScrHash #-}
scriptCredFromScrHash :: ScriptHash -> BuiltinData
scriptCredFromScrHash sh = BI.mkConstr 1 (BI.mkCons (toBuiltinData sh) mkNil)

{-# INLINEABLE addressFromScriptHashesBd #-}
addressFromScriptHashesBd :: BuiltinData -> BuiltinData -> BuiltinData
addressFromScriptHashesBd pkh spkh = BI.mkConstr 0 (BI.mkCons (scriptCredFromScrHashBd pkh) (BI.mkCons (stakingScriptBdCredFromScriptCredBd spkh) mkNil))

{-# INLINEABLE scriptCredFromScrHashBd #-}
scriptCredFromScrHashBd :: BuiltinData -> BuiltinData
scriptCredFromScrHashBd sh = BI.mkConstr 1 (BI.mkCons sh mkNil)

{-# INLINEABLE stakingScriptBdCredFromScriptCredBd #-}
stakingScriptBdCredFromScriptCredBd:: BuiltinData -> BuiltinData
stakingScriptBdCredFromScriptCredBd sh = BI.mkConstr 0 $ BI.mkCons (BI.mkConstr 0 $ BI.mkCons (scriptCredFromScrHashBd sh) mkNil) mkNil

{-# INLINEABLE justScriptHashBd #-}
justScriptHashBd :: ScriptHash -> BuiltinData
justScriptHashBd sh = mkConstr 0 (BI.mkCons (toBuiltinData sh) mkNil)

{-# INLINEABLE justBdScriptHashBd #-}
justBdScriptHashBd :: BuiltinData -> BuiltinData
justBdScriptHashBd sh = mkConstr 0 (BI.mkCons sh mkNil)

{-# INLINEABLE getAddressBdScriptHash #-}
getAddressBdScriptHash :: BuiltinData -> ScriptHash
getAddressBdScriptHash = unsafeFromBuiltinData . head . constrArgs . head . constrArgs

{-# INLINEABLE getAddressBdScriptHashBd #-}
getAddressBdScriptHashBd :: BuiltinData -> BuiltinData
getAddressBdScriptHashBd = head . constrArgs . head . constrArgs