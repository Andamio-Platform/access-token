module Andamio.Utility.LazyContextV3
  ( lazyTxInfoInputs,
    lazyTxInfoInputsBd,
    lazyTxInfoReferenceInputs,
    lazyTxInfoReferenceInputsBd,
    lazyTxInfoOutputs,
    lazyTxInfoOutputsBd,
    lazyTxInfoFee,
    lazyTxInfoMintBd,
    lazyTxInfoMint,
    lazyTxInfoTxCerts,
    lazyTxInfoWdrl,
    lazyTxInfoWdrlBd,
    lazyTxInfoValidRange,
    lazyTxInfoSignatories,
    lazyTxInfoRedeemers,
    lazyTxInfoRedeemersBd,
    lazyTxInfoData,
    lazyTxInfoId,
    lazyTxInfoVotes,
    lazyTxInfoProposalProcedures,
    lazyTxInfoCurrentTreasuryAmount,
    lazyTxInfoTreasuryDonation,
    getContext,
    lazyTxInfo,
    lazyRedeemerTyped,
    lazyRedeemer,
    lazyInlineDatumTyped,
    lazyInlineDatum,
    lazyTxOutRef,
    lazyTxOutRefBd,
    lazyOwnCurrencySymbol,
    lazyOwnCurrencySymbolBd,
    lazyScriptInfo,
    lazyScriptInfoBd,
    BI.unitval,
    constrArgs
  )
where

import           PlutusLedgerApi.V3               (Lovelace, ScriptInfo(..), CurrencySymbol (..),
                                                  TxInInfo (..),Datum (..),Credential (..),
                                                  TxOutRef(..),Value (..),POSIXTimeRange,
                                                  Redeemer (..),ProposalProcedure(..),GovernanceActionId(..),
                                                  PubKeyHash,Map,Vote,Voter,DatumHash, TxOut (..),
                                                  ScriptPurpose (..),TxId(..),TxCert(..))
import           PlutusTx                         (BuiltinData, UnsafeFromData, unsafeFromBuiltinData)
import qualified PlutusTx.Builtins.Internal as BI (head, tail, snd, unsafeDataAsConstr, unitval,
                                                  unsafeDataAsList, unsafeDataAsMap)
import           PlutusTx.Builtins.Internal       (BuiltinList, BuiltinPair, BuiltinInteger)
import           PlutusTx.Prelude                 (Maybe (..),(.))

{-# INLINEABLE constrArgs #-}
constrArgs :: BuiltinData -> BuiltinList BuiltinData
constrArgs = BI.snd . BI.unsafeDataAsConstr

{-# INLINEABLE getContext #-}
getContext :: BuiltinData -> BuiltinList BuiltinData
getContext = constrArgs

{-# INLINEABLE lazyRedeemer #-}
lazyRedeemer :: BuiltinData -> BuiltinPair BuiltinInteger (BuiltinList BuiltinData)
lazyRedeemer = BI.unsafeDataAsConstr . BI.head . BI.tail . getContext

{-# INLINEABLE lazyRedeemerTyped #-}
lazyRedeemerTyped :: forall red. (UnsafeFromData red) => BuiltinData -> red
lazyRedeemerTyped = unsafeFromBuiltinData @red . getRedeemer . unsafeFromBuiltinData . BI.head . BI.tail . getContext

{-# INLINEABLE lazyScriptInfoBd #-}
lazyScriptInfoBd :: BuiltinData -> BuiltinData
lazyScriptInfoBd = BI.head . BI.tail . BI.tail . getContext

{-# INLINEABLE lazyScriptInfo #-}
lazyScriptInfo :: BuiltinData -> ScriptInfo
lazyScriptInfo = unsafeFromBuiltinData . lazyScriptInfoBd

{-# INLINEABLE lazyInlineDatum #-}
lazyInlineDatum :: BuiltinData -> BuiltinData
lazyInlineDatum = getDatum . unsafeFromBuiltinData . BI.head . constrArgs  . BI.head . BI.tail . constrArgs . lazyScriptInfoBd

{-# INLINEABLE lazyInlineDatumTyped #-}
lazyInlineDatumTyped :: forall dat. (UnsafeFromData dat) => BuiltinData -> dat
lazyInlineDatumTyped = unsafeFromBuiltinData @dat . lazyInlineDatum

{-# INLINEABLE lazyTxOutRefBd #-}
lazyTxOutRefBd :: BuiltinData -> BuiltinData
lazyTxOutRefBd = BI.head . constrArgs . lazyScriptInfoBd

{-# INLINEABLE lazyTxOutRef #-}
lazyTxOutRef :: BuiltinData -> TxOutRef
lazyTxOutRef = unsafeFromBuiltinData . lazyTxOutRefBd

{-# INLINEABLE lazyOwnCurrencySymbolBd #-}
lazyOwnCurrencySymbolBd :: BuiltinData -> BuiltinData
lazyOwnCurrencySymbolBd = BI.head . constrArgs . lazyScriptInfoBd

{-# INLINEABLE lazyOwnCurrencySymbol #-}
lazyOwnCurrencySymbol :: BuiltinData -> CurrencySymbol
lazyOwnCurrencySymbol = CurrencySymbol . unsafeFromBuiltinData . lazyOwnCurrencySymbolBd

{-# INLINEABLE lazyTxInfo #-}
lazyTxInfo :: BuiltinData -> BuiltinList BuiltinData
lazyTxInfo = constrArgs . BI.head . getContext

{-# INLINEABLE lazyTxInfoInputs #-}
lazyTxInfoInputs :: BuiltinData -> [TxInInfo]
lazyTxInfoInputs = unsafeFromBuiltinData . BI.head . lazyTxInfo

{-# INLINEABLE lazyTxInfoInputsBd #-}
lazyTxInfoInputsBd :: BuiltinData -> BuiltinList BuiltinData
lazyTxInfoInputsBd = BI.unsafeDataAsList . BI.head . lazyTxInfo

{-# INLINEABLE lazyTxInfoReferenceInputsBd #-}
lazyTxInfoReferenceInputsBd :: BuiltinData -> BuiltinList BuiltinData
lazyTxInfoReferenceInputsBd = BI.unsafeDataAsList . BI.head . BI.tail . lazyTxInfo

{-# INLINEABLE lazyTxInfoReferenceInputs #-}
lazyTxInfoReferenceInputs :: BuiltinData -> [TxInInfo]
lazyTxInfoReferenceInputs = unsafeFromBuiltinData . BI.head . BI.tail . lazyTxInfo

{-# INLINEABLE lazyTxInfoOutputs #-}
lazyTxInfoOutputs :: BuiltinData -> [TxOut]
lazyTxInfoOutputs = unsafeFromBuiltinData . BI.head . BI.tail . BI.tail . lazyTxInfo

{-# INLINEABLE lazyTxInfoOutputsBd #-}
lazyTxInfoOutputsBd :: BuiltinData -> BuiltinList BuiltinData
lazyTxInfoOutputsBd = BI.unsafeDataAsList . BI.head . BI.tail . BI.tail . lazyTxInfo

{-# INLINEABLE lazyTxInfoFee #-}
lazyTxInfoFee :: BuiltinData -> Lovelace
lazyTxInfoFee = unsafeFromBuiltinData . BI.head . BI.tail . BI.tail . BI.tail . lazyTxInfo

{-# INLINEABLE lazyTxInfoMintBd #-}
lazyTxInfoMintBd :: BuiltinData -> BuiltinData
lazyTxInfoMintBd = BI.head . BI.tail . BI.tail . BI.tail . BI.tail . lazyTxInfo

{-# INLINEABLE lazyTxInfoMint #-}
lazyTxInfoMint :: BuiltinData -> Value
lazyTxInfoMint = unsafeFromBuiltinData . lazyTxInfoMintBd

{-# INLINEABLE lazyTxInfoTxCerts #-}
lazyTxInfoTxCerts :: BuiltinData -> [TxCert]
lazyTxInfoTxCerts =
  unsafeFromBuiltinData . BI.head . BI.tail . BI.tail . BI.tail . BI.tail . BI.tail . lazyTxInfo

{-# INLINEABLE lazyTxInfoWdrl #-}
lazyTxInfoWdrl :: BuiltinData -> Map Credential Lovelace
lazyTxInfoWdrl =
  unsafeFromBuiltinData . BI.head . BI.tail . BI.tail . BI.tail . BI.tail . BI.tail . BI.tail . lazyTxInfo

{-# INLINEABLE lazyTxInfoWdrlBd #-}
lazyTxInfoWdrlBd :: BuiltinData -> BuiltinList (BuiltinPair BuiltinData BuiltinData)
lazyTxInfoWdrlBd = BI.unsafeDataAsMap . BI.head . BI.tail . BI.tail . BI.tail . BI.tail . BI.tail . BI.tail . lazyTxInfo

{-# INLINEABLE lazyTxInfoValidRange #-}
lazyTxInfoValidRange :: BuiltinData -> POSIXTimeRange
lazyTxInfoValidRange =
  unsafeFromBuiltinData . BI.head . BI.tail . BI.tail . BI.tail . BI.tail . BI.tail . BI.tail . BI.tail . lazyTxInfo

{-# INLINEABLE lazyTxInfoSignatories #-}
lazyTxInfoSignatories :: BuiltinData -> [PubKeyHash]
lazyTxInfoSignatories =
  unsafeFromBuiltinData . BI.head . BI.tail . BI.tail . BI.tail . BI.tail . BI.tail . BI.tail . BI.tail . BI.tail . lazyTxInfo

{-# INLINEABLE lazyTxInfoRedeemers #-}
lazyTxInfoRedeemers :: BuiltinData -> Map ScriptPurpose Redeemer
lazyTxInfoRedeemers =
  unsafeFromBuiltinData . BI.head . BI.tail . BI.tail . BI.tail . BI.tail . BI.tail . BI.tail . BI.tail . BI.tail . BI.tail . lazyTxInfo

{-# INLINEABLE lazyTxInfoRedeemersBd #-}
lazyTxInfoRedeemersBd :: BuiltinData -> BuiltinList (BuiltinPair BuiltinData BuiltinData)
lazyTxInfoRedeemersBd = BI.unsafeDataAsMap . BI.head . BI.tail . BI.tail . BI.tail . BI.tail . BI.tail . BI.tail . BI.tail . BI.tail . BI.tail . lazyTxInfo

{-# INLINEABLE lazyTxInfoData #-}
lazyTxInfoData :: BuiltinData -> Map DatumHash Datum
lazyTxInfoData =
  unsafeFromBuiltinData . BI.head . BI.tail . BI.tail . BI.tail . BI.tail . BI.tail . BI.tail . BI.tail . BI.tail . BI.tail . BI.tail . lazyTxInfo

{-# INLINEABLE lazyTxInfoId #-}
lazyTxInfoId :: BuiltinData -> TxId
lazyTxInfoId =
  unsafeFromBuiltinData . BI.head . BI.tail . BI.tail . BI.tail . BI.tail . BI.tail . BI.tail . BI.tail . BI.tail . BI.tail . BI.tail . BI.tail . lazyTxInfo

{-# INLINEABLE lazyTxInfoVotes #-}
lazyTxInfoVotes :: BuiltinData -> Map Voter (Map GovernanceActionId Vote)
lazyTxInfoVotes =
  unsafeFromBuiltinData . BI.head . BI.tail . BI.tail . BI.tail . BI.tail . BI.tail . BI.tail . BI.tail . BI.tail . BI.tail . BI.tail . BI.tail . BI.tail . lazyTxInfo

{-# INLINEABLE lazyTxInfoProposalProcedures #-}
lazyTxInfoProposalProcedures :: BuiltinData -> [ProposalProcedure]
lazyTxInfoProposalProcedures =
  unsafeFromBuiltinData . BI.head . BI.tail . BI.tail . BI.tail . BI.tail . BI.tail . BI.tail . BI.tail . BI.tail . BI.tail . BI.tail . BI.tail . BI.tail . BI.tail . lazyTxInfo

{-# INLINEABLE lazyTxInfoCurrentTreasuryAmount #-}
lazyTxInfoCurrentTreasuryAmount :: BuiltinData -> Maybe Lovelace
lazyTxInfoCurrentTreasuryAmount =
  unsafeFromBuiltinData . BI.head . BI.tail . BI.tail . BI.tail . BI.tail . BI.tail . BI.tail . BI.tail . BI.tail . BI.tail . BI.tail . BI.tail . BI.tail . BI.tail . BI.tail . lazyTxInfo

{-# INLINEABLE lazyTxInfoTreasuryDonation #-}
lazyTxInfoTreasuryDonation :: BuiltinData -> Maybe Lovelace
lazyTxInfoTreasuryDonation =
  unsafeFromBuiltinData . BI.head . BI.tail . BI.tail . BI.tail . BI.tail . BI.tail . BI.tail . BI.tail . BI.tail . BI.tail . BI.tail . BI.tail . BI.tail . BI.tail . BI.tail . BI.tail . lazyTxInfo