module Andamio.Utility.ValidatorOnChainNames
    ( indexTokenName
    , indexTokenNameBd
    , indexScriptsOnChainName
    , indexScriptsOnChainNameBd
    , assignmentValidatorOnChainName
    , moduleScriptsOnChainName
    , localStateScriptsOnChainName
    , localStateScriptsOnChainNameBd
    , globalStateOnChainName
    , globalStateOnChainNameBd
    , courseGovOnChainName
    , instanceScriptsOnChainName
    , courseNftOnChainName
    , instanceProviderOnChainName
    , contributorStateScriptsOnChainName
    , contributorStateScriptsOnChainNameBd
    , treasuryScriptsOnChainName
    , treasuryScriptsOnChainNameBd
    , treasuryTokensOnChainName
    , escrow1OnChainName
    , escrow1OnChainNameBd
    , projectNftOnChainName
    , adaTokenBd
    , adaSymbolBd
    ) where

import           PlutusLedgerApi.V3         (TokenName(..), BuiltinData)
import           PlutusTx.Builtins.Internal (mkB)

{-# INLINEABLE adaSymbolBd #-}
adaSymbolBd :: BuiltinData
adaSymbolBd = mkB ""

{-# INLINEABLE adaTokenBd #-}
adaTokenBd :: BuiltinData
adaTokenBd = mkB ""

----- ##### Index ##### -----

{-# INLINEABLE indexTokenName #-}
indexTokenName :: TokenName 
indexTokenName = TokenName " "

{-# INLINEABLE indexTokenNameBd #-}
indexTokenNameBd :: BuiltinData 
indexTokenNameBd = mkB " "

{-# INLINEABLE indexScriptsOnChainName #-}
indexScriptsOnChainName :: TokenName 
indexScriptsOnChainName = TokenName "IndexScripts"

{-# INLINEABLE indexScriptsOnChainNameBd #-}
indexScriptsOnChainNameBd :: BuiltinData 
indexScriptsOnChainNameBd = mkB "IndexScripts"

----- ##### Global State ##### -----

{-# INLINEABLE globalStateOnChainNameBd #-}
globalStateOnChainNameBd :: BuiltinData
globalStateOnChainNameBd = mkB "GlobalStateValidator"

{-# INLINEABLE globalStateOnChainName #-}
globalStateOnChainName :: TokenName
globalStateOnChainName = TokenName "GlobalStateValidator"

----- ##### Course ##### -----

{-# INLINEABLE assignmentValidatorOnChainName #-}
assignmentValidatorOnChainName :: TokenName 
assignmentValidatorOnChainName = TokenName "AssignmentValidator"

{-# INLINEABLE moduleScriptsOnChainName #-}
moduleScriptsOnChainName :: TokenName 
moduleScriptsOnChainName = TokenName "ModuleScripts"

{-# INLINEABLE localStateScriptsOnChainNameBd #-}
localStateScriptsOnChainNameBd :: BuiltinData 
localStateScriptsOnChainNameBd = mkB "CourseStateScripts"

{-# INLINEABLE localStateScriptsOnChainName #-}
localStateScriptsOnChainName :: TokenName 
localStateScriptsOnChainName = TokenName "CourseStateScripts"

{-# INLINEABLE courseNftOnChainName #-}
courseNftOnChainName :: TokenName
courseNftOnChainName = TokenName "CourseNFT"

----- ##### Project ##### -----

{-# INLINEABLE contributorStateScriptsOnChainNameBd #-}
contributorStateScriptsOnChainNameBd :: BuiltinData
contributorStateScriptsOnChainNameBd = mkB "ContributorStateScripts"

{-# INLINEABLE contributorStateScriptsOnChainName #-}
contributorStateScriptsOnChainName :: TokenName
contributorStateScriptsOnChainName = TokenName "ContributorStateScripts"

{-# INLINEABLE treasuryScriptsOnChainNameBd #-}
treasuryScriptsOnChainNameBd :: BuiltinData
treasuryScriptsOnChainNameBd = mkB "TreasuryScripts"

{-# INLINEABLE treasuryScriptsOnChainName #-}
treasuryScriptsOnChainName :: TokenName
treasuryScriptsOnChainName = TokenName "TreasuryScripts"

{-# INLINEABLE treasuryTokensOnChainName #-}
treasuryTokensOnChainName :: TokenName
treasuryTokensOnChainName = TokenName "TreasuryToken"

{-# INLINEABLE escrow1OnChainNameBd #-}
escrow1OnChainNameBd :: BuiltinData
escrow1OnChainNameBd = mkB "Escrow1"

{-# INLINEABLE escrow1OnChainName #-}
escrow1OnChainName :: TokenName
escrow1OnChainName = TokenName "Escrow1"

{-# INLINEABLE projectNftOnChainName #-}
projectNftOnChainName :: TokenName
projectNftOnChainName = TokenName "ProjectNFT"

----- ##### Instance ##### -----

{-# INLINEABLE courseGovOnChainName #-}
courseGovOnChainName :: TokenName 
courseGovOnChainName = TokenName "GovernanceValidator"

{-# INLINEABLE instanceScriptsOnChainName #-}
instanceScriptsOnChainName :: TokenName 
instanceScriptsOnChainName = TokenName "InstanceScripts"

{-# INLINEABLE instanceProviderOnChainName #-}
instanceProviderOnChainName :: TokenName 
instanceProviderOnChainName = TokenName "InstanceProvider"