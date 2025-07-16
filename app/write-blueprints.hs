module Main (main) where

import Prelude
import PlutusTx.Blueprint
import Paths_andamio_blueprints (getDataFileName)
import Index.Compiled

main :: IO ()
main = do
  pathI <- getDataFileName "index.plutus"
  writeBlueprint pathI indexContractBlueprint
      