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

import           PlutusTx.Prelude              (Bool(..), ($), otherwise, error, (==), (.))
import           PlutusLedgerApi.V3            (Value(..), unsafeFromBuiltinData)
import           PlutusTx.Builtins.Internal    (BuiltinList, BuiltinData, BuiltinPair, tail, 
                                               head, unsafeDataAsMap)
import           PlutusTx.Builtins             (null)
import           Andamio.Utility.Value         (singleTokenInValueBd, csElem)
import           Andamio.Utility.LazyContextV3 (constrArgs)

{-# INLINEABLE lazyTxOutAddrBd #-}
lazyTxOutAddrBd :: BuiltinData -> BuiltinData
lazyTxOutAddrBd = head . constrArgs

{-# INLINEABLE lazyTxOutValueBd #-}
lazyTxOutValueBd :: BuiltinData -> BuiltinData
lazyTxOutValueBd = head . tail . constrArgs

{-# INLINEABLE lazyTxOutValueMapBd #-}
lazyTxOutValueMapBd :: BuiltinData -> BuiltinList (BuiltinPair BuiltinData BuiltinData)
lazyTxOutValueMapBd = unsafeDataAsMap . lazyTxOutValueBd

{-# INLINEABLE lazyTxOutValue #-}
lazyTxOutValue :: BuiltinData -> Value
lazyTxOutValue = unsafeFromBuiltinData . lazyTxOutValueBd

{-# INLINEABLE lazyTxOutDatumBd #-}
lazyTxOutDatumBd :: BuiltinData -> BuiltinData
lazyTxOutDatumBd = head . tail . tail . constrArgs

{-# INLINEABLE lazyTxOutInlineDatBd #-}
lazyTxOutInlineDatBd :: BuiltinData -> BuiltinData
lazyTxOutInlineDatBd = head . constrArgs . lazyTxOutDatumBd

{-# INLINEABLE lazyTxOutReferenceScriptBd #-}
lazyTxOutReferenceScriptBd :: BuiltinData -> BuiltinData
lazyTxOutReferenceScriptBd = head . tail . tail . tail . constrArgs

{-# INLINEABLE csInTxOutsBd #-}
csInTxOutsBd :: BuiltinList BuiltinData -> BuiltinData -> Bool
csInTxOutsBd bdList cs 
  | null bdList = False
  | csElem (lazyTxOutValueMapBd $ head bdList) cs = True
  | otherwise = csInTxOutsBd (tail bdList) cs

{-# INLINEABLE findLazyTxOutByCs #-}
findLazyTxOutByCs :: BuiltinList BuiltinData -> BuiltinData -> BuiltinData
findLazyTxOutByCs txOutsBd cs
  | null txOutsBd = error ()
  | csElem (lazyTxOutValueMapBd $ head txOutsBd) cs = head txOutsBd
  | otherwise = findLazyTxOutByCs (tail txOutsBd) cs

{-# INLINEABLE findLazyTxOutByAddr #-}
findLazyTxOutByAddr :: BuiltinList BuiltinData -> BuiltinData -> BuiltinData
findLazyTxOutByAddr txOutsBd addr
  | null txOutsBd = error ()
  | lazyTxOutAddrBd (head txOutsBd) == addr = head txOutsBd
  | otherwise = findLazyTxOutByAddr (tail txOutsBd) addr

{-# INLINEABLE findLazyTxOutBySingleToken #-}
findLazyTxOutBySingleToken :: BuiltinList BuiltinData -> BuiltinData -> BuiltinData -> BuiltinData
findLazyTxOutBySingleToken txOutsBd cs tn
  | null txOutsBd = error ()
  | singleTokenInValueBd (lazyTxOutValueMapBd $ head txOutsBd) cs tn = head txOutsBd
  | otherwise = findLazyTxOutBySingleToken (tail txOutsBd) cs tn

{-# INLINEABLE findLazyTxOutBySingleTokenToAddrBd #-}
findLazyTxOutBySingleTokenToAddrBd :: BuiltinList BuiltinData -> BuiltinData -> BuiltinData -> BuiltinData
findLazyTxOutBySingleTokenToAddrBd txOutsBd cs tn = lazyTxOutAddrBd $ findLazyTxOutBySingleToken txOutsBd cs tn
