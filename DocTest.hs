module Main
  ( main
  ) where

import Prelude

import Data.Aeson
import qualified Data.Yaml as Yaml
import Test.DocTest

newtype PackageExtensions = PackageExtensions [String]

instance FromJSON PackageExtensions where
  parseJSON = withObject "PackageExtensions"
    $ \o -> PackageExtensions <$> o .: "default-extensions"

main :: IO ()
main = do
  PackageExtensions extensions <- Yaml.decodeFileThrow "package.yaml"
  doctest $ map ("-X" <>) extensions <> ["src"]
