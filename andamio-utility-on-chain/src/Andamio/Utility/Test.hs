module Andamio.Utility.Test 
    ( createAddress
    , createScriptCredential
    , createCs
    , createValue
    , createTxOut
    , createTxOutRef
    , createTxInfo
    , createTxInInfo
    , createTxInInfoBd
    , isLeft
    , isRight
    , unsafeFromLeft
    , unsafeFromRight
    , unitRedeemer
    , emptyTxInfo
    , emptyTxOut
    , createScriptContext
    , createScriptContextBd
    , createScriptContextBd'
    , evaluateScriptCounting'
    , serialisedToCurrencySymbol
    ) where

import Prelude                             (Either(..), Bool(..), Show, ($), (.),
                                           error, show, either, map, fst, snd,
                                           Maybe(..), id)
import PlutusTx                            ()
import PlutusTx.AssocMap          as Map   (empty, singleton)
import PlutusLedgerApi.V3         as V3
import PlutusLedgerApi.V1.Value   as Value (singleton)
import PlutusTx.Prelude                    (blake2b_224)
import PlutusLedgerApi.Common.Versions     (ledgerLanguageIntroducedIn, PlutusLedgerLanguage(..))
import PlutusLedgerApi.Test.V3.EvaluationContext
import Cardano.Crypto.Hash        as Hash
import Data.ByteString            as BS hiding (map)
import Data.ByteString.Short      as SBS hiding (map)
import Control.Monad.Writer

createTxOutRef :: BuiltinByteString -> TxOutRef
createTxOutRef bbs = TxOutRef (TxId $ blake2b_224 bbs) 0

createAddress :: BuiltinByteString -> Address
createAddress bbs = Address (createScriptCredential bbs) Nothing

createScriptCredential :: BuiltinByteString -> Credential
createScriptCredential bbs = ScriptCredential $ ScriptHash $ blake2b_224 bbs

createCs :: BuiltinByteString -> CurrencySymbol
createCs = CurrencySymbol . blake2b_224

createValue :: BuiltinByteString -> Value
createValue bbs = Value.singleton (createCs bbs) (TokenName bbs) 1

createTxOut :: BuiltinByteString -> TxOut
createTxOut bbs = TxOut 
  { txOutAddress         = createAddress bbs
  , txOutValue           = createValue bbs
  , txOutDatum           = OutputDatum $ Datum $ toBuiltinData bbs
  , txOutReferenceScript = Just (ScriptHash $ blake2b_224 bbs)
    }

createTxInInfo :: BuiltinByteString -> TxInInfo
createTxInInfo bbs = TxInInfo
  { txInInfoOutRef   = TxOutRef (TxId $ blake2b_224 bbs) 0
  , txInInfoResolved = createTxOut bbs
  }

createTxInInfoBd :: BuiltinByteString -> BuiltinData
createTxInInfoBd = toBuiltinData . createTxInInfo

createTxInfo :: BuiltinByteString -> TxInfo 
createTxInfo bbs = TxInfo
  { txInfoInputs                = [createTxInInfo bbs]
  , txInfoReferenceInputs       = [createTxInInfo bbs]
  , txInfoOutputs               = [createTxOut bbs]
  , txInfoFee                   = 1
  , txInfoMint                  = Value.singleton (createCs bbs) (TokenName bbs) 2
  , txInfoTxCerts               = [TxCertRegStaking (createScriptCredential bbs) Nothing]
  , txInfoWdrl                  = Map.singleton (createScriptCredential bbs) 3
  , txInfoValidRange            = always
  , txInfoSignatories           = [PubKeyHash $ blake2b_224 bbs]
  , txInfoRedeemers             = Map.singleton (Minting $ createCs bbs) (Redeemer $ toBuiltinData bbs) 
  , txInfoData                  = Map.singleton (DatumHash $ blake2b_224 bbs) (Datum $ toBuiltinData bbs)
  , txInfoId                    = TxId $ blake2b_224 bbs
  , txInfoVotes                 = Map.singleton (DRepVoter $ DRepCredential $ createScriptCredential bbs) (Map.singleton (GovernanceActionId (TxId $ blake2b_224 bbs) 0) VoteNo)
  , txInfoProposalProcedures    = [ProposalProcedure 1 (createScriptCredential bbs) InfoAction]
  , txInfoCurrentTreasuryAmount = Just 4
  , txInfoTreasuryDonation      = Just 5
  }

unsafeFromRight :: (Show e) => Either e a -> a
unsafeFromRight (Right a) = a
unsafeFromRight (Left e)  = error $ show e

unsafeFromLeft :: (Show a) => Either e a -> e
unsafeFromLeft (Right a) = error $ show a
unsafeFromLeft (Left e)  = e

-- | Return `True` if the given value is a `Left`-value, `False` otherwise.
isLeft :: Either a b -> Bool
isLeft (Left _)  = True
isLeft (Right _) = False

-- | Return `True` if the given value is a `Right`-value, `False` otherwise.
isRight :: Either a b -> Bool
isRight (Left _)  = False
isRight (Right _) = True

evaluateScriptCounting' :: SerialisedScript -> BuiltinData -> Either EvaluationError ExBudget
evaluateScriptCounting' scr scrCtxBd = snd $ V3.evaluateScriptCounting (ledgerLanguageIntroducedIn PlutusV3) Quiet evalCtx (deserialiseScript' scr) (fromBuiltin scrCtxBd)

hashScript :: SerialisedScript -> ScriptHash
hashScript =
  ScriptHash
    . toBuiltin
    . (Hash.hashToBytes :: Hash.Hash Hash.Blake2b_224 SBS.ShortByteString -> BS.ByteString)
    . Hash.hashWith (BS.append "\x03" . SBS.fromShort)

serialisedToCurrencySymbol :: SerialisedScript -> CurrencySymbol
serialisedToCurrencySymbol = CurrencySymbol . getScriptHash . hashScript

evalCtx :: V3.EvaluationContext
evalCtx = fst $ unsafeFromRight $ runWriterT $ V3.mkEvaluationContext (map snd costModelParamsForTesting)

deserialiseScript' :: SerialisedScript -> ScriptForEvaluation
deserialiseScript' scr = either (error . show) id $ V3.deserialiseScript (ledgerLanguageIntroducedIn PlutusV3) scr

unitRedeemer :: Redeemer
unitRedeemer = Redeemer $ toBuiltinData ()

createScriptContext :: BuiltinByteString -> ScriptContext
createScriptContext bbs = ScriptContext 
  { scriptContextTxInfo = createTxInfo bbs
  , scriptContextRedeemer = Redeemer $ toBuiltinData bbs
  , scriptContextScriptInfo = MintingScript $ createCs bbs
  }

createScriptContextBd :: BuiltinByteString -> BuiltinData
createScriptContextBd = toBuiltinData . createScriptContext

createScriptContextBd' :: TxInfo -> Redeemer -> ScriptInfo -> BuiltinData
createScriptContextBd' txInfo redeemer scriptInfo = toBuiltinData $ ScriptContext 
  { scriptContextTxInfo = txInfo
  , scriptContextRedeemer = redeemer
  , scriptContextScriptInfo = scriptInfo
  }

emptyTxOut :: TxOut
emptyTxOut = TxOut {
    txOutAddress         = createAddress "0",
    txOutValue           = Value Map.empty,
    txOutDatum           = NoOutputDatum,
    txOutReferenceScript = Nothing
    }

emptyTxInfo :: TxInfo 
emptyTxInfo = TxInfo
  { txInfoInputs                = []
  , txInfoReferenceInputs       = []
  , txInfoOutputs               = []
  , txInfoFee                   = 0
  , txInfoMint                  = Value Map.empty
  , txInfoTxCerts               = []
  , txInfoWdrl                  = Map.empty
  , txInfoValidRange            = always
  , txInfoSignatories           = []
  , txInfoRedeemers             = Map.empty
  , txInfoData                  = Map.empty
  , txInfoId                    = "6c46dd437a3d43ac556795fbc4e92f914dee2aaa67d7b2de1f0aeaf8158f98c8"
  , txInfoVotes                 = Map.empty
  , txInfoProposalProcedures    = []
  , txInfoCurrentTreasuryAmount = Nothing
  , txInfoTreasuryDonation      = Nothing
  }