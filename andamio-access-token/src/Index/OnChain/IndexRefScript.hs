module Index.OnChain.IndexRefScript
                    ( IndexRefParams(..)
                    , IndexData(..)
                    , NewIndexData(..)
                    , indexRefValidatorCompiledCode
                    ) where

import           PlutusLedgerApi.V3                (unsafeFromBuiltinData, OutputDatum(..),
                                                   toBuiltinData, Address(..), Credential(..))
import           PlutusTx                          (compile, CompiledCode)     
import           PlutusTx.Prelude                  (BuiltinUnit, BuiltinData, Bool(..), error,
                                                   otherwise, ($), (==), (&&), (>))
import           PlutusTx.Builtins.Internal  as BI (head, tail, BuiltinList(..), unsafeDataAsConstr, snd, fst)
import           PlutusTx.Builtins           as B  (null)

import           Andamio.Utility.OnChain           (lazyRedeemerTyped, singleTokenInValueBd,
                                                   indexScriptsOnChainNameBd, mkInlineDatumBuiltin,
                                                   unitval, lazyTxOutAddrBd, csInTxOutsBd,
                                                   lazyTxInfoOutputsBd, flatValLength,
                                                   lazyInlineDatumTyped, lazyTxOutRefBd, lazyTxInfoInputsBd,
                                                   findLazyTxInInfoByTxOutRefToTxOutBd, lazyTxOutDatumBd,
                                                   lazyTxOutValueMapBd, lengthListTupleBd, lazyTxOutReferenceScriptBd)

import Index.OnChain.IndexRef.IndexData      (IndexData(..), NewIndexData(..))
import Index.OnChain.IndexRef.IndexRefParams (IndexRefParams(..))

{-
Spending Validator
Change Index Data if admin NFT present.
-}

{-# INLINEABLE mkValidator #-}
mkValidator :: IndexRefParams -> NewIndexData -> BuiltinData -> IndexData -> BuiltinList BuiltinData -> Bool
mkValidator IndexRefParams{..} newIndexData ownInput dat txInfoOutputsBd = 

                    csInTxOutsBd txInfoOutputsBd irpAdminCs &&
                    singleTokenInValueBd (lazyTxOutValueMapBd ownInput) irpRefCs indexScriptsOnChainNameBd &&
                    checkNewOutput txInfoOutputsBd &&
                    (flatValLength (newMintAccessTokenValue newIndexData) 0 > 0) &&
                    isAddr (unsafeFromBuiltinData $ newTreasuryAddr newIndexData) &&
                    isOutputDatum (unsafeFromBuiltinData $ newTreasuryDat newIndexData)

            where

              -- type check
              isOutputDatum :: OutputDatum -> Bool
              isOutputDatum NoOutputDatum = True
              isOutputDatum (OutputDatumHash _) = True
              isOutputDatum (OutputDatum _) = True

              -- type check
              isAddr :: Address -> Bool
              isAddr (Address _ _) = True

              -- new output present
              checkNewOutput :: BuiltinList BuiltinData -> Bool
              checkNewOutput  bdList
                    | B.null bdList = error ()
                    | lazyTxOutAddrBd (BI.head bdList) == lazyTxOutAddrBd ownInput = lazyTxOutReferenceScriptBd (BI.head bdList) == lazyTxOutReferenceScriptBd ownInput
                                                                                  && singleTokenInValueBd (lazyTxOutValueMapBd $ BI.head bdList) irpRefCs indexScriptsOnChainNameBd
                                                                                  && lengthListTupleBd (lazyTxOutValueMapBd $ BI.head bdList) 0 == 2
                                                                                  && lazyTxOutDatumBd (BI.head bdList) == mkInlineDatumBuiltin newIndexDataBd
                    | otherwise = checkNewOutput (BI.tail bdList)

              -- if just new init obs then is Script Credential
              newObsList :: [BuiltinData]
              newObsList
                | fst constr == 0 && isScriptCred (unsafeFromBuiltinData $ BI.head $ BI.snd constr) = (BI.head $ BI.snd constr):initGSObsShList dat
                | otherwise = initGSObsShList dat
                where

                  constr = BI.unsafeDataAsConstr $ newInitGSObsSh newIndexData

                  isScriptCred :: Credential -> Bool
                  isScriptCred (ScriptCredential _) = True
                  isScriptCred _ = False
              
              -- new output index data
              newIndexDataBd :: BuiltinData
              newIndexDataBd = toBuiltinData $ IndexData
                (newTreasuryAddr newIndexData)
                (newTreasuryDat newIndexData)
                (newMintAccessTokenValue newIndexData)
                newObsList


{-# INLINEABLE untypedValidator #-}
untypedValidator :: IndexRefParams -> BuiltinData -> BuiltinUnit
untypedValidator params ctx'
  | mkValidator params (lazyRedeemerTyped ctx') (findLazyTxInInfoByTxOutRefToTxOutBd (lazyTxInfoInputsBd ctx') (lazyTxOutRefBd ctx')) (lazyInlineDatumTyped ctx') (lazyTxInfoOutputsBd ctx') = unitval
  | otherwise = error ()

indexRefValidatorCompiledCode :: CompiledCode (BuiltinData -> BuiltinData -> BuiltinUnit)
indexRefValidatorCompiledCode = $$(PlutusTx.compile [||\params -> untypedValidator (unsafeFromBuiltinData params)||])