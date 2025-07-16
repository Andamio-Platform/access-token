module Tests.TxOut (tests) where

import Prelude
import           Test.Tasty             (testGroup, TestTree)
import PlutusTx
import PlutusTx.Builtins.Internal       (unsafeDataAsList)
import PlutusLedgerApi.V3         as V3
import Test.Tasty.HUnit                 (testCaseSteps, assertBool)
import PlutusTx.Prelude                 (blake2b_224)

import Andamio.Utility.TxOut
import Andamio.Utility.Test

tests :: TestTree
tests = testGroup "TxOut" 
              [ testCaseSteps "lazyTxOutAddrBd" $ \_ -> do

                  let txOut = toBuiltinData $ createTxOut "1"

                  assertBool "lazyTxOutAddrBd" (lazyTxOutAddrBd txOut == toBuiltinData (createAddress "1")),
                
                testCaseSteps "lazyTxOutValue" $ \_ -> do

                  let txOut = toBuiltinData $ createTxOut "1"

                  assertBool "lazyTxOutValue" (lazyTxOutValue txOut == createValue "1"),

                testCaseSteps "lazyTxOutInlineDatBd" $ \_ -> do

                  let txOut = toBuiltinData $ createTxOut "1"

                  assertBool "lazyTxOutInlineDatBd" (lazyTxOutInlineDatBd txOut == toBuiltinData ("1" :: BuiltinByteString)),
                
                testCaseSteps "lazyTxOutReferenceScriptBd" $ \_ -> do

                  let txOut = toBuiltinData $ createTxOut "1"

                  assertBool "lazyTxOutReferenceScriptBd" (lazyTxOutReferenceScriptBd txOut == toBuiltinData (Just $ ScriptHash $ blake2b_224 "1")),
                
                testCaseSteps "csInTxOutsBd" $ \_ -> do

                  let txOuts = unsafeDataAsList $ toBuiltinData [createTxOut "1", createTxOut "2", createTxOut "3"]

                  assertBool "csInTxOutsBd" (csInTxOutsBd txOuts (toBuiltinData $ blake2b_224 "2") && csInTxOutsBd txOuts (toBuiltinData $ blake2b_224 "4") == False),
                
                testCaseSteps "findLazyTxOutByCs" $ \_ -> do

                  let txOuts = unsafeDataAsList $ toBuiltinData [createTxOut "1", createTxOut "2", createTxOut "3"]

                  assertBool "findLazyTxOutByCs" (findLazyTxOutByCs txOuts (toBuiltinData $ blake2b_224 "3") == toBuiltinData (createTxOut "3")),

                testCaseSteps "findLazyTxOutByAddr" $ \_ -> do

                  let txOuts = unsafeDataAsList $ toBuiltinData [createTxOut "1", createTxOut "2", createTxOut "3"]

                  assertBool "findLazyTxOutByAddr" (findLazyTxOutByAddr txOuts (toBuiltinData $ createAddress "1") == toBuiltinData (createTxOut "1")),
              
                testCaseSteps "findLazyTxOutBySingleTokenToAddrBd" $ \_ -> do

                  let txOuts = unsafeDataAsList $ toBuiltinData [createTxOut "1", createTxOut "2", createTxOut "3"]

                  assertBool "findLazyTxOutBySingleTokenToAddrBd" (findLazyTxOutBySingleTokenToAddrBd txOuts (toBuiltinData $ blake2b_224 "3") (toBuiltinData $ TokenName "3") == toBuiltinData (createAddress "3"))
              ]