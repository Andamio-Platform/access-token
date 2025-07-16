module Andamio.Utility.Validators.TokenNamePolicy
                        ( tokenNamePolicySerialised
                        ) where

import qualified Prelude            as Pr   (error, Either(..))

import           PlutusCore.Version         (plcVersion110)
import           PlutusTx                   (CompiledCode, applyCode, compile, liftCode)
import           PlutusTx.AssocMap  as Map  (toList, Map)   
import           PlutusTx.Prelude           (Bool(..), Integer, ($), error, (==), otherwise)
import           PlutusLedgerApi.V3         (TokenName(..), TokenName(..), SerialisedScript,
                                            Value(..), CurrencySymbol(..), serialiseCompiledCode)
import           PlutusTx.Builtins.Internal (BuiltinUnit, BuiltinData)

import           Andamio.Utility.LazyContextV3 (lazyTxInfoMint, unitval, lazyOwnCurrencySymbol)

-- Mint a token parameterized by token name.
-- Other minting policies allowed

{-# INLINEABLE mkPolicy #-}
mkPolicy :: TokenName -> Value -> CurrencySymbol -> Bool
mkPolicy tn txInfoMint ownSymbol = 
              
              checkMinting (Map.toList $ getValue txInfoMint)
  
  where

    checkMinting :: [(CurrencySymbol, Map.Map TokenName Integer)] -> Bool
    checkMinting [] = error ()
    checkMinting ((cs', tnAm):xs) = if cs' == ownSymbol
                                    then go (Map.toList tnAm)
                                    else checkMinting xs
      where              
        go :: [(TokenName, Integer)] -> Bool
        go [(tn', _)] = tn' == tn
        go _ = error ()

{-# INLINEABLE untypedPolicy #-}
untypedPolicy :: TokenName -> BuiltinData -> BuiltinUnit
untypedPolicy tn ctx' 
  | mkPolicy tn (lazyTxInfoMint ctx') (lazyOwnCurrencySymbol ctx') = unitval
  | otherwise = error ()

tokenNamePolicyCompiledCode :: TokenName -> CompiledCode (BuiltinData -> BuiltinUnit)
tokenNamePolicyCompiledCode tn = case compiled of
    Pr.Right c -> c
    Pr.Left _ -> Pr.error "tokenNamePolicyCompiledCode"
    where
        compiled = $$(compile [||untypedPolicy||]) `applyCode` liftCode plcVersion110 tn

tokenNamePolicySerialised :: TokenName -> SerialisedScript
tokenNamePolicySerialised tn = serialiseCompiledCode $ tokenNamePolicyCompiledCode tn