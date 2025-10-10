module Index.OnChain.IndexScripts.UnlockAdaObserver
                    ( mkUnlockAdaObserver
                    ) where


import PlutusTx.Prelude                       as PPr (Bool(..), Integer, BuiltinData, BuiltinByteString,
                                                     (||), (+), ($), (==), (&&), otherwise,
                                                     (-), (>=), error, (<))

import PlutusTx.Builtins                      as B   (null)
import Andamio.Utility.OnChain                       (singleTokenInValueBd, valueOfBd, lazyTxOutValueMapBd,
                                                     lazyTxOutAddrBd, constrArgs, indexTokenNameBd,
                                                     lazyTxOutReferenceScriptBd, lazyTxOutDatumBd, lengthListTupleBd,
                                                     nothingBd, adaTokenBd, adaSymbolBd, tupleElemOnlyOne,
                                                     lazyTxInInfoValueMapBd, addressFromScriptHashesBd)
import PlutusTx.Builtins.Internal             as BI  (head, tail, BuiltinList(..), mkCons, mkB, BuiltinPair)
import PlutusTx.Builtins.HasOpaque                   (mkNil)


import Index.OnChain.IndexScripts.IndexParams        (IndexParams(..))
import Index.OnChain.IndexRef.IndexData              (IndexData(..))

{-
Withdraw observer

Unlock Ada to protocol treasury without changing linked list. 
Accounting for a possible Cardano protocol change where minimum utxo ada will be lowered.
-}

{-# INLINEABLE mkUnlockAdaObserver #-}
mkUnlockAdaObserver :: IndexParams -> IndexData -> BuiltinByteString -> BuiltinList BuiltinData -> BuiltinList BuiltinData -> Bool
mkUnlockAdaObserver IndexParams{..} indexData ownBbs txInfoOutputs txInfoInputs =
  
                   paidToTreasury txInfoOutputs
                && checkInIsOut correctInputTxOuts

    where

        -- all inputs are in outputs with less ada
        checkInIsOut :: BuiltinList BuiltinData -> Bool
        checkInIsOut bdList
          | B.null bdList = True
          | checkOutExists (lazyTxOutDatumBd $ BI.head bdList) (lazyTxOutValueMapBd $ BI.head bdList) = checkInIsOut (BI.tail bdList)
          | otherwise = error ()
          
        -- exactly one output with token and datum
        checkOutExists :: BuiltinData -> BuiltinList (BuiltinPair BuiltinData BuiltinData) -> Bool
        checkOutExists dat val = go correctOutputTxOuts
          where
            go :: BuiltinList BuiltinData -> Bool
            go bdList
              | B.null bdList = False
              | lazyTxOutDatumBd (BI.head bdList) == dat = valueOfBd (lazyTxOutValueMapBd $ BI.head bdList) adaSymbolBd adaTokenBd < valueOfBd val adaSymbolBd adaTokenBd
              | otherwise = go (BI.tail bdList)

        -- ada unlocked sent to treasury from index ref datum
        paidToTreasury :: BuiltinList BuiltinData -> Bool
        paidToTreasury bdList
          | B.null bdList = error ()
          | lazyTxOutAddrBd (BI.head bdList) == treasuryAddr indexData = valueOfBd (lazyTxOutValueMapBd $ BI.head bdList) adaSymbolBd adaTokenBd >= adaInput - adaOutput
                                                                      && lazyTxOutDatumBd (BI.head bdList) == treasuryDat indexData
                                                                      && lazyTxOutReferenceScriptBd (BI.head bdList) == nothingBd
                                                                      && lengthListTupleBd (lazyTxOutValueMapBd $ BI.head bdList) 0 == 1
          | otherwise = paidToTreasury (BI.tail bdList)   
          where
            adaInput = getAdaAm correctInputTxOuts 0
            adaOutput = getAdaAm correctOutputTxOuts 0

        -- get ada amount from tx outs
        getAdaAm :: BuiltinList BuiltinData -> Integer -> Integer
        getAdaAm bdList counter
          | B.null bdList = counter
          | otherwise = getAdaAm (BI.tail bdList) (valueOfBd (lazyTxOutValueMapBd $ BI.head bdList) adaSymbolBd adaTokenBd + counter)

        -- inputs with linked list token
        correctInputTxOuts :: BuiltinList BuiltinData
        correctInputTxOuts = go txInfoInputs mkNil
          where
            go :: BuiltinList BuiltinData -> BuiltinList BuiltinData -> BuiltinList BuiltinData
            go bdList counter
              | B.null bdList = counter  
              | oneOf (lazyTxInInfoValueMapBd $ BI.head bdList) = go (BI.tail bdList) (mkCons (BI.head $ BI.tail $ constrArgs $ BI.head bdList) counter)
              | otherwise = go (BI.tail bdList) counter

        -- outputs back to index
        correctOutputTxOuts :: BuiltinList BuiltinData
        correctOutputTxOuts = go txInfoOutputs mkNil
          where
            go :: BuiltinList BuiltinData -> BuiltinList BuiltinData -> BuiltinList BuiltinData
            go bdList counter
              | B.null bdList = counter
              | lazyTxOutAddrBd (BI.head bdList) == addressFromScriptHashesBd (BI.mkB ownBbs) stakingScrHash &&
                oneOf (lazyTxOutValueMapBd $ BI.head bdList) &&
                tupleElemOnlyOne (lazyTxOutValueMapBd $ BI.head bdList) 0 == 2 &&
                lazyTxOutReferenceScriptBd (BI.head bdList) == nothingBd = go (BI.tail bdList) (mkCons (BI.head bdList) counter)
              | otherwise = go (BI.tail bdList) counter

        -- either boarder or own token
        oneOf :: BuiltinList (BuiltinPair BuiltinData BuiltinData) -> Bool
        oneOf value = singleTokenInValueBd value startEndCs indexTokenNameBd || singleTokenInValueBd value (BI.mkB ownBbs) indexTokenNameBd