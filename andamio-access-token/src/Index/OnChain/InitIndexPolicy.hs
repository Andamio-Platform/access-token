module Index.OnChain.InitIndexPolicy 
                    ( initIndexPolicyCompiledCode
                    ) where

import           PlutusTx                          (compile, CompiledCode)
import           PlutusTx.Prelude                  (BuiltinUnit, BuiltinData, Bool(..), error, 
                                                   otherwise, (==), (&&), ($))
import qualified PlutusTx.Builtins.Internal  as BI (unsafeDataAsMap, fst, snd, head, tail, mkI)
import           PlutusTx.Builtins.Internal        (BuiltinList, BuiltinPair)
import           PlutusTx.Builtins           as B  (null)

import           Andamio.Utility.OnChain           (lazyTxInfoMintBd, lazyOwnCurrencySymbolBd, lazyTxInfoInputsBd, 
                                                   lazyTxInInfoConsumedBd, indexTokenNameBd, unitval, lengthListTupleBd)

{-
Minting Validator
Minting boarder tokens for linked list (Index Scripts).
- exactly 2 tokens
-}

{-# INLINEABLE mkPolicy #-}
mkPolicy :: BuiltinData -> BuiltinData -> BuiltinData -> BuiltinList BuiltinData -> Bool
mkPolicy txrefBd txInfoMintBd ownSymbolBd txInfoInputsBd = 
  
        lazyTxInInfoConsumedBd txInfoInputsBd txrefBd &&
        checkMinting (BI.unsafeDataAsMap txInfoMintBd)

  where

    checkMinting :: BuiltinList (BuiltinPair BuiltinData BuiltinData) -> Bool
    checkMinting bdTupleList
      | B.null bdTupleList = error ()
      | BI.fst (BI.head bdTupleList) == ownSymbolBd = go (BI.unsafeDataAsMap $ BI.snd $ BI.head bdTupleList)
      | otherwise = checkMinting (BI.tail bdTupleList)
      where
        go :: BuiltinList (BuiltinPair BuiltinData BuiltinData) -> Bool
        go bdTupleList' = lengthListTupleBd bdTupleList' 0 == 1 &&
                          BI.fst (BI.head bdTupleList') == indexTokenNameBd &&
                          BI.snd (BI.head bdTupleList') == BI.mkI 2

{-# INLINEABLE untypedPolicy #-}
untypedPolicy :: BuiltinData -> BuiltinData -> BuiltinUnit
untypedPolicy txref ctx'
  | mkPolicy txref (lazyTxInfoMintBd ctx') (lazyOwnCurrencySymbolBd ctx') (lazyTxInfoInputsBd ctx') = unitval
  | otherwise = error ()

initIndexPolicyCompiledCode :: CompiledCode (BuiltinData -> BuiltinData -> BuiltinUnit)
initIndexPolicyCompiledCode = $$(PlutusTx.compile [||\params -> untypedPolicy params||])