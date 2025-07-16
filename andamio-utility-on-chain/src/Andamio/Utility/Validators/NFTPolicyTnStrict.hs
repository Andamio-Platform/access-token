module Andamio.Utility.Validators.NFTPolicyTnStrict
                        ( nftPolicyTnStrictSerialised
                        , NFTStrictTnParams(..)
                        ) where

import           GHC.Generics               (Generic)
import qualified Prelude            as Pr   (Show, Ord, Eq(..), error, Either(..))

import           PlutusCore.Version         (plcVersion110)
import           PlutusTx                   (makeLift, CompiledCode, applyCode, compile, liftCode)
import           PlutusTx.AssocMap  as Map  (toList, Map)   
import           PlutusTx.Prelude           (Bool(..), Integer, (&&), ($), error, (==), otherwise)
import           PlutusLedgerApi.V3         (TxOutRef(..), TokenName(..), TokenName(..), 
                                            Value(..), CurrencySymbol(..), toBuiltinData,
                                            SerialisedScript, serialiseCompiledCode)
import           PlutusTx.Builtins.Internal (BuiltinList, BuiltinUnit, BuiltinData)

import           Andamio.Utility.LazyContextV3 (lazyTxInfoMint, lazyTxInfoInputsBd, 
                                               unitval, lazyOwnCurrencySymbol)
import           Andamio.Utility.TxInInfo      (lazyTxInInfoConsumedBd)

-- Mint a NFT where also the name is part of the policy id.
-- Other minting policies allowed

data NFTStrictTnParams = NFTStrictTnParams 
      { nstpTxRef :: TxOutRef
      , tn        :: TokenName
      } deriving stock (Pr.Eq, Pr.Ord, Pr.Show, Generic)

PlutusTx.makeLift ''NFTStrictTnParams

{-# INLINEABLE mkPolicy #-}
mkPolicy :: NFTStrictTnParams -> Value -> BuiltinList BuiltinData -> CurrencySymbol -> Bool
mkPolicy NFTStrictTnParams{..} txInfoMint txInfoInputsBd ownSymbol = 
                                                                lazyTxInInfoConsumedBd txInfoInputsBd (toBuiltinData nstpTxRef) &&
                                                                checkMinting (Map.toList $ getValue txInfoMint)
  where

    checkMinting :: [(CurrencySymbol, Map.Map TokenName Integer)] -> Bool
    checkMinting [] = error ()
    checkMinting ((cs', tnAm):xs) = if cs' == ownSymbol
                                    then go (Map.toList tnAm)
                                    else checkMinting xs
      where              
        go :: [(TokenName, Integer)] -> Bool
        go [(tn', am)] = tn' == tn && am == 1
        go _ = error ()

{-# INLINEABLE untypedPolicy #-}
untypedPolicy :: NFTStrictTnParams -> BuiltinData -> BuiltinUnit
untypedPolicy params ctx' 
  | mkPolicy params (lazyTxInfoMint ctx') (lazyTxInfoInputsBd ctx') (lazyOwnCurrencySymbol ctx') = unitval
  | otherwise = error ()

nftPolicyTnStrictCompiledCode :: NFTStrictTnParams -> CompiledCode (BuiltinData -> BuiltinUnit)
nftPolicyTnStrictCompiledCode params = case compiled of
    Pr.Right c -> c
    Pr.Left _ -> Pr.error "nftPolicyTnStrictCompiledCode"
    where
        compiled = $$(compile [||untypedPolicy||]) `applyCode` liftCode plcVersion110 params

nftPolicyTnStrictSerialised :: NFTStrictTnParams -> SerialisedScript
nftPolicyTnStrictSerialised nstp = serialiseCompiledCode $ nftPolicyTnStrictCompiledCode nstp