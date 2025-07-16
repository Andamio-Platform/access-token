module Main (main) where

import Prelude
import Test.Tasty                     (testGroup, defaultMain, TestTree)

import Tests.Validators as Validators
import Tests.Address as Address
import Tests.BuiltinByteString as BuiltinByteString
import Tests.Cbors as Cbors
import Tests.Datum as Datum
import Tests.LazyContextV3 as LazyContextV3
import Tests.Redeemers as Redeemers
import Tests.TxInInfo as TxInInfo
import Tests.TxOut as TxOut
import Tests.Value as Value

main :: IO ()
main = defaultMain Main.tests

tests :: TestTree
tests = testGroup "on-chain-utility-tests" 
  [ Validators.tests
  , Address.tests
  , BuiltinByteString.tests
  , Cbors.tests
  , Datum.tests
  , LazyContextV3.tests
  , Redeemers.tests
  , TxInInfo.tests
  , TxOut.tests
  , Value.tests
  ]