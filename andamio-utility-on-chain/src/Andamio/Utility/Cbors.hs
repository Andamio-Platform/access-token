module Andamio.Utility.Cbors
    ( compareCbors
    , v3Prefix
    ) where

import           Prelude
import           Data.ByteString.Short (fromShort)
import           PlutusLedgerApi.V3 as Plutus
import           Data.ByteString as BS 

compareCbors :: SerialisedScript -> SerialisedScript -> SerialisedScript -> [BS.ByteString]
compareCbors cbor1 cbor2 cbor3 = go (fromShort cbor1) (fromShort cbor2) (fromShort cbor3) "" [] True
  where
    go :: BS.ByteString -> BS.ByteString -> BS.ByteString -> BS.ByteString -> [BS.ByteString] -> Bool -> [BS.ByteString]
    go c1 c2 c3 curC cL bool
      | c1 == "" && c2 == "" && c3 == "" = BS.append v3Prefix (Prelude.head $ Prelude.reverse (curC : cL)) : Prelude.drop 1 (Prelude.reverse (curC : cL))
      | (t1 c1 == t1 c2 && t1 c3 == t1 c2 && t1 c3 == t1 c1) && bool          = go (d1 c1) (d1 c2) (d1 c3) (BS.append curC (t1 c1)) cL True
      | (t1 c1 == t1 c2 && t1 c3 == t1 c2 && t1 c3 == t1 c1) && bool == False = go (d1 c1) (d1 c2) (d1 c3) (t1 c1) cL True
      | (t1 c1 /= t1 c2 || t1 c3 /= t1 c2 || t1 c3 /= t1 c1) && bool          = go (d1 c1) (d1 c2) (d1 c3) "" (curC : cL) False
      | otherwise                                                             = go (d1 c1) (d1 c2) (d1 c3) curC cL False

t1 :: BS.ByteString -> BS.ByteString
t1 = BS.take 1

d1 :: BS.ByteString -> BS.ByteString
d1 = BS.drop 1

v3Prefix :: BS.ByteString
v3Prefix = "\x03"