module Index.OnChain.IndexScripts.SpendingScript
                    ( mkSpendingValidator
                    ) where


import PlutusTx.Prelude                 (BuiltinData, Integer, Bool(..),
                                        (==), (+), ($), otherwise)
import PlutusTx.Builtins.Internal as BI (head, tail, BuiltinList(..), BuiltinPair(..), 
                                        mkConstr, mkCons, fst)
import PlutusTx.Builtins          as B  (null)
import PlutusTx.Builtins.HasOpaque      (mkNil)

{-
Spending Validator
Validate for exactly one other index Purpose, either Withdrawl or Minting.
-}

{-# INLINEABLE mkSpendingValidator #-}
mkSpendingValidator :: BuiltinData -> BuiltinList (BuiltinPair BuiltinData BuiltinData) -> Integer -> Bool
mkSpendingValidator ownBbs txInfoRedeemersBd counter
      | B.null txInfoRedeemersBd = counter == 1
      | BI.fst (BI.head txInfoRedeemersBd) == BI.mkConstr 0 (BI.mkCons ownBbs mkNil) = mkSpendingValidator ownBbs (BI.tail txInfoRedeemersBd) (counter + 1)
      | BI.fst (BI.head txInfoRedeemersBd) == BI.mkConstr 2 (BI.mkCons (BI.mkConstr 1 $ BI.mkCons ownBbs mkNil) mkNil) = mkSpendingValidator ownBbs (BI.tail txInfoRedeemersBd) (counter + 1)
      | otherwise = mkSpendingValidator ownBbs (BI.tail txInfoRedeemersBd) counter