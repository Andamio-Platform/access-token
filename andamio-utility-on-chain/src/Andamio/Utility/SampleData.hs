module Andamio.Utility.SampleData
    ( cs1
    , cs2
    , cs3
    , tn1Str
    , tn2Str
    , tn3Str
    , addr1
    , addr2
    , addr3
    , txHash1
    , txHash2
    , txHash3
    , txId1
    , txId2
    , txId3
    , txOutRef1
    , txOutRef2
    , txOutRef3
    ) where

import           Data.String                  (fromString)
import           Prelude                      (Integer, String)
import           PlutusLedgerApi.V3 as Plutus


txOutRef1 :: TxOutRef
txOutRef1 = TxOutRef (fromString txHash1) txId1

txOutRef2 :: TxOutRef
txOutRef2 = TxOutRef (fromString txHash2) txId2

txOutRef3 :: TxOutRef
txOutRef3 = TxOutRef (fromString txHash3) txId3

txHash1 :: String 
txHash1 = "1111111111111111111111111111111111111111111111111111111111111111"

txHash2 :: String 
txHash2 = "2222222222222222222222222222222222222222222222222222222222222222"


txHash3 :: String
txHash3 = "3333333333333333333333333333333333333333333333333333333333333333"

txId1 :: Integer
txId1 = 1

txId2 :: Integer
txId2 = 10

txId3 :: Integer
txId3 = 3

tn1Str :: String 
tn1Str = "5" -- 35

tn2Str :: String
tn2Str = "a" -- 61

tn3Str :: String 
tn3Str = "z" -- 7a

addr1 :: String 
addr1 = "addr_test1xr3y6w95qnxd36jnpls2xkedua384gnje8lfwumnxmkq2k97e2x40hz803ze97khldrp2xav4xjs002zcflxe6ul22dshvpw63"

addr2 :: String 
addr2 = "addr_test1xr5p5urs8ff7rfhchz5kuxes05ektgtslwpswzfzcmr4y8d7e2x40hz803ze97khldrp2xav4xjs002zcflxe6ul22dsyd77au"

addr3 :: String 
addr3 = "addr_test1xz8cfevn6n6qxsgft208pwmysrn8fdfnnclxyj4jpg552cd7e2x40hz803ze97khldrp2xav4xjs002zcflxe6ul22ds04zp96"

cs1 :: CurrencySymbol
cs1 = "b6f3ddf2790e0e768f75f800c99834247de1ea1388c0aafe1c0b4d95"

cs2 :: CurrencySymbol
cs2 = "801ea167c62a8d41fe01b34f292ef643e618e42865ac607b53456d94"

cs3 :: CurrencySymbol
cs3 = "f6f49b186751e61f1fb8c64e7504e771f968cea9f4d11f5222b169e3"
