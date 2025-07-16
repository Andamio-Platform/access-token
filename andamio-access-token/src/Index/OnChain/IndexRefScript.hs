module Index.OnChain.IndexRefScript
                    ( IndexRefParams(..)
                    , IndexData(..)
                    , indexRefValidatorCompiledCode
                    ) where

import           PlutusLedgerApi.V3                (unsafeFromBuiltinData, OutputDatum(..),
                                                   toBuiltinData, Address(..), Credential(..))
import           PlutusTx                          (compile, CompiledCode)     
import           PlutusTx.Prelude                  (BuiltinUnit, BuiltinData, Bool(..), Integer, 
                                                   otherwise, ($), (==), (&&), (+), (<=), (>), 
                                                   error, (||))
import           PlutusTx.Builtins.Internal  as BI (head, tail, BuiltinList(..))
import           PlutusTx.Builtins           as B  (null)

import           Andamio.Utility.OnChain           (lazyRedeemerTyped, singleTokenInValueBd,
                                                   indexScriptsOnChainNameBd, mkInlineDatumBuiltin,
                                                   unitval, lazyTxOutAddrBd, csInTxOutsBd,
                                                   lazyTxInfoOutputsBd, flatValLength,
                                                   lazyInlineDatumTyped, lazyTxOutRefBd, lazyTxInfoInputsBd,
                                                   findLazyTxInInfoByTxOutRefToTxOutBd, lazyTxOutDatumBd,
                                                   lazyTxOutValueMapBd, lengthListTupleBd, lazyTxOutReferenceScriptBd)

import Index.OnChain.IndexRef.IndexData      (IndexData(..))
import Index.OnChain.IndexRef.IndexRefParams (IndexRefParams(..))

{-
Spending Validator
Change Index Data if admin NFT present.
-}

{-# INLINEABLE mkValidator #-}
mkValidator :: IndexRefParams -> IndexData -> BuiltinData -> IndexData -> BuiltinList BuiltinData -> Bool
mkValidator IndexRefParams{..} newIndexData ownInput dat txInfoOutputsBd = 

                    csInTxOutsBd txInfoOutputsBd irpAdminCs &&
                    singleTokenInValueBd (lazyTxOutValueMapBd ownInput) irpRefCs indexScriptsOnChainNameBd &&
                    checkNewOutput txInfoOutputsBd &&
                    (flatValLength (mintAccessTokenValue newIndexData) 0 > 0) &&
                    (lengthScrHL (initGSObsShList newIndexData) 0 <= (1 + lengthScrHL (initGSObsShList dat) 0)) &&
                    allScrHElem (initGSObsShList dat) &&
                    isAddr (unsafeFromBuiltinData $ treasuryAddr newIndexData) &&
                    isOutputDatum (unsafeFromBuiltinData $ treasuryDat newIndexData)

            where

              -- type check
              isOutputDatum :: OutputDatum -> Bool
              isOutputDatum NoOutputDatum = True
              isOutputDatum (OutputDatumHash _) = True
              isOutputDatum (OutputDatum _) = True

              -- type check
              isAddr :: Address -> Bool
              isAddr (Address _ _) = True

              lengthScrHL :: [BuiltinData] -> Integer -> Integer
              lengthScrHL [] counter = counter
              lengthScrHL (_:xs) counter = lengthScrHL xs (counter + 1)

              -- new output present
              checkNewOutput :: BuiltinList BuiltinData -> Bool
              checkNewOutput  bdList
                    | B.null bdList = error ()
                    | lazyTxOutAddrBd (BI.head bdList) == lazyTxOutAddrBd ownInput = lazyTxOutReferenceScriptBd (BI.head bdList) == lazyTxOutReferenceScriptBd ownInput
                                                                                  && singleTokenInValueBd (lazyTxOutValueMapBd $ BI.head bdList) irpRefCs indexScriptsOnChainNameBd
                                                                                  && lengthListTupleBd (lazyTxOutValueMapBd $ BI.head bdList) 0 == 2
                                                                                  && lazyTxOutDatumBd (BI.head bdList) == mkInlineDatumBuiltin (toBuiltinData newIndexData)
                    | otherwise = checkNewOutput (BI.tail bdList)

              -- old init observers are present in new one
              allScrHElem :: [BuiltinData] -> Bool
              allScrHElem [] = True
              allScrHElem (x:xs) = if elem (initGSObsShList newIndexData) x && isScriptCred (unsafeFromBuiltinData x)
                                   then allScrHElem xs
                                   else error ()
                where
                  elem :: [BuiltinData] -> BuiltinData -> Bool
                  elem [] _ = error ()
                  elem (x':xs') scrH = x' == scrH || elem xs' scrH

                  isScriptCred :: Credential -> Bool
                  isScriptCred (ScriptCredential _) = True
                  isScriptCred _ = False


{-# INLINEABLE untypedValidator #-}
untypedValidator :: IndexRefParams -> BuiltinData -> BuiltinUnit
untypedValidator params ctx'
  | mkValidator params (lazyRedeemerTyped ctx') (findLazyTxInInfoByTxOutRefToTxOutBd (lazyTxInfoInputsBd ctx') (lazyTxOutRefBd ctx')) (lazyInlineDatumTyped ctx') (lazyTxInfoOutputsBd ctx') = unitval
  | otherwise = error ()

indexRefValidatorCompiledCode :: CompiledCode (BuiltinData -> BuiltinData -> BuiltinUnit)
indexRefValidatorCompiledCode = $$(PlutusTx.compile [||\params -> untypedValidator (unsafeFromBuiltinData params)||])