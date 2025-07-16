module Tests.Datum (tests) where

import Prelude
import Test.Tasty                       (testGroup, TestTree)
import PlutusTx
import PlutusTx.Builtins.Internal as BI
import PlutusLedgerApi.V3         as V3
import Test.Tasty.HUnit                 (testCaseSteps, assertBool)
import Andamio.Utility.Datum

tests :: TestTree
tests = testGroup "Datum" 
              [ testCaseSteps "getTxOutInlineDatumTyped" $ \_ -> do

                  let str = "string"
                      outDat = OutputDatum $ Datum $ toBuiltinData str                  

                  assertBool "getTxOutInlineDatumTyped" (str == getTxOutInlineDatumTyped @BuiltinByteString outDat),
                
                testCaseSteps "mkInlineDatumBuiltin" $ \_ -> do

                  let str = "string" :: BuiltinByteString
                      outDat = mkInlineDatumBuiltin $ toBuiltinData str
                      outDatBd = OutputDatum $ Datum $ toBuiltinData str
                  
                  assertBool "mkInlineDatumBuiltin" (unsafeFromBuiltinData @OutputDatum outDat == outDatBd),
                
                testCaseSteps "nothingBd" $ \_ -> do

                  let nothingSHBd = nothingBd
                      nothingSH = Nothing :: Maybe ScriptHash
                  
                  assertBool "nothingBd" (unsafeFromBuiltinData @(Maybe ScriptHash) nothingSHBd == nothingSH)
              ]