module Andamio.Utility.TxOut 
    ( lazyTxOutAddrBd
    , lazyTxOutValue
    , lazyTxOutValueMapBd
    , lazyTxOutValueBd
    , lazyTxOutDatumBd
    , lazyTxOutInlineDatBd
    , lazyTxOutReferenceScriptBd
    , csInTxOutsBd
    , findLazyTxOutByCs
    , findLazyTxOutByAddr
    , findLazyTxOutBySingleTokenToAddrBd
    , findLazyTxOutBySingleToken
    ) where

import           PlutusTx.Prelude                    (Bool(..), ($), otherwise, error, (==), (.))
import           PlutusLedgerApi.V3                  (Value(..), unsafeFromBuiltinData)
import qualified PlutusTx.Builtins.Internal    as BI (tail, head, unsafeDataAsMap)
import           PlutusTx.Builtins.Internal          (BuiltinList, BuiltinData, BuiltinPair)
import           PlutusTx.Builtins                   (null)
import           Andamio.Utility.Value               (singleTokenInValueBd, csElem)
import           Andamio.Utility.LazyContextV3       (constrArgs)

{-# INLINEABLE lazyTxOutAddrBd #-}
lazyTxOutAddrBd :: BuiltinData -> BuiltinData
lazyTxOutAddrBd = BI.head . constrArgs

{-# INLINEABLE lazyTxOutValueBd #-}
lazyTxOutValueBd :: BuiltinData -> BuiltinData
lazyTxOutValueBd = BI.head . BI.tail . constrArgs

{-# INLINEABLE lazyTxOutValueMapBd #-}
lazyTxOutValueMapBd :: BuiltinData -> BuiltinList (BuiltinPair BuiltinData BuiltinData)
lazyTxOutValueMapBd = BI.unsafeDataAsMap . lazyTxOutValueBd

{-# INLINEABLE lazyTxOutValue #-}
lazyTxOutValue :: BuiltinData -> Value
lazyTxOutValue = unsafeFromBuiltinData . lazyTxOutValueBd

{-# INLINEABLE lazyTxOutDatumBd #-}
lazyTxOutDatumBd :: BuiltinData -> BuiltinData
lazyTxOutDatumBd = BI.head . BI.tail . BI.tail . constrArgs

{-# INLINEABLE lazyTxOutInlineDatBd #-}
lazyTxOutInlineDatBd :: BuiltinData -> BuiltinData
lazyTxOutInlineDatBd = BI.head . constrArgs . lazyTxOutDatumBd

{-# INLINEABLE lazyTxOutReferenceScriptBd #-}
lazyTxOutReferenceScriptBd :: BuiltinData -> BuiltinData
lazyTxOutReferenceScriptBd = BI.head . BI.tail . BI.tail . BI.tail . constrArgs

{-# INLINEABLE csInTxOutsBd #-}
csInTxOutsBd :: BuiltinList BuiltinData -> BuiltinData -> Bool
csInTxOutsBd bdList cs 
  | null bdList = False
  | csElem (lazyTxOutValueMapBd $ BI.head bdList) cs = True
  | otherwise = csInTxOutsBd (BI.tail bdList) cs

{-# INLINEABLE findLazyTxOutByCs #-}
findLazyTxOutByCs :: BuiltinList BuiltinData -> BuiltinData -> BuiltinData
findLazyTxOutByCs txOutsBd cs
  | null txOutsBd = error ()
  | csElem (lazyTxOutValueMapBd $ BI.head txOutsBd) cs = BI.head txOutsBd
  | otherwise = findLazyTxOutByCs (BI.tail txOutsBd) cs

{-# INLINEABLE findLazyTxOutByAddr #-}
findLazyTxOutByAddr :: BuiltinList BuiltinData -> BuiltinData -> BuiltinData
findLazyTxOutByAddr txOutsBd addr
  | null txOutsBd = error ()
  | lazyTxOutAddrBd (BI.head txOutsBd) == addr = BI.head txOutsBd
  | otherwise = findLazyTxOutByAddr (BI.tail txOutsBd) addr

{-# INLINEABLE findLazyTxOutBySingleToken #-}
findLazyTxOutBySingleToken :: BuiltinList BuiltinData -> BuiltinData -> BuiltinData -> BuiltinData
findLazyTxOutBySingleToken txOutsBd cs tn
  | null txOutsBd = error ()
  | singleTokenInValueBd (lazyTxOutValueMapBd $ BI.head txOutsBd) cs tn = BI.head txOutsBd
  | otherwise = findLazyTxOutBySingleToken (BI.tail txOutsBd) cs tn

{-# INLINEABLE findLazyTxOutBySingleTokenToAddrBd #-}
findLazyTxOutBySingleTokenToAddrBd :: BuiltinList BuiltinData -> BuiltinData -> BuiltinData -> BuiltinData
findLazyTxOutBySingleTokenToAddrBd txOutsBd cs tn = lazyTxOutAddrBd $ findLazyTxOutBySingleToken txOutsBd cs tn
