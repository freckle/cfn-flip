module CfnFlip.Aeson
  ( eitherDecodeFileStrictThrow
  , module Data.Aeson
  ) where

import RIO

import Data.Aeson

eitherDecodeFileStrictThrow :: (MonadIO m, FromJSON a) => FilePath -> m a
eitherDecodeFileStrictThrow path = do
  result <- liftIO $ eitherDecodeFileStrict path
  either throwString pure result
