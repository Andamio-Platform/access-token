module Tests.BuiltinByteString (tests) where

import Prelude
import Test.Tasty                              (testGroup, TestTree)
import PlutusTx
import PlutusTx.Builtins.Internal        as BI
import Test.Tasty.HUnit                        (testCaseSteps, assertBool)
import Andamio.Utility.BuiltinByteString

tests :: TestTree
tests = testGroup "BuiltinByteString" 
              [ testCaseSteps "bdElemList" $ \_ -> do

                  let l1 = BI.unsafeDataAsList $ toBuiltinData ([1, 2, 3] :: [Integer])
                      l2 = BI.unsafeDataAsList $ toBuiltinData ([1, 2, 4] :: [Integer])
                      l3 = BI.unsafeDataAsList $ toBuiltinData ([] :: [Integer])
                      int = toBuiltinData (4 :: Integer)                    

                  assertBool "bd is or is not elem" (bdElemList l1 int == False && bdElemList l2 int && bdElemList l3 int == False),
                
                testCaseSteps "filterNotElem" $ \_ -> do

                  let bbsL1 = ["1", "2", "3"]
                      bbsL2 = ["1", "2", "4"]

                  assertBool "filterNotElem" (filterNotElem bbsL1 bbsL2 [] == ["3"] && filterNotElem bbsL2 bbsL1 [] == ["4"]),
                
                testCaseSteps "allElem" $ \_ -> do

                  let bbsL1 = ["1", "2"]
                      bbsL2 = ["1", "2", "4"]
                  
                  assertBool "allElem" (allElem bbsL1 bbsL2 == True && allElem bbsL2 bbsL1 == False),
                
                testCaseSteps "appendList" $ \_ -> do

                  let bbsL = ["1", "2", "3", "4"]
                  
                  assertBool "appendList" (appendList bbsL "" == "1234"),
                
                testCaseSteps "merge" $ \_ -> do

                  let bbsL1 = ["1", "2"]
                      bbsL2 = ["1", "2", "4"]
                  
                  assertBool "merge" (merge bbsL1 bbsL2 [] == ["1", "1", "2", "2", "4"]),
                
                testCaseSteps "lengthBBsList" $ \_ -> do

                  let bbsL = ["1", "2", "3", "4"]
                  
                  assertBool "lengthBBsList" (lengthBBsList bbsL 0 == 4)
              ]