module CfnFlip.Aeson
  ( eitherDecodeFileStrictThrow
  , module Data.Aeson
  ) where

import CfnFlip.Prelude

import Data.Aeson

eitherDecodeFileStrictThrow :: (MonadIO m, FromJSON a) => FilePath -> m a
eitherDecodeFileStrictThrow path = do
  result <- liftIO $ eitherDecodeFileStrict path
  either throwString pure result
