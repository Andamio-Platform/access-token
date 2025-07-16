{-# LANGUAGE LambdaCase #-}

module Index.Compiled
    ( indexContractBlueprint
    ) where

import Data.Set as Set

import Index.OnChain.IndexScripts      (IndexParams(..), indexValidatorCompiledCode)
import Index.OnChain.InitIndexPolicy   (initIndexPolicyCompiledCode)
import Index.OnChain.IndexRefScript    (IndexRefParams(..), indexRefValidatorCompiledCode, 
                                       IndexData(..))
import Andamio.Utility.OnChain         (FlatValue(..))
import PlutusTx.Blueprint
import PlutusTx.Prelude
import Data.ByteString.Short           (fromShort)
import PlutusLedgerApi.V3

indexContractBlueprint :: ContractBlueprint
indexContractBlueprint =
  MkContractBlueprint
    { contractId = Nothing
    , contractPreamble = indexPreamble
    , contractValidators = Set.fromList [ indexValidatorBlueprint
                                        , initIndexPolicyBlueprint
                                        , indexRefValidatorBlueprint
                                        ]
    , contractDefinitions =
        deriveDefinitions
          @[ IndexParams
           , IndexRefParams
           , BuiltinData
           , IndexData
           , FlatValue
           ]
    }

indexPreamble :: Preamble
indexPreamble = MkPreamble 
          { preambleTitle = "Index Scripts"
          , preambleDescription = Just "A set of scripts validating an on chain linked list."
          , preambleVersion = "1.0.0"
          , preamblePlutusVersion = PlutusV3
          , preambleLicense = Nothing
          }

indexValidatorBlueprint :: ValidatorBlueprint referenceTypes
indexValidatorBlueprint = MkValidatorBlueprint
  { validatorTitle       = "Index_Scripts"
  , validatorDescription = Just "Validator that handles a on chain linked list."
  , validatorRedeemer    = MkArgumentBlueprint Nothing Nothing (Set.singleton Spend) (SchemaBytes emptySchemaInfo emptyBytesSchema)
  , validatorDatum       = Nothing
  , validatorParameters  = [ MkParameterBlueprint
            { parameterTitle = Nothing
            , parameterDescription = Nothing
            , parameterPurpose = Set.fromList [Spend, Withdraw, Mint]
            , parameterSchema = definitionRef @IndexParams
            }
        ]
  , validatorCompiled    = Just $ compiledValidator PlutusV3 (fromShort $ serialiseCompiledCode indexValidatorCompiledCode)
  }

initIndexPolicyBlueprint :: ValidatorBlueprint referenceTypes
initIndexPolicyBlueprint = MkValidatorBlueprint
  { validatorTitle       = "Init_Index_Policy"
  , validatorDescription = Just "Minting policy to initialise the linked list by setting boarders."
  , validatorRedeemer    = MkArgumentBlueprint Nothing Nothing (Set.singleton Spend) (SchemaBytes emptySchemaInfo emptyBytesSchema)
  , validatorDatum       = Nothing
  , validatorParameters  = [ MkParameterBlueprint
            { parameterTitle = Nothing
            , parameterDescription = Nothing
            , parameterPurpose = Set.fromList [Mint]
            , parameterSchema = definitionRef @BuiltinData
            }
        ]
  , validatorCompiled    = Just $ compiledValidator PlutusV3 (fromShort $ serialiseCompiledCode initIndexPolicyCompiledCode)
  }

indexRefValidatorBlueprint :: ValidatorBlueprint referenceTypes
indexRefValidatorBlueprint = MkValidatorBlueprint
  { validatorTitle       = "Index_Ref"
  , validatorDescription = Just "Validator where reference script for Index_Scripts is stored and has some data like fee in datum."
  , validatorRedeemer    = MkArgumentBlueprint Nothing Nothing (Set.singleton Spend) (SchemaBytes emptySchemaInfo emptyBytesSchema)
  , validatorDatum       = Nothing
  , validatorParameters  = [ MkParameterBlueprint
            { parameterTitle = Nothing
            , parameterDescription = Nothing
            , parameterPurpose = Set.fromList [Spend]
            , parameterSchema = definitionRef @IndexRefParams
            }
        ]
  , validatorCompiled    = Just $ compiledValidator PlutusV3 (fromShort $ serialiseCompiledCode indexRefValidatorCompiledCode)
  }