module Index.OnChain.IndexScripts.MintingScript
                    ( mkMintingScript
                    ) where


import PlutusLedgerApi.V3                            (unsafeFromBuiltinData, toBuiltinData)
import PlutusTx.Prelude                       as PPr (Integer, Bool(..), fst, snd, BuiltinByteString, 
                                                     (+), (==), otherwise, (&&), ($), error, 
                                                     (||), (<), BuiltinData)
import PlutusTx.Builtins.Internal             as BI  (head, tail, BuiltinList(..), BuiltinPair, 
                                                     unsafeDataAsMap, mkI, mkCons, mkNilData,
                                                     unitval)
import PlutusTx.Builtins                      as B   (null)

import Andamio.Utility.OnChain                       (indexTokenNameBd, lazyTxInInfoTxOutInlineDatBd,
                                                     lazyTxOutDatumBd, tnAmBdMapByCsFromValueBd,
                                                     lazyTxOutReferenceScriptBd, csElem, tupleElemOnlyOne,
                                                     lazyTxOutValueMapBd, lazyTxOutAddrBd,
                                                     singleTokenInValueBd, flatValLength, create100Tn,
                                                     addressFromScriptHashesBd, mkInlineDatumBuiltin,
                                                     nothingBd, flatValuePaidBd, lazyTxInInfoValueMapBd,
                                                     lengthListTupleBd, builtinsElemMapBd, create222Tn)

import Index.OnChain.IndexScripts.IndexParams        (IndexParams(..))
import Index.OnChain.IndexRef.IndexData              (IndexData(..))

{-
Minting Validator
Handle minting of Access Token (CIP68 NFT). 

- mint exactly 3 tokens
  - CIP68 pair
  - index token -> space as token name
- pay fee to protocol treasury
- one index token as input
- new alias between Pair of index token datum
- two new index token outputs
- init global state observer present
-}

{-# INLINEABLE mkMintingScript #-}
mkMintingScript :: IndexParams -> IndexData -> BuiltinByteString -> BuiltinData -> BuiltinData -> BuiltinList BuiltinData -> BuiltinList BuiltinData -> BuiltinList (BuiltinPair BuiltinData BuiltinData) -> Bool
mkMintingScript IndexParams{..} indexData newElement ownSymbolBd txInfoMintBd txInfoInputsBd txInfoOutputsBd txInfoWdrlBd =

        let ownAddress = addressFromScriptHashesBd ownSymbolBd stakingScrHash
            dat = filterTxInInfoByTokenDatumBd txInfoInputsBd (mkNilData unitval)
            toOutputDatum this next = mkInlineDatumBuiltin $ toBuiltinData (this, next)
            thisPolicyMintTnAm = tnAmBdMapByCsFromValueBd (BI.unsafeDataAsMap txInfoMintBd) ownSymbolBd
        in
           lengthListTupleBd thisPolicyMintTnAm 0 == 3
        && builtinsElemMapBd thisPolicyMintTnAm indexTokenNameBd (BI.mkI 1)
        && builtinsElemMapBd thisPolicyMintTnAm (create100Tn newElement) (BI.mkI 1)
        && builtinsElemMapBd thisPolicyMintTnAm (create222Tn newElement) (BI.mkI 1)
        && feeIsPaid txInfoOutputsBd
        && checkNewOutputs ownAddress (toOutputDatum (PPr.fst dat) newElement)
        && checkNewOutputs ownAddress (toOutputDatum newElement (PPr.snd dat))
        && (PPr.fst dat < newElement && newElement < PPr.snd dat)
        && checkSPkhPresent (initGSObsShList indexData) 0
        
    where

        -- own input with linked list token
        filterTxInInfoByTokenDatumBd :: BuiltinList BuiltinData -> BuiltinList BuiltinData -> (BuiltinByteString, BuiltinByteString)
        filterTxInInfoByTokenDatumBd txInInfosBd ins
          | B.null txInInfosBd = if B.null (BI.tail ins) 
                                 then unsafeFromBuiltinData $ lazyTxInInfoTxOutInlineDatBd (BI.head ins)
                                 else error ()
          | oneTokenInValue (lazyTxInInfoValueMapBd $ BI.head txInInfosBd) = filterTxInInfoByTokenDatumBd (BI.tail txInInfosBd) (mkCons (BI.head txInInfosBd) ins)
          | otherwise = filterTxInInfoByTokenDatumBd (BI.tail txInInfosBd) ins

        -- either boarder token or own symbol
        oneTokenInValue :: BuiltinList (BuiltinPair BuiltinData BuiltinData) -> Bool
        oneTokenInValue value = singleTokenInValueBd value ownSymbolBd indexTokenNameBd 
                             || singleTokenInValueBd value startEndCs indexTokenNameBd

        -- exactly one init observer withdraw script present
        checkSPkhPresent :: [BuiltinData] -> Integer -> Bool
        checkSPkhPresent [] counter = counter == 1
        checkSPkhPresent (x:xs) counter = if csElem txInfoWdrlBd x
                                          then checkSPkhPresent xs (counter + 1)
                                          else checkSPkhPresent xs counter

        -- new output present
        checkNewOutputs :: BuiltinData -> BuiltinData -> Bool
        checkNewOutputs addr outDat = go txInfoOutputsBd
          where
            go :: BuiltinList BuiltinData -> Bool
            go bdList
              | B.null bdList = error ()
              | lazyTxOutAddrBd (BI.head bdList) == addr && lazyTxOutDatumBd (BI.head bdList) == outDat = lazyTxOutReferenceScriptBd (BI.head bdList) == nothingBd
                                                                                              && oneTokenInValue (lazyTxOutValueMapBd $ BI.head bdList)
                                                                                              && tupleElemOnlyOne (lazyTxOutValueMapBd $ BI.head bdList) 0 == 2
              | otherwise = go (BI.tail bdList) 

        -- fee from index ref is paid
        feeIsPaid :: BuiltinList BuiltinData -> Bool
        feeIsPaid bdList 
          | B.null bdList = error ()
          | lazyTxOutAddrBd (BI.head bdList) == treasuryAddr indexData = let value = lazyTxOutValueMapBd (BI.head bdList)
                                                                       in
                                                                       flatValuePaidBd (mintAccessTokenValue indexData) value
                                                                    && tupleElemOnlyOne value 0 == flatValLength (mintAccessTokenValue indexData) 0
                                                                    && lazyTxOutReferenceScriptBd (BI.head bdList) == nothingBd
                                                                    && treasuryDat indexData == lazyTxOutDatumBd (BI.head bdList)   
          | otherwise = feeIsPaid (BI.tail bdList)