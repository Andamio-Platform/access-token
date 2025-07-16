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
    unitval,
    constrArgs
  )
where

import           PlutusLedgerApi.V3        (Lovelace, ScriptInfo(..), CurrencySymbol (..),
                                           TxInInfo (..),Datum (..),Credential (..),
                                           TxOutRef(..),Value (..),POSIXTimeRange,
                                           Redeemer (..),ProposalProcedure(..),GovernanceActionId(..),
                                           PubKeyHash,Map,Vote,Voter,DatumHash, TxOut (..),
                                           ScriptPurpose (..),TxId(..),TxCert(..))
import          PlutusTx                   (BuiltinData, UnsafeFromData, unsafeFromBuiltinData)
import          PlutusTx.Builtins.Internal (head, tail, snd, BuiltinList, unsafeDataAsConstr, unitval, 
                                           unsafeDataAsList, BuiltinPair, unsafeDataAsMap, BuiltinInteger)
import          PlutusTx.Prelude           (Maybe (..),(.))

{-# INLINEABLE constrArgs #-}
constrArgs :: BuiltinData -> BuiltinList BuiltinData
constrArgs = snd . unsafeDataAsConstr

{-# INLINEABLE getContext #-}
getContext :: BuiltinData -> BuiltinList BuiltinData
getContext = constrArgs

{-# INLINEABLE lazyRedeemer #-}
lazyRedeemer :: BuiltinData -> BuiltinPair BuiltinInteger (BuiltinList BuiltinData)
lazyRedeemer = unsafeDataAsConstr . head . tail . getContext

{-# INLINEABLE lazyRedeemerTyped #-}
lazyRedeemerTyped :: forall red. (UnsafeFromData red) => BuiltinData -> red
lazyRedeemerTyped = unsafeFromBuiltinData @red . getRedeemer . unsafeFromBuiltinData . head . tail . getContext

{-# INLINEABLE lazyScriptInfoBd #-}
lazyScriptInfoBd :: BuiltinData -> BuiltinData
lazyScriptInfoBd = head . tail . tail . getContext

{-# INLINEABLE lazyScriptInfo #-}
lazyScriptInfo :: BuiltinData -> ScriptInfo
lazyScriptInfo = unsafeFromBuiltinData . lazyScriptInfoBd

{-# INLINEABLE lazyInlineDatum #-}
lazyInlineDatum :: BuiltinData -> BuiltinData
lazyInlineDatum = getDatum . unsafeFromBuiltinData . head . constrArgs  . head . tail . constrArgs . lazyScriptInfoBd

{-# INLINEABLE lazyInlineDatumTyped #-}
lazyInlineDatumTyped :: forall dat. (UnsafeFromData dat) => BuiltinData -> dat
lazyInlineDatumTyped = unsafeFromBuiltinData @dat . lazyInlineDatum

{-# INLINEABLE lazyTxOutRefBd #-}
lazyTxOutRefBd :: BuiltinData -> BuiltinData
lazyTxOutRefBd = head . constrArgs . lazyScriptInfoBd

{-# INLINEABLE lazyTxOutRef #-}
lazyTxOutRef :: BuiltinData -> TxOutRef
lazyTxOutRef = unsafeFromBuiltinData . lazyTxOutRefBd

{-# INLINEABLE lazyOwnCurrencySymbolBd #-}
lazyOwnCurrencySymbolBd :: BuiltinData -> BuiltinData
lazyOwnCurrencySymbolBd = head . constrArgs . lazyScriptInfoBd

{-# INLINEABLE lazyOwnCurrencySymbol #-}
lazyOwnCurrencySymbol :: BuiltinData -> CurrencySymbol
lazyOwnCurrencySymbol = CurrencySymbol . unsafeFromBuiltinData . lazyOwnCurrencySymbolBd

{-# INLINEABLE lazyTxInfo #-}
lazyTxInfo :: BuiltinData -> BuiltinList BuiltinData
lazyTxInfo = constrArgs . head . getContext

{-# INLINEABLE lazyTxInfoInputs #-}
lazyTxInfoInputs :: BuiltinData -> [TxInInfo]
lazyTxInfoInputs = unsafeFromBuiltinData . head . lazyTxInfo

{-# INLINEABLE lazyTxInfoInputsBd #-}
lazyTxInfoInputsBd :: BuiltinData -> BuiltinList BuiltinData
lazyTxInfoInputsBd = unsafeDataAsList . head . lazyTxInfo

{-# INLINEABLE lazyTxInfoReferenceInputsBd #-}
lazyTxInfoReferenceInputsBd :: BuiltinData -> BuiltinList BuiltinData
lazyTxInfoReferenceInputsBd = unsafeDataAsList . head . tail . lazyTxInfo

{-# INLINEABLE lazyTxInfoReferenceInputs #-}
lazyTxInfoReferenceInputs :: BuiltinData -> [TxInInfo]
lazyTxInfoReferenceInputs = unsafeFromBuiltinData . head . tail . lazyTxInfo

{-# INLINEABLE lazyTxInfoOutputs #-}
lazyTxInfoOutputs :: BuiltinData -> [TxOut]
lazyTxInfoOutputs = unsafeFromBuiltinData . head . tail . tail . lazyTxInfo

{-# INLINEABLE lazyTxInfoOutputsBd #-}
lazyTxInfoOutputsBd :: BuiltinData -> BuiltinList BuiltinData
lazyTxInfoOutputsBd = unsafeDataAsList . head . tail . tail . lazyTxInfo

{-# INLINEABLE lazyTxInfoFee #-}
lazyTxInfoFee :: BuiltinData -> Lovelace
lazyTxInfoFee = unsafeFromBuiltinData . head . tail . tail . tail . lazyTxInfo

{-# INLINEABLE lazyTxInfoMintBd #-}
lazyTxInfoMintBd :: BuiltinData -> BuiltinData
lazyTxInfoMintBd = head . tail . tail . tail . tail . lazyTxInfo

{-# INLINEABLE lazyTxInfoMint #-}
lazyTxInfoMint :: BuiltinData -> Value
lazyTxInfoMint = unsafeFromBuiltinData . lazyTxInfoMintBd

{-# INLINEABLE lazyTxInfoTxCerts #-}
lazyTxInfoTxCerts :: BuiltinData -> [TxCert]
lazyTxInfoTxCerts =
  unsafeFromBuiltinData . head . tail . tail . tail . tail . tail . lazyTxInfo

{-# INLINEABLE lazyTxInfoWdrl #-}
lazyTxInfoWdrl :: BuiltinData -> Map Credential Lovelace
lazyTxInfoWdrl =
  unsafeFromBuiltinData . head . tail . tail . tail . tail . tail . tail . lazyTxInfo

{-# INLINEABLE lazyTxInfoWdrlBd #-}
lazyTxInfoWdrlBd :: BuiltinData -> BuiltinList (BuiltinPair BuiltinData BuiltinData)
lazyTxInfoWdrlBd = unsafeDataAsMap . head . tail . tail . tail . tail . tail . tail . lazyTxInfo

{-# INLINEABLE lazyTxInfoValidRange #-}
lazyTxInfoValidRange :: BuiltinData -> POSIXTimeRange
lazyTxInfoValidRange =
  unsafeFromBuiltinData . head . tail . tail . tail . tail . tail . tail . tail . lazyTxInfo

{-# INLINEABLE lazyTxInfoSignatories #-}
lazyTxInfoSignatories :: BuiltinData -> [PubKeyHash]
lazyTxInfoSignatories =
  unsafeFromBuiltinData . head . tail . tail . tail . tail . tail . tail . tail . tail . lazyTxInfo

{-# INLINEABLE lazyTxInfoRedeemers #-}
lazyTxInfoRedeemers :: BuiltinData -> Map ScriptPurpose Redeemer
lazyTxInfoRedeemers =
  unsafeFromBuiltinData . head . tail . tail . tail . tail . tail . tail . tail . tail . tail . lazyTxInfo

{-# INLINEABLE lazyTxInfoRedeemersBd #-}
lazyTxInfoRedeemersBd :: BuiltinData -> BuiltinList (BuiltinPair BuiltinData BuiltinData)
lazyTxInfoRedeemersBd = unsafeDataAsMap . head . tail . tail . tail . tail . tail . tail . tail . tail . tail . lazyTxInfo

{-# INLINEABLE lazyTxInfoData #-}
lazyTxInfoData :: BuiltinData -> Map DatumHash Datum
lazyTxInfoData =
  unsafeFromBuiltinData . head . tail . tail . tail . tail . tail . tail . tail . tail . tail . tail . lazyTxInfo

{-# INLINEABLE lazyTxInfoId #-}
lazyTxInfoId :: BuiltinData -> TxId
lazyTxInfoId =
  unsafeFromBuiltinData . head . tail . tail . tail . tail . tail . tail . tail . tail . tail . tail . tail . lazyTxInfo

{-# INLINEABLE lazyTxInfoVotes #-}
lazyTxInfoVotes :: BuiltinData -> Map Voter (Map GovernanceActionId Vote)
lazyTxInfoVotes =
  unsafeFromBuiltinData . head . tail . tail . tail . tail . tail . tail . tail . tail . tail . tail . tail . tail . lazyTxInfo

{-# INLINEABLE lazyTxInfoProposalProcedures #-}
lazyTxInfoProposalProcedures :: BuiltinData -> [ProposalProcedure]
lazyTxInfoProposalProcedures =
  unsafeFromBuiltinData . head . tail . tail . tail . tail . tail . tail . tail . tail . tail . tail . tail . tail . tail . lazyTxInfo

{-# INLINEABLE lazyTxInfoCurrentTreasuryAmount #-}
lazyTxInfoCurrentTreasuryAmount :: BuiltinData -> Maybe Lovelace
lazyTxInfoCurrentTreasuryAmount =
  unsafeFromBuiltinData . head . tail . tail . tail . tail . tail . tail . tail . tail . tail . tail . tail . tail . tail . tail . lazyTxInfo

{-# INLINEABLE lazyTxInfoTreasuryDonation #-}
lazyTxInfoTreasuryDonation :: BuiltinData -> Maybe Lovelace
lazyTxInfoTreasuryDonation =
  unsafeFromBuiltinData . head . tail . tail . tail . tail . tail . tail . tail . tail . tail . tail . tail . tail . tail . tail . tail . lazyTxInfo