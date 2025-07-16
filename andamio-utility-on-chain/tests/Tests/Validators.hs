module Tests.Validators (tests) where

import Prelude
import Test.Tasty                        (testGroup, TestTree)
import PlutusLedgerApi.V3       as V3
import PlutusLedgerApi.V1.Value as Value (singleton)
import Test.Tasty.HUnit                  (testCaseSteps, assertBool)

import Andamio.Utility.Validators.NFTPolicyTnStrict (nftPolicyTnStrictSerialised, NFTStrictTnParams(..))
import Andamio.Utility.Validators.TokenNamePolicy   (tokenNamePolicySerialised)
import Andamio.Utility.Test

tests :: TestTree
tests = testGroup "Validators" 
              [ testCaseSteps "NFTPolicyTnStrict: True" $ \info -> do

                  let tn = TokenName "Test1"
                      txRef = TxOutRef "6c46dd437a3d43ac556795fbc4e92f914dee2aaa67d7b2de1f0aeaf8158f98c7" 0
                      strictTnPolicy = nftPolicyTnStrictSerialised $ NFTStrictTnParams txRef tn
                      strictTnPolicyCs = serialisedToCurrencySymbol strictTnPolicy
                      mintValue = Value.singleton strictTnPolicyCs tn 1
                      
                  let initOutcome = evaluateScriptCounting' strictTnPolicy (createScriptContextBd' (emptyTxInfo{txInfoInputs=[TxInInfo txRef emptyTxOut], txInfoMint=mintValue}) unitRedeemer (MintingScript strictTnPolicyCs))
                  info (show $ unsafeFromRight initOutcome)

                  assertBool "init index token minted" (isRight initOutcome),
                
                testCaseSteps "NFTPolicyTnStrict: False" $ \info -> do

                  let tn = TokenName "Test1"
                      txRef = TxOutRef "6c46dd437a3d43ac556795fbc4e92f914dee2aaa67d7b2de1f0aeaf8158f98c7" 0
                      strictTnPolicy = nftPolicyTnStrictSerialised $ NFTStrictTnParams txRef tn
                      strictTnPolicyCs = serialisedToCurrencySymbol strictTnPolicy
                      mintValue = Value.singleton strictTnPolicyCs tn 1
                               <> Value.singleton strictTnPolicyCs (TokenName "Test2") 1

                  let initOutcome = evaluateScriptCounting' strictTnPolicy (createScriptContextBd' (emptyTxInfo{txInfoInputs=[TxInInfo txRef emptyTxOut], txInfoMint=mintValue}) unitRedeemer (MintingScript strictTnPolicyCs))
                  info (show $ unsafeFromLeft initOutcome)

                  assertBool "init index token minted" (isLeft initOutcome),
                
                testCaseSteps "TokenNamePolicy: True" $ \info -> do

                  let tn = TokenName "Test1"
                      tnPolicy = tokenNamePolicySerialised tn
                      tnPolicyCs = serialisedToCurrencySymbol tnPolicy
                      mintValue = Value.singleton tnPolicyCs tn 100
                      
                  let initOutcome = evaluateScriptCounting' tnPolicy (createScriptContextBd' (emptyTxInfo{txInfoMint=mintValue}) unitRedeemer (MintingScript tnPolicyCs))
                  info (show $ unsafeFromRight initOutcome)

                  assertBool "init index token minted" (isRight initOutcome),
                
                testCaseSteps "TokenNamePolicy: False" $ \info -> do

                  let tn = TokenName "Test1"
                      tnPolicy = tokenNamePolicySerialised tn
                      tnPolicyCs = serialisedToCurrencySymbol tnPolicy
                      mintValue = Value.singleton tnPolicyCs tn 100
                               <> Value.singleton tnPolicyCs (TokenName "Test2") 100

                  let initOutcome = evaluateScriptCounting' tnPolicy (createScriptContextBd' (emptyTxInfo{txInfoMint=mintValue}) unitRedeemer (MintingScript tnPolicyCs))
                  info (show $ unsafeFromLeft initOutcome)

                  assertBool "init index token minted" (isLeft initOutcome)
              ]