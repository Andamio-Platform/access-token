module Andamio.Utility.TxInInfo 
    ( lazyTxInInfoTxOutRefBd
    , lazyTxInInfoTxOutBd
    , lazyTxInInfoTxOutAddrBd
    , lazyTxInInfoValue
    , lazyTxInInfoValueMapBd
    , lazyTxInInfoValueBd
    , lazyTxInInfoTxOutOutDatBd
    , lazyTxInInfoTxOutInlineDatBd
    , lazyTxInInfoTxOutOutReferenceScriptBd
    , findLazyTxInInfoByTxOutRef
    , findLazyTxInInfoByTxOutRefToTxOutBd
    , findLazyTxInInfoByTxOutRefToAddrPkhBd
    , lazyTxInInfoConsumedBd
    , findLazyTxInInfoByTxOutAddr
    , findLazyTxInInfoByTxOutAddrToTxOutBd
    , findLazyTxInInfoByToken
    , findLazyTxInInfoBySingleTokenToTxOutBd
    , findLazyTxInInfoBySingleTokenToAddrBd
    , findLazyTxInInfoBySingleTokenToInlineDatBd
    , csInTxInInfosBd
    , singleTokenInOutAddrSame
    ) where

import           PlutusTx.Prelude                    (Bool(..), (==), ($), otherwise, error, (.))
import           PlutusLedgerApi.V3                  (Value(..), unsafeFromBuiltinData)
import qualified PlutusTx.Builtins.Internal    as BI (tail, head, unsafeDataAsMap)
import           PlutusTx.Builtins.Internal          (BuiltinData, BuiltinList, BuiltinPair)
import           PlutusTx.Builtins                   (null)
import           Andamio.Utility.Value               (csElem, singleTokenInValueBd)
import           Andamio.Utility.LazyContextV3       (constrArgs)
import           Andamio.Utility.Address             (getAddressBdScriptHashBd)
import           Andamio.Utility.TxOut               (findLazyTxOutBySingleTokenToAddrBd)

{-# INLINEABLE lazyTxInInfoTxOutRefBd #-}
lazyTxInInfoTxOutRefBd :: BuiltinData -> BuiltinData
lazyTxInInfoTxOutRefBd = BI.head . constrArgs

{-# INLINEABLE lazyTxInInfoTxOutBd #-}
lazyTxInInfoTxOutBd :: BuiltinData -> BuiltinData
lazyTxInInfoTxOutBd = BI.head . BI.tail . constrArgs

{-# INLINEABLE lazyTxInInfoTxOutAddrBd #-}
lazyTxInInfoTxOutAddrBd :: BuiltinData -> BuiltinData
lazyTxInInfoTxOutAddrBd = BI.head . constrArgs . lazyTxInInfoTxOutBd

{-# INLINEABLE lazyTxInInfoValueBd #-}
lazyTxInInfoValueBd :: BuiltinData -> BuiltinData
lazyTxInInfoValueBd = BI.head . BI.tail . constrArgs . lazyTxInInfoTxOutBd

{-# INLINEABLE lazyTxInInfoValueMapBd #-}
lazyTxInInfoValueMapBd :: BuiltinData -> BuiltinList (BuiltinPair BuiltinData BuiltinData)
lazyTxInInfoValueMapBd = BI.unsafeDataAsMap . lazyTxInInfoValueBd

{-# INLINEABLE lazyTxInInfoValue #-}
lazyTxInInfoValue :: BuiltinData -> Value
lazyTxInInfoValue = unsafeFromBuiltinData . lazyTxInInfoValueBd

{-# INLINEABLE lazyTxInInfoTxOutOutDatBd #-}
lazyTxInInfoTxOutOutDatBd :: BuiltinData -> BuiltinData
lazyTxInInfoTxOutOutDatBd = BI.head . BI.tail . BI.tail . constrArgs . lazyTxInInfoTxOutBd

{-# INLINEABLE lazyTxInInfoTxOutInlineDatBd #-}
lazyTxInInfoTxOutInlineDatBd :: BuiltinData -> BuiltinData
lazyTxInInfoTxOutInlineDatBd = BI.head . constrArgs . lazyTxInInfoTxOutOutDatBd

{-# INLINEABLE lazyTxInInfoTxOutOutReferenceScriptBd #-}
lazyTxInInfoTxOutOutReferenceScriptBd :: BuiltinData -> BuiltinData
lazyTxInInfoTxOutOutReferenceScriptBd = BI.head . BI.tail . BI.tail . BI.tail . constrArgs . lazyTxInInfoTxOutBd

{-# INLINEABLE csInTxInInfosBd #-}
csInTxInInfosBd :: BuiltinList BuiltinData -> BuiltinData -> Bool
csInTxInInfosBd bdList cs 
  | null bdList = False
  | csElem (lazyTxInInfoValueMapBd $ BI.head bdList) cs = True
  | otherwise = csInTxInInfosBd (BI.tail bdList) cs

{-# INLINEABLE findLazyTxInInfoByTxOutRef #-}
findLazyTxInInfoByTxOutRef :: BuiltinList BuiltinData -> BuiltinData -> BuiltinData
findLazyTxInInfoByTxOutRef bdTxIns txRefBd
  | null bdTxIns = error ()
  | lazyTxInInfoTxOutRefBd (BI.head bdTxIns) == txRefBd = BI.head bdTxIns
  | otherwise = findLazyTxInInfoByTxOutRef (BI.tail bdTxIns) txRefBd

{-# INLINEABLE findLazyTxInInfoByTxOutRefToTxOutBd #-}
findLazyTxInInfoByTxOutRefToTxOutBd :: BuiltinList BuiltinData -> BuiltinData -> BuiltinData
findLazyTxInInfoByTxOutRefToTxOutBd bdTxIns txRefBd = lazyTxInInfoTxOutBd $ findLazyTxInInfoByTxOutRef bdTxIns txRefBd

{-# INLINEABLE findLazyTxInInfoByTxOutRefToAddrPkhBd #-}
findLazyTxInInfoByTxOutRefToAddrPkhBd :: BuiltinList BuiltinData -> BuiltinData -> BuiltinData
findLazyTxInInfoByTxOutRefToAddrPkhBd bdTxIns txRefBd = getAddressBdScriptHashBd $ lazyTxInInfoTxOutAddrBd $ findLazyTxInInfoByTxOutRef bdTxIns txRefBd

{-# INLINEABLE lazyTxInInfoConsumedBd #-}
lazyTxInInfoConsumedBd :: BuiltinList BuiltinData -> BuiltinData -> Bool
lazyTxInInfoConsumedBd txIns txref 
  | null txIns = error ()
  | lazyTxInInfoTxOutRefBd (BI.head txIns) == txref = True
  | otherwise = lazyTxInInfoConsumedBd (BI.tail txIns) txref

{-# INLINEABLE findLazyTxInInfoByTxOutAddr #-}
findLazyTxInInfoByTxOutAddr :: BuiltinList BuiltinData -> BuiltinData -> BuiltinData
findLazyTxInInfoByTxOutAddr bdTxIns addr
  | null bdTxIns = error ()
  | lazyTxInInfoTxOutAddrBd (BI.head bdTxIns) == addr = BI.head bdTxIns
  | otherwise = findLazyTxInInfoByTxOutAddr (BI.tail bdTxIns) addr

{-# INLINEABLE findLazyTxInInfoByTxOutAddrToTxOutBd #-}
findLazyTxInInfoByTxOutAddrToTxOutBd :: BuiltinList BuiltinData -> BuiltinData -> BuiltinData
findLazyTxInInfoByTxOutAddrToTxOutBd bdTxIns addr = lazyTxInInfoTxOutBd $ findLazyTxInInfoByTxOutAddr bdTxIns addr

{-# INLINEABLE findLazyTxInInfoByToken #-}
findLazyTxInInfoByToken :: BuiltinList BuiltinData -> BuiltinData -> BuiltinData -> BuiltinData
findLazyTxInInfoByToken bdTxIns cs tn
  | null bdTxIns = error ()
  | singleTokenInValueBd (lazyTxInInfoValueMapBd $ BI.head bdTxIns) cs tn = BI.head bdTxIns
  | otherwise = findLazyTxInInfoByToken (BI.tail bdTxIns) cs tn

{-# INLINEABLE findLazyTxInInfoBySingleTokenToTxOutBd #-}
findLazyTxInInfoBySingleTokenToTxOutBd :: BuiltinList BuiltinData -> BuiltinData -> BuiltinData -> BuiltinData
findLazyTxInInfoBySingleTokenToTxOutBd bdTxIns cs tn = lazyTxInInfoTxOutBd $ findLazyTxInInfoByToken bdTxIns cs tn

{-# INLINEABLE findLazyTxInInfoBySingleTokenToAddrBd #-}
findLazyTxInInfoBySingleTokenToAddrBd :: BuiltinList BuiltinData -> BuiltinData -> BuiltinData -> BuiltinData
findLazyTxInInfoBySingleTokenToAddrBd bdTxIns cs tn = lazyTxInInfoTxOutAddrBd $ findLazyTxInInfoByToken bdTxIns cs tn

{-# INLINEABLE findLazyTxInInfoBySingleTokenToInlineDatBd #-}
findLazyTxInInfoBySingleTokenToInlineDatBd :: BuiltinList BuiltinData -> BuiltinData -> BuiltinData -> BuiltinData
findLazyTxInInfoBySingleTokenToInlineDatBd bdTxIns cs tn = lazyTxInInfoTxOutInlineDatBd $ findLazyTxInInfoByToken bdTxIns cs tn

{-# INLINEABLE singleTokenInOutAddrSame #-}
singleTokenInOutAddrSame :: BuiltinList BuiltinData -> BuiltinList BuiltinData -> BuiltinData -> BuiltinData -> Bool
singleTokenInOutAddrSame txIns txOuts cs tn = findLazyTxInInfoBySingleTokenToAddrBd txIns cs tn == findLazyTxOutBySingleTokenToAddrBd txOuts cs tn