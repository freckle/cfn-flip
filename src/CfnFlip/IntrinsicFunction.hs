module CfnFlip.IntrinsicFunction
  ( getIntrinsicFunction
  , setIntrinsicFunction
  , fromIntrinsicFunction
  ) where

import CfnFlip.Prelude

import CfnFlip.Libyaml (Event (..), Tag (..))

-- | If an 'Event' is using a known @"!X"@, returns the @"Fn::Y"@ for it
getIntrinsicFunction :: Event -> Maybe ByteString
getIntrinsicFunction = \case
  EventScalar _ (UriTag t) _ _ -> lookup t intrinsics
  EventMappingStart (UriTag t) _ _ -> lookup t intrinsics
  EventSequenceStart (UriTag t) _ _ -> lookup t intrinsics
  _ -> Nothing

-- | Set an 'Event' up with a @'UriTag' "!X"@
setIntrinsicFunction :: String -> Event -> Event
setIntrinsicFunction tag e = fromMaybe e $ do
  let t = UriTag tag

  case e of
    EventScalar x _ y z -> Just $ EventScalar x t y z
    EventMappingStart _ x y -> Just $ EventMappingStart t x y
    EventSequenceStart _ x y -> Just $ EventSequenceStart t x y
    _ -> Nothing

fromIntrinsicFunction :: Event -> Maybe String
fromIntrinsicFunction = \case
  EventScalar x _ _ _ -> lookup x swappedIntrinsics
  _ -> Nothing

intrinsics :: [(String, ByteString)]
intrinsics =
  map
    toFn
    [ "And"
    , "Base64"
    , "Cidr"
    , "Equals"
    , "FindInMap"
    , "GetAtt"
    , "GetAZs"
    , "If"
    , "ImportValue"
    , "Join"
    , "Not"
    , "Or"
    , "Ref"
    , "Select"
    , "Split"
    , "Sub"
    , "Transform"
    ]
 where
  toFn x
    | x == "Ref" = ("!" <> unpack x, encodeUtf8 x)
    | otherwise = ("!" <> unpack x, "Fn::" <> encodeUtf8 x)

swappedIntrinsics :: [(ByteString, String)]
swappedIntrinsics = map swap intrinsics
 where
  swap :: (a, b) -> (b, a)
  swap (a, b) = (b, a)
