-- | Haskell re-implementation of [cfn_flip](https://github.com/awslabs/aws-cfn-template-flip/blob/837aa56e21cb00b1c7fa0150f0fd38365c508e4e/cfn_flip/yaml_dumper.py)
module CfnFlip
  ( yamlFileToJson
  , yamlToJson
  , jsonToYamlFile
  , jsonFileToYaml
  , jsonToYaml
  ) where

import RIO

import CfnFlip.Aeson
import qualified CfnFlip.JsonToYaml as JsonToYaml
import qualified CfnFlip.Yaml as Yaml
import qualified CfnFlip.YamlToJson as YamlToJson

-- | Read a file of Yaml and produce a @'FromJSON' a@
yamlFileToJson :: (MonadIO m, FromJSON a) => FilePath -> m a
yamlFileToJson = yamlToJson <=< readFileBinary

-- | Convert a 'ByteString' of Yaml to a @'FromJSON' a@
yamlToJson :: (MonadIO m, FromJSON a) => ByteString -> m a
yamlToJson = Yaml.decode YamlToJson.translate

-- | Write a @'ToJSON a@ to a file as Yaml
jsonToYamlFile :: (MonadUnliftIO m, ToJSON a) => FilePath -> a -> m ()
jsonToYamlFile path = writeFileBinary path <=< jsonToYaml

-- | Read a file of JSON and produce a 'ByteString' of Yaml
--
-- NB. The conversion occurs at 'Value'.
--
jsonFileToYaml :: MonadUnliftIO m => FilePath -> m ByteString
jsonFileToYaml = jsonToYaml @_ @Value <=< eitherDecodeFileStrictThrow

-- | Convert a 'ToJSON a' to a 'ByteString' of Yaml
jsonToYaml :: (MonadUnliftIO m, ToJSON a) => a -> m ByteString
jsonToYaml = Yaml.encode JsonToYaml.translate

