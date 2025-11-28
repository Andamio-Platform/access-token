module Tests.Value (tests) where

import Prelude
import Test.Tasty                        (testGroup, TestTree)
import PlutusTx
import PlutusTx.Builtins.Internal        (unsafeDataAsMap)
import PlutusLedgerApi.V3         as V3
import PlutusTx.AssocMap          as Map
import Test.Tasty.HUnit                  (testCaseSteps, assertBool)
import PlutusTx.Prelude                  (blake2b_224)

import Andamio.Utility.Value
import Andamio.Utility.Test
import Andamio.Utility.ValidatorOnChainNames (adaSymbolBd, adaTokenBd)

tests :: TestTree
tests = testGroup "Value" 
              [ testCaseSteps "tnElemList" $ \_ -> do

                  let tns = map TokenName ["1", "2", "3"]

                  assertBool "tnElemList" (tnElemList tns (TokenName "3") && tnElemList tns (TokenName "4") == False),
                
                testCaseSteps "csElemList" $ \_ -> do

                  let css = map createCs ["1", "2", "3"]

                  assertBool "csElemList" (csElemList css (createCs "3") && csElemList css (createCs "4") == False),
                
                testCaseSteps "checkMinting" $ \_ -> do

                  let tnAmBdMap = unsafeDataAsMap $ toBuiltinData $ Map.singleton (TokenName "bbs") (1 :: Integer)

                  assertBool "checkMinting" (checkMinting tnAmBdMap "bbs" 1 && checkMinting tnAmBdMap "bbs" 2 == False),

                testCaseSteps "lookupIsOne" $ \_ -> do

                  let tnAmBdMap = unsafeDataAsMap $ toBuiltinData $ Map.singleton (TokenName "bbs") (1 :: Integer)

                  assertBool "lookupIsOne" (lookupIsOne tnAmBdMap (toBuiltinData $ TokenName "bbs") 1 && lookupIsOne tnAmBdMap (toBuiltinData $ TokenName "bbs") 2 == False),
                
                testCaseSteps "tnAmBdMapByCsFromValueBd" $ \_ -> do

                  let tnAmBdMap = unsafeDataAsMap $ toBuiltinData $ mconcat $ map createValue ["1", "2", "3", "4"]

                  assertBool "tnAmBdMapByCsFromValueBd" (tnAmBdMapByCsFromValueBd tnAmBdMap (toBuiltinData $ createCs "3") == unsafeDataAsMap (toBuiltinData $ Map.singleton (TokenName "3") (1 :: Integer))),
                
                testCaseSteps "builtinsElemMapBd" $ \_ -> do

                  let tnAmBdMap = unsafeDataAsMap $ toBuiltinData $ Map.singleton (TokenName "bbs") (2 :: Integer)

                  assertBool "builtinsElemMapBd" (builtinsElemMapBd tnAmBdMap (toBuiltinData $ TokenName "bbs") (toBuiltinData (2 :: Integer))),

                testCaseSteps "tupleElemOnlyOne" $ \_ -> do

                  let tnAmBdMap = unsafeDataAsMap $ toBuiltinData $ mconcat $ map createValue ["1", "2", "3", "4"]

                  assertBool "tupleElemOnlyOne" (tupleElemOnlyOne tnAmBdMap 0 == 4),

                testCaseSteps "lengthListTupleBd" $ \_ -> do

                  let tnAmBdMap = unsafeDataAsMap $ toBuiltinData $ mconcat $ map createValue ["1", "2", "3", "4"]

                  assertBool "lengthListTupleBd" (lengthListTupleBd tnAmBdMap 0 == 4),

                testCaseSteps "csElem" $ \_ -> do

                  let css = unsafeDataAsMap $ toBuiltinData $ mconcat $ map createValue ["1", "2", "3", "4"]

                  assertBool "csElem" (csElem css (toBuiltinData $ createCs "3")),

                testCaseSteps "valueOfBd" $ \_ -> do

                  let tnAmBdMap = unsafeDataAsMap $ toBuiltinData $ mconcat $ map createValue ["1", "2", "3", "4"]

                  assertBool "valueOfBd" (valueOfBd tnAmBdMap (toBuiltinData $ blake2b_224 "1") (toBuiltinData $ TokenName "1") == 1),

                testCaseSteps "singleTokenInValueBd" $ \_ -> do

                  let tnAmBdMap = unsafeDataAsMap $ toBuiltinData $ mconcat $ map createValue ["1", "2", "3", "4"]

                  assertBool "singleTokenInValueBd" (singleTokenInValueBd tnAmBdMap (toBuiltinData $ createCs "1") (toBuiltinData $ TokenName "1") && singleTokenInValueBd tnAmBdMap (toBuiltinData $ createCs "1") (toBuiltinData $ TokenName "5") == False),

                testCaseSteps "flatValuePaidBd" $ \_ -> do

                  let tnAmBdMap = unsafeDataAsMap $ toBuiltinData $ mconcat $ map createValue ["1", "2", "3", "4"]
                      flatVal = [FlatValue (createCs "2") (TokenName "2") 1]

                  assertBool "flatValuePaidBd" (flatValuePaidBd flatVal tnAmBdMap),

                testCaseSteps "flatValLength" $ \_ -> do

                  let flatVal = [FlatValue (createCs "2") (TokenName "2") 2, FlatValue (createCs "3") (TokenName "3") 3]

                  assertBool "flatValLength" (flatValLength flatVal 0 == 2),

                testCaseSteps "flatValueToValue" $ \_ -> do

                  let val = mconcat $ map createValue ["2", "3"]
                      flatVal = [FlatValue (createCs "2") (TokenName "2") 1, FlatValue (createCs "3") (TokenName "3") 1]

                  assertBool "flatValueToValue" (flatValueToValue flatVal (Value Map.empty) == val),
                
                testCaseSteps "Match ADA AssetClass" $ \_ -> do
  
                  let correctSymbol = V3.unsafeFromBuiltinData adaSymbolBd == V3.adaSymbol
                  let correctName = V3.unsafeFromBuiltinData adaTokenBd == V3.adaToken

                  assertBool "Unmatched ADA Symbol" correctSymbol
                  assertBool "Unmatched ADA Name" correctName
              ]