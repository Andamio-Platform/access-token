module Tests.Redeemers (tests) where

import Prelude
import Test.Tasty                        (testGroup, TestTree)
import PlutusTx
import PlutusTx.AssocMap          as Map
import PlutusLedgerApi.V3         as V3
import Test.Tasty.HUnit                  (testCaseSteps, assertBool)
import PlutusTx.Builtins.Internal        (unsafeDataAsMap)

import Andamio.Utility.Redeemers
import Andamio.Utility.Test

tests :: TestTree
tests = testGroup "Redeemers" 
              [ testCaseSteps "filterRedeemersBdByScriptPurposeBd: some" $ \_ -> do
                  let scriptPurpose1 =  Minting $ createCs "1"
                      scriptPurpose2 =  Minting $ createCs "2"
                      redeemer int = Redeemer $ toBuiltinData (int :: Integer)
                      redeemers1 = toBuiltinData $ Map.unsafeFromList [(scriptPurpose1, redeemer 1), (scriptPurpose2, redeemer 2), (scriptPurpose1, redeemer 2)]
                  assertBool "filterRedeemersBdByScriptPurposeBd" (filterRedeemersBdByScriptPurposeBd (unsafeDataAsMap redeemers1) (toBuiltinData scriptPurpose1) == [redeemer 2, redeemer 1]),

                testCaseSteps "filterRedeemersBdByScriptPurposeBd: none" $ \_ -> do
                  let scriptPurpose1 =  Minting $ createCs "1"
                      scriptPurpose2 =  Minting $ createCs "2"
                      scriptPurpose3 =  Minting $ createCs "3"
                      redeemer int = Redeemer $ toBuiltinData (int :: Integer)
                      redeemers1 = toBuiltinData $ Map.unsafeFromList [(scriptPurpose1, redeemer 1), (scriptPurpose2, redeemer 2), (scriptPurpose1, redeemer 2)]
                  assertBool "filterRedeemersBdByScriptPurposeBd" (filterRedeemersBdByScriptPurposeBd (unsafeDataAsMap redeemers1) (toBuiltinData scriptPurpose3) == [])
              ]