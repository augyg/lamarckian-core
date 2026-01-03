{-# LANGUAGE PackageImports #-}
module Lamarckian.Types where

import Obelisk.Route.Frontend
import Reflex.Dom.Core
import Control.Monad.Trans.Reader
import qualified Data.Map as Map
import qualified Data.Text as T
import "template-haskell" Language.Haskell.TH

type GroupKey = String

type StaticDom = PostBuildT DomTimeline (StaticDomBuilderT DomTimeline (PerformEventT DomTimeline DomHost))

type StaticPackagePath = FilePath

-- | In theory we could make the r of ReaderT generic 
newtype TemplateT m a = TemplateT { runTemplateT :: ReaderT TemplateVars m a }
-- | In generic impl. that would mean `templateSlot :: (r -> a) -> TemplateT a ~~~ asks`
-- | Further, we could also have a templateFileSlot function 
type Name = String
type StaticWidget' r x a = SetRouteT (SpiderTimeline Global) (R r) (RouteToUrlT (R r) (StaticWidget x)) a
type TemplateVars = Map.Map String String
type SlotKey = String

-- | The key allows for arbitrary retrieval of a Template group  
type HTemplateVars k a = Map.Map k [(SlotKey, HtmlString, a)]
-- | for example, lets say we are writing an email with multiple sections which require non-escaped Raw Strings (ie html)
-- |
-- | do 
-- |   let tmplMap = fromList [( 1, sectionOneVars), (2, sectionTwoVars)]
-- |   renderSectionOne (Map.lookupWithDefault [] 1 tmplMap) 
-- |   renderSectionTwo (Map.lookupWithDefault [] 2 tmplMap)
-- |
-- | Thus, this data structure allows for an arbitrary number of DomBuilders 
type HTemplateRefs k a = Map.Map k [(SlotKey, a)]

-- | Once the DOM has been rendered, all we need are our globally unique IDs + vals
type HTemplateValues = Map.Map SlotKey (HtmlString) 

newtype HtmlString = HtmlString { getHtml :: T.Text }


data Promised = NotDone | DoneFailed Reason | DoneSuccess
type Reason = String

data CouldWrite = CanWriteFile FilePath | FailedWriteFile deriving Show

type URL = T.Text
type CompiledFilePath = Q Exp

data StaticSite r = StaticSite
  { _staticSite_baseWritableFolder :: FilePath
  -- ^ the prefix not included in staticFilePath's argument
  , _staticSite_staticFilePath  :: FilePath -> CompiledFilePath
  -- ^ Your obelisk generated staticFilePath function
  , _staticSite_routeEncoder :: R r -> URL
  -- ^ In the simplest of cases, this is just simply rendering the route
  -- ie. (<rendered-route>|"root" if nothing).html
  , _staticSite_subFolder :: Maybe FilePath
  -- ^ Allows for configuring cases like
  -- baseWritableFolder/<subFolder>/filepathFromRoute
  , _staticSite_localHint :: IO Bool
  -- ^ Flag for whether or not to get file directly from
  -- where it was written, which only works if local.
  }

