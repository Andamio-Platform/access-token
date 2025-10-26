module Andamio.Utility.BuiltinByteString
    ( merge
    , appendList
    , lengthBBsList
    , bbsIsElem
    , allElem
    , filterNotElem
    , bdElemList
    ) where

import           PlutusTx.Prelude                 (Integer, (+), (++), appendByteString,
                                                  Bool(..), (==), otherwise, (||), (&&))
import           PlutusLedgerApi.V3               (BuiltinByteString, BuiltinData)
import qualified PlutusTx.Builtins.Internal as BI (head, tail)
import           PlutusTx.Builtins.Internal       (BuiltinList)
import           PlutusTx.Builtins                (null)

{-# INLINEABLE bdElemList #-}
bdElemList :: BuiltinList BuiltinData -> BuiltinData -> Bool
bdElemList bdList bd
  | null bdList = False
  | otherwise = (BI.head bdList == bd) || bdElemList (BI.tail bdList) bd

{-# INLINEABLE filterNotElem #-}
filterNotElem :: [BuiltinByteString] -> [BuiltinByteString] -> [BuiltinByteString] -> [BuiltinByteString]
filterNotElem [] _ counter = counter
filterNotElem (x:xs) bbsL counter = if bbsIsElem bbsL x == False
                            then filterNotElem xs bbsL (x:counter)
                            else filterNotElem xs bbsL counter

-- whole first list exists in second
{-# INLINEABLE allElem #-}
allElem :: [BuiltinByteString] -> [BuiltinByteString] -> Bool
allElem [] _ = True
allElem (x:xs) userLs = bbsIsElem userLs x && allElem xs userLs

{-# INLINEABLE appendList #-}
appendList :: [BuiltinByteString] -> BuiltinByteString -> BuiltinByteString
appendList [] counter = counter
appendList (x:xs) counter = appendList xs (appendByteString counter x)

{-# INLINEABLE merge #-}
merge :: [BuiltinByteString] -> [BuiltinByteString] -> [BuiltinByteString] -> [BuiltinByteString]
merge []     []     counter = counter
merge xs     []     counter = counter ++ xs
merge []     ys     counter = counter ++ ys
merge (x:xs) (y:ys) counter = merge xs ys (counter ++ [x, y])

-- BuiltinByteString is in list
{-# INLINEABLE bbsIsElem #-}
bbsIsElem :: [BuiltinByteString] -> BuiltinByteString -> Bool
bbsIsElem [] _ = False
bbsIsElem (x:xs) bbs = (x == bbs) || bbsIsElem xs bbs

{-# INLINEABLE lengthBBsList #-}
lengthBBsList :: [BuiltinByteString] -> Integer -> Integer
lengthBBsList [] counter = counter
lengthBBsList (_:xs) counter = lengthBBsList xs (counter + 1)