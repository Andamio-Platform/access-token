module Andamio.Utility.Redeemers
    ( filterRedeemersBdByScriptPurposeBd
    ) where

import           PlutusTx.Prelude                 (otherwise, ($), (==))
import qualified PlutusTx.Builtins.Internal as BI (tail, head, snd, fst)
import           PlutusTx.Builtins.Internal       (BuiltinData, BuiltinPair, BuiltinList)
import           PlutusTx.Builtins                (null)
import           PlutusLedgerApi.V3               (Redeemer, unsafeFromBuiltinData)

{-# INLINEABLE filterRedeemersBdByScriptPurposeBd #-}
filterRedeemersBdByScriptPurposeBd :: BuiltinList (BuiltinPair BuiltinData BuiltinData) -> BuiltinData -> [Redeemer]
filterRedeemersBdByScriptPurposeBd bdListTuple purposeBd = go bdListTuple []
  where
    go :: BuiltinList (BuiltinPair BuiltinData BuiltinData) -> [Redeemer] -> [Redeemer]
    go bdListTuple' counter
      | null bdListTuple' = counter
      | BI.fst (BI.head bdListTuple') == purposeBd = go (BI.tail bdListTuple') (unsafeFromBuiltinData (BI.snd $ BI.head bdListTuple'):counter)
      | otherwise = go (BI.tail bdListTuple') counter