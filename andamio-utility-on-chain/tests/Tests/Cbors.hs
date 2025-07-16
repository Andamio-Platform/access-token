module Tests.Cbors (tests) where

import Prelude
import Test.Tasty                  (testGroup, TestTree)
import Data.ByteString       as BS
import Test.Tasty.HUnit            (testCaseSteps, assertBool)
import Andamio.Utility.Cbors

tests :: TestTree
tests = testGroup "Cbors" 
              [ testCaseSteps "compareCbors" $ \_ -> do

                  let bs1 = "1464knsvmsd"
                      bs2 = "1464kdvssvd6575d"
                      bs3 = "1465654dsldvs nsvldvssdaca"

                  assertBool "compareCbors" (compareCbors bs1 bs2 bs3 == [BS.append v3Prefix "146", "d", ""])
              ]