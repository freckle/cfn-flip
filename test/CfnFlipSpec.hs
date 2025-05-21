module CfnFlipSpec
  ( spec
  ) where

import CfnFlip.Prelude

import CfnFlip
import CfnFlip.Aeson (Value, eitherDecodeFileStrictThrow)
import CfnFlip.Conduit
import qualified CfnFlip.JsonToYaml as JsonToYaml
import qualified CfnFlip.YamlToJson as YamlToJson
import System.FilePath ((-<.>))
import System.FilePath.Glob (globDir1)
import Test.Hspec
import qualified Text.Libyaml as Libyaml

spec :: Spec
spec = do
  yamls <- runIO $ globDir1 "*.yaml" "test/examples"
  jsons <- runIO $ globDir1 "*.json" "test/examples"

  describe "yaml-to-json" $ do
    for_ yamls $ \yaml -> do
      it yaml $ do
        when (yaml == "test/examples/test_json_data.yaml")
          $ pendingWith
            "Converting Scalar strings of JSON to actual Mapping objects"

        actual <- yamlFileToJson @_ @Value yaml
        expected <- eitherDecodeFileStrictThrow @_ @Value $ yaml -<.> "json"
        actual `shouldBe` expected

  describe "json-to-yaml-to-json" $ do
    for_ jsons $ \json -> do
      it json $ do
        actual <- yamlToJson =<< jsonFileToYaml json
        expected <- eitherDecodeFileStrictThrow @_ @Value json
        actual `shouldBe` expected

  describe "yaml-to-json-to-yaml" $ do
    for_ yamls $ \yaml -> do
      it yaml $ do
        expected <-
          runResourceT $ runConduit $ Libyaml.decodeFile yaml .| sinkList
        actual <-
          runConduit
            $ sourceList expected
              .| YamlToJson.translate
              .| JsonToYaml.translate
              .| sinkList

        actual `shouldBe` expected
