-- | Haskell re-implementation of [cfn_flip](https://github.com/awslabs/aws-cfn-template-flip/blob/837aa56e21cb00b1c7fa0150f0fd38365c508e4e/cfn_flip/yaml_dumper.py)
module CfnFlip
  ( yamlFileToJson
  , yamlToJson
  , jsonToYamlFile
  , jsonFileToYaml
  , jsonToYaml

  -- * Useful in test suite too
  , eitherDecodeFileStrictThrow
  ) where

import RIO

import qualified CfnFlip.JsonToYaml as JsonToYaml
import qualified CfnFlip.Yaml as Yaml
import qualified CfnFlip.YamlToJson as YamlToJson
import Data.Aeson

yamlFileToJson :: (MonadIO m, FromJSON a) => FilePath -> m a
yamlFileToJson = yamlToJson <=< readFileBinary

yamlToJson :: (MonadIO m, FromJSON a) => ByteString -> m a
yamlToJson = Yaml.decode YamlToJson.translate

jsonToYamlFile :: (MonadUnliftIO m, ToJSON a) => FilePath -> a -> m ()
jsonToYamlFile path = writeFileBinary path <=< jsonToYaml

-- | NB Conversion occurs at 'Value'
jsonFileToYaml :: MonadUnliftIO m => FilePath -> m ByteString
jsonFileToYaml = jsonToYaml @_ @Value <=< eitherDecodeFileStrictThrow

jsonToYaml :: (MonadUnliftIO m, ToJSON a) => a -> m ByteString
jsonToYaml = Yaml.encode JsonToYaml.translate

eitherDecodeFileStrictThrow :: (MonadIO m, FromJSON a) => FilePath -> m a
eitherDecodeFileStrictThrow path = do
  result <- liftIO $ eitherDecodeFileStrict path
  either throwString pure result
