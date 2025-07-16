module Tests.TxInInfo (tests) where

import Prelude
import Test.Tasty                          (testGroup, TestTree)
import PlutusTx
import PlutusTx.Builtins.Internal          (unsafeDataAsList)
import PlutusLedgerApi.V3         as V3
import PlutusLedgerApi.V1.Value   as Value (singleton)
import Test.Tasty.HUnit                    (testCaseSteps, assertBool)
import PlutusTx.Prelude                    (blake2b_224)

import Andamio.Utility.TxInInfo
import Andamio.Utility.Test

tests :: TestTree
tests = testGroup "TxInInfo" 
              [ testCaseSteps "lazyTxInInfoTxOutRefBd" $ \_ -> do

                  assertBool "lazyTxInInfoTxOutRefBd" (lazyTxInInfoTxOutRefBd (createTxInInfoBd "1") == toBuiltinData (createTxOutRef "1")),
                
                testCaseSteps "lazyTxInInfoTxOutAddrBd" $ \_ -> do

                  assertBool "lazyTxInInfoTxOutAddrBd" (lazyTxInInfoTxOutAddrBd (createTxInInfoBd "1") == toBuiltinData (createAddress "1")),
                
                testCaseSteps "lazyTxInInfoValue" $ \_ -> do

                  assertBool "lazyTxInInfoValue" (lazyTxInInfoValue (createTxInInfoBd "1") == Value.singleton (createCs "1") (TokenName "1") 1),
                
                testCaseSteps "lazyTxInInfoTxOutOutDatBd" $ \_ -> do

                  assertBool "lazyTxInInfoTxOutOutDatBd" (lazyTxInInfoTxOutOutDatBd (createTxInInfoBd "1") == toBuiltinData (OutputDatum $ Datum $ toBuiltinData ("1" :: BuiltinByteString))),
                
                testCaseSteps "lazyTxInInfoTxOutInlineDatBd" $ \_ -> do

                  assertBool "lazyTxInInfoTxOutInlineDatBd" (lazyTxInInfoTxOutInlineDatBd (createTxInInfoBd "1") == toBuiltinData ("1" :: BuiltinByteString)),
                
                testCaseSteps "lazyTxInInfoTxOutOutReferenceScriptBd" $ \_ -> do

                  assertBool "lazyTxInInfoTxOutOutReferenceScriptBd" (lazyTxInInfoTxOutOutReferenceScriptBd (createTxInInfoBd "1") == toBuiltinData (Just $ blake2b_224 "1")),
                                
                testCaseSteps "csInTxInInfosBd" $ \_ -> do

                  let sampleTxInInfos = unsafeDataAsList $ toBuiltinData [createTxInInfo "0", createTxInInfo "1", createTxInInfo "2"]

                  assertBool "csInTxInInfosBd" (csInTxInInfosBd sampleTxInInfos (toBuiltinData $ createCs "1") && csInTxInInfosBd sampleTxInInfos (toBuiltinData $ createCs "4") == False),
              --  
                testCaseSteps "findLazyTxInInfoByTxOutRefToTxOutBd" $ \_ -> do

                  let txInInfos = unsafeDataAsList $ toBuiltinData [createTxInInfo "1", createTxInInfo "2", createTxInInfo "3"]

                  assertBool "findLazyTxInInfoByTxOutRefToTxOutBd" (findLazyTxInInfoByTxOutRefToTxOutBd txInInfos (toBuiltinData $ TxOutRef (TxId $ blake2b_224 "1") 0) == toBuiltinData (createTxOut "1")),
                
                testCaseSteps "findLazyTxInInfoByTxOutRefToAddrPkhBd" $ \_ -> do

                  let txInInfos = unsafeDataAsList $ toBuiltinData [createTxInInfo "1", createTxInInfo "2", createTxInInfo "3"]

                  assertBool "findLazyTxInInfoByTxOutRefToAddrPkhBd" (findLazyTxInInfoByTxOutRefToAddrPkhBd txInInfos (toBuiltinData $ TxOutRef (TxId $ blake2b_224 "1") 0) == toBuiltinData (ScriptHash $ blake2b_224 "1")),
                
                testCaseSteps "lazyTxInInfoConsumedBd" $ \_ -> do

                  let txInInfos = unsafeDataAsList $ toBuiltinData [createTxInInfo "1", createTxInInfo "2", createTxInInfo "3"]

                  assertBool "lazyTxInInfoConsumedBd" (lazyTxInInfoConsumedBd txInInfos (toBuiltinData $ TxOutRef (TxId $ blake2b_224 "2") 0)),
                
                testCaseSteps "findLazyTxInInfoByTxOutAddrToTxOutBd" $ \_ -> do

                  let txInInfos = unsafeDataAsList $ toBuiltinData [createTxInInfo "1", createTxInInfo "2", createTxInInfo "3"]

                  assertBool "findLazyTxInInfoByTxOutAddrToTxOutBd" (findLazyTxInInfoByTxOutAddrToTxOutBd txInInfos (toBuiltinData (createAddress "3")) == toBuiltinData (createTxOut "3")),
                
                testCaseSteps "findLazyTxInInfoBySingleTokenToTxOutBd" $ \_ -> do

                  let txInInfos = unsafeDataAsList $ toBuiltinData [createTxInInfo "1", createTxInInfo "2", createTxInInfo "3"]

                  assertBool "findLazyTxInInfoBySingleTokenToTxOutBd" (findLazyTxInInfoBySingleTokenToTxOutBd txInInfos (toBuiltinData $ createCs "2") (toBuiltinData $ TokenName "2") == toBuiltinData (createTxOut "2")),

                testCaseSteps "findLazyTxInInfoBySingleTokenToAddrBd" $ \_ -> do

                  let txInInfos = unsafeDataAsList $ toBuiltinData [createTxInInfo "1", createTxInInfo "2", createTxInInfo "3"]

                  assertBool "findLazyTxInInfoBySingleTokenToAddrBd" (findLazyTxInInfoBySingleTokenToAddrBd txInInfos (toBuiltinData $ createCs "2") (toBuiltinData $ TokenName "2") == toBuiltinData (createAddress "2")),

                testCaseSteps "findLazyTxInInfoBySingleTokenToInlineDatBd" $ \_ -> do

                  let txInInfos = unsafeDataAsList $ toBuiltinData [createTxInInfo "1", createTxInInfo "2", createTxInInfo "3"]

                  assertBool "findLazyTxInInfoBySingleTokenToInlineDatBd" (findLazyTxInInfoBySingleTokenToInlineDatBd txInInfos (toBuiltinData $ createCs "2") (toBuiltinData $ TokenName "2") == toBuiltinData ("2" :: BuiltinByteString)),

                testCaseSteps "singleTokenInOutAddrSame" $ \_ -> do

                  let txInInfos = unsafeDataAsList $ toBuiltinData [createTxInInfo "1", createTxInInfo "2", createTxInInfo "3"]
                      txOuts = unsafeDataAsList $ toBuiltinData [createTxOut "1", createTxOut "2", createTxOut "3"]

                  assertBool "singleTokenInOutAddrSame" (singleTokenInOutAddrSame txInInfos txOuts (toBuiltinData $ createCs "2") (toBuiltinData $ TokenName "2"))
                
              ]