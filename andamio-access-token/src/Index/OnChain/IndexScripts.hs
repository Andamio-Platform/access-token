module Index.OnChain.IndexScripts
                    ( IndexParams(..)
                    , indexScriptsOnChainName
                    , indexTokenName
                    , indexValidatorCompiledCode
                    ) where
 
import           PlutusLedgerApi.V3                (unsafeFromBuiltinData)
import           PlutusTx                          (compile, CompiledCode)
import           PlutusTx.Prelude           as PPr (BuiltinUnit, BuiltinData, Bool(..), 
                                                   ($), otherwise, error, (==))

import           PlutusTx.Builtins.Internal as BI  (head, BuiltinList(..), unsafeDataAsConstr,
                                                   snd, fst, BuiltinPair, BuiltinInteger,
                                                   unsafeDataAsB)

import           Andamio.Utility.OnChain           (lazyRedeemerTyped, indexScriptsOnChainName, 
                                                   unitval, indexTokenName, indexScriptsOnChainNameBd,
                                                   lazyTxInfoWdrlBd, lazyTxInfoRedeemersBd, constrArgs,
                                                   lazyScriptInfoBd, findLazyTxInInfoBySingleTokenToInlineDatBd,
                                                   lazyTxInfoReferenceInputsBd, lazyTxInfoMintBd,
                                                   lazyTxInfoInputsBd, lazyTxInfoOutputsBd, constrArgs,
                                                   findLazyTxInInfoByTxOutRefToAddrPkhBd)

import           Index.OnChain.IndexScripts.IndexParams       (IndexParams(..))
import           Index.OnChain.IndexRef.IndexData             (IndexData(..))
import           Index.OnChain.IndexScripts.SpendingScript    (mkSpendingValidator)
import           Index.OnChain.IndexScripts.UnlockAdaObserver (mkUnlockAdaObserver)
import           Index.OnChain.IndexScripts.MintingScript     (mkMintingScript)

-- Which ScriptInfo?

{-# INLINEABLE untypedValidator #-}
untypedValidator :: IndexParams -> BuiltinData -> BuiltinUnit
untypedValidator params ctx'
  | validatorOrPolicy (BI.unsafeDataAsConstr $ lazyScriptInfoBd ctx') = unitval
  | otherwise = error()
  where
    validatorOrPolicy :: BuiltinPair BuiltinInteger (BuiltinList BuiltinData) -> Bool
    validatorOrPolicy scrInfoBd
      | BI.fst scrInfoBd == 0 = mkMintingScript params (getIndexData $ lazyTxInfoReferenceInputsBd ctx') (lazyRedeemerTyped ctx') (BI.head $ BI.snd scrInfoBd) (lazyTxInfoMintBd ctx') (lazyTxInfoInputsBd ctx') (lazyTxInfoOutputsBd ctx') (lazyTxInfoWdrlBd ctx')
      | BI.fst scrInfoBd == 1 = mkSpendingValidator (findLazyTxInInfoByTxOutRefToAddrPkhBd (lazyTxInfoInputsBd ctx') (BI.head $ BI.snd scrInfoBd)) (lazyTxInfoRedeemersBd ctx') 0
      | BI.fst scrInfoBd == 2 = mkUnlockAdaObserver params (getIndexData $ lazyTxInfoReferenceInputsBd ctx')  (BI.unsafeDataAsB $ BI.head $ constrArgs $ BI.head $ BI.snd scrInfoBd) (lazyTxInfoOutputsBd ctx') (lazyTxInfoInputsBd ctx')
      | BI.fst scrInfoBd == 3 = True
      | otherwise = error ()

    getIndexData :: BuiltinList BuiltinData -> IndexData
    getIndexData txIns = unsafeFromBuiltinData $ findLazyTxInInfoBySingleTokenToInlineDatBd txIns (referenceIndexCs params) indexScriptsOnChainNameBd

indexValidatorCompiledCode :: CompiledCode (BuiltinData -> BuiltinData -> BuiltinUnit)
indexValidatorCompiledCode = $$(PlutusTx.compile [||\params -> untypedValidator (unsafeFromBuiltinData params)||])