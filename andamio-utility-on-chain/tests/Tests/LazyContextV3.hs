module Tests.LazyContextV3 (tests) where

import Prelude
import           Test.Tasty                       (testGroup, TestTree)
import PlutusTx
import PlutusTx.AssocMap as Map
import PlutusLedgerApi.V3 as V3
import PlutusLedgerApi.V1.Value as Value (singleton)
import Test.Tasty.HUnit (testCaseSteps, assertBool)
import PlutusTx.Prelude         (blake2b_224)

import Andamio.Utility.LazyContextV3
import Andamio.Utility.Test

tests :: TestTree
tests = testGroup "LazyContextV3" 
              [ testCaseSteps "lazyRedeemerTyped" $ \_ -> do

                  assertBool "lazyRedeemerTyped" (lazyRedeemerTyped @BuiltinByteString (createScriptContextBd "1") == "1"),
                
                testCaseSteps "lazyScriptInfo" $ \_ -> do
                  
                  assertBool "lazyScriptInfo" (lazyScriptInfo (createScriptContextBd "1") == MintingScript (createCs "1")),
                
                testCaseSteps "lazyInlineDatumTyped" $ \_ -> do

                  let sampleScriptContext = createScriptContext "1"
                  
                  assertBool "lazyInlineDatumTyped" (lazyInlineDatumTyped @Integer (toBuiltinData sampleScriptContext{scriptContextScriptInfo=SpendingScript (TxOutRef "6c46dd437a3d43ac556795fbc4e92f914dee2aaa67d7b2de1f0aeaf8158f98c7" 0) (Just $ Datum $ toBuiltinData (1 :: Integer))}) == 1),
                
                testCaseSteps "lazyTxOutRef" $ \_ -> do

                  let sampleScriptContext = createScriptContext "1"

                  assertBool "lazyTxOutRef" (lazyTxOutRef (toBuiltinData sampleScriptContext{scriptContextScriptInfo=SpendingScript (TxOutRef "6c46dd437a3d43ac556795fbc4e92f914dee2aaa67d7b2de1f0aeaf8158f98c7" 0) Nothing}) == TxOutRef "6c46dd437a3d43ac556795fbc4e92f914dee2aaa67d7b2de1f0aeaf8158f98c7" 0),

                testCaseSteps "lazyOwnCurrencySymbol" $ \_ -> do

                  assertBool "lazyOwnCurrencySymbol" (lazyOwnCurrencySymbol (createScriptContextBd "1") == createCs "1"),
              
                testCaseSteps "lazyTxInfoInputs" $ \_ -> do

                  assertBool "lazyTxInfoInputs" (lazyTxInfoInputs (createScriptContextBd "1") == [createTxInInfo "1"]),
                
                testCaseSteps "lazyTxInfoReferenceInputs" $ \_ -> do

                  assertBool "lazyTxInfoReferenceInputs" (lazyTxInfoReferenceInputs (createScriptContextBd "1") == [createTxInInfo "1"]),
                
                testCaseSteps "lazyTxInfoOutputs" $ \_ -> do

                  assertBool "lazyTxInfoOutputs" (lazyTxInfoOutputs (createScriptContextBd "1") == [createTxOut "1"]),

                testCaseSteps "lazyTxInfoFee" $ \_ -> do

                  assertBool "lazyTxInfoFee" (lazyTxInfoFee (createScriptContextBd "1") == 1),
                
                testCaseSteps "lazyTxInfoMint" $ \_ -> do

                  assertBool "lazyTxInfoMint" (lazyTxInfoMint (createScriptContextBd "1") == Value.singleton (createCs "1") (TokenName "1") 2),
              
                testCaseSteps "lazyTxInfoTxCerts" $ \_ -> do

                  assertBool "lazyTxInfoTxCerts" (lazyTxInfoTxCerts (createScriptContextBd "1") == [TxCertRegStaking (createScriptCredential "1") Nothing]),
                
                testCaseSteps "lazyTxInfoWdrl" $ \_ -> do

                  assertBool "lazyTxInfoWdrl" (lazyTxInfoWdrl (createScriptContextBd "1") == Map.singleton (createScriptCredential "1") 3),
                
                testCaseSteps "lazyTxInfoValidRange" $ \_ -> do

                  assertBool "lazyTxInfoValidRange" (lazyTxInfoValidRange (createScriptContextBd "1") == always),
                
                testCaseSteps "lazyTxInfoSignatories" $ \_ -> do

                  assertBool "lazyTxInfoSignatories" (lazyTxInfoSignatories (createScriptContextBd "1") == [PubKeyHash $ blake2b_224 "1"]),
                
                testCaseSteps "lazyTxInfoRedeemers" $ \_ -> do

                  assertBool "lazyTxInfoRedeemers" (lazyTxInfoRedeemers (createScriptContextBd "1") == Map.singleton (Minting (createCs "1")) (Redeemer $ toBuiltinData ("1" :: BuiltinByteString))),
                
                testCaseSteps "lazyTxInfoData" $ \_ -> do

                  assertBool "lazyTxInfoData" (lazyTxInfoData (createScriptContextBd "1") == Map.singleton (DatumHash $ blake2b_224 "1") (Datum $ toBuiltinData ("1" :: BuiltinByteString))),

                testCaseSteps "lazyTxInfoId" $ \_ -> do

                  assertBool "lazyTxInfoId" (lazyTxInfoId (createScriptContextBd "1") == TxId (blake2b_224 "1")),
                
                testCaseSteps "lazyTxInfoVotes" $ \_ -> do

                  assertBool "lazyTxInfoVotes" (lazyTxInfoVotes (createScriptContextBd "1") == Map.singleton (DRepVoter $ DRepCredential $ createScriptCredential "1") (Map.singleton (GovernanceActionId (TxId $ blake2b_224 "1") 0) VoteNo)),      
              
                testCaseSteps "lazyTxInfoProposalProcedures" $ \_ -> do

                  assertBool "lazyTxInfoProposalProcedures" (lazyTxInfoProposalProcedures (createScriptContextBd "1") == [ProposalProcedure 1 (createScriptCredential "1") InfoAction]),
                
                testCaseSteps "lazyTxInfoCurrentTreasuryAmount" $ \_ -> do

                  assertBool "lazyTxInfoCurrentTreasuryAmount" (lazyTxInfoCurrentTreasuryAmount (createScriptContextBd "1") == Just 4),
              
                testCaseSteps "lazyTxInfoTreasuryDonation" $ \_ -> do

                  assertBool "lazyTxInfoTreasuryDonation" (lazyTxInfoTreasuryDonation (createScriptContextBd "1") == Just 5)
              ]