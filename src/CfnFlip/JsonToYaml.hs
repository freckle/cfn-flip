module CfnFlip.JsonToYaml
  ( InvalidYamlEvent (..)
  , translate
  ) where

import CfnFlip.Prelude

import CfnFlip.Conduit
import CfnFlip.IntrinsicFunction
import CfnFlip.Libyaml

translate :: MonadIO m => ConduitT Event Event m ()
translate = awaitForever $ \e -> do
  mS <- peekC

  case (e, mS) of
    (EventMappingStart {}, Just s@EventScalar {})
      | Just tag <- fromIntrinsicFunction s -> do
          dropC 1 -- Scalar
          await
            >>= traverse_
              ( \case
                  i | tag == "!GetAtt" -> do
                    (resource, attribute) <- awaitGetAtt i
                    let key = resource <> "." <> attribute
                    yield $ EventScalar key (UriTag tag) SingleQuoted Nothing
                  i -> do
                    yield $ setIntrinsicFunction tag i
                    when (startsMapOrSequence i) $ takeMapOrSequenceC i .| translate
              )

          dropC 1 -- MappingEnd
    _ -> yield e

awaitGetAtt
  :: MonadIO m => Event -> ConduitT Event Event m (ByteString, ByteString)
awaitGetAtt e = do
  results <- sequence [await, await, await]

  case results of
    [ Just (EventScalar r _ _ _)
      , Just (EventScalar a _ _ _)
      , Just EventSequenceEnd {}
      ] ->
      pure (r, a)
    _ ->
      throwIO
        $ InvalidYamlEvent e
        $ "Unexpected GetAtt. Should be two Scalars and a SequenceEnd, saw: "
          <> show results
