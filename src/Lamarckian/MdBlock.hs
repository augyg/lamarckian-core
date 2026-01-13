module Lamarckian.MdBlock where

import Data.Text

newtype MdBlock = MdBlock { runMdBlock :: (Text -> Text) -> Text }

instance Semigroup MdBlock where
  md1 <> md2 =  MdBlock $ \mkLocalLink -> (runMdBlock md1) mkLocalLink <> (runMdBlock md2) mkLocalLink

renderMdBlock :: (Text -> Text) -> MdBlock -> Text
renderMdBlock mkLocalLink md = runMdBlock md mkLocalLink

