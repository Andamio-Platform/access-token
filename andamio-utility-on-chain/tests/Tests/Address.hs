module Tests.Address (tests) where

import Prelude
import Test.Tasty                    (testGroup, TestTree)
import PlutusTx
import PlutusTx.Prelude              (blake2b_224)
import PlutusLedgerApi.V3      as V3
import Test.Tasty.HUnit              (testCaseSteps, assertBool)
import Andamio.Utility.Address

tests :: TestTree
tests = testGroup "Address" 
              [ testCaseSteps "scriptCredFromScrHash" $ \_ -> do

                  let sh = scriptCredFromScrHash $ ScriptHash $ blake2b_224 "1"
                      
                  bool <- case unsafeFromBuiltinData @Credential sh of
                    PubKeyCredential _ -> return False
                    ScriptCredential _ -> return True
                  assertBool "scriptCredFromScrHash" bool,

                testCaseSteps "addressFromScriptHashesBd" $ \_ -> do

                  let addrBd = addressFromScriptHashesBd (toBuiltinData $ ScriptHash $ blake2b_224 "1") (toBuiltinData $ ScriptHash $ blake2b_224 "2")
                      addr = Address (ScriptCredential $ ScriptHash $ blake2b_224 "1") (Just $ StakingHash $ ScriptCredential $ ScriptHash $ blake2b_224 "2")
                  
                  assertBool "addressFromScriptHashesBd" (addr == unsafeFromBuiltinData addrBd),
                
                testCaseSteps "just ScriptHash" $ \_ -> do

                  let justSh = Just $ ScriptHash $ blake2b_224 "1"
                      justShBd = justScriptHashBd $ ScriptHash $ blake2b_224 "1"
                      justShLazyBd = justBdScriptHashBd $ toBuiltinData $ blake2b_224 "1"
                  
                  assertBool "not same script hashes" (justSh == unsafeFromBuiltinData justShBd && justSh == unsafeFromBuiltinData justShLazyBd),
                
                testCaseSteps "get address script hash" $ \_ -> do

                  let addr = toBuiltinData $ Address (ScriptCredential $ ScriptHash $ blake2b_224 "1") (Just $ StakingHash $ ScriptCredential $ ScriptHash $ blake2b_224 "2")

                  assertBool "same script hashes" (toBuiltinData (getAddressBdScriptHash addr) == getAddressBdScriptHashBd addr && ScriptHash (blake2b_224 "1") == getAddressBdScriptHash addr)
              ]