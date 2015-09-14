{-# LANGUAGE OverloadedStrings #-}

module Main where

import Chat.Flowdock
import Graphics.QML
import Control.Monad
import Data.List (find)
import Data.Maybe
import Data.IORef
import Data.Text (Text)
import qualified Data.Text as T
import Control.Monad.ST
import Data.STRef
import System.Environment ( getArgs )

getNick :: [User] -> Text -> Text
getNick us id = userNick $ fromJust $ find (\u -> (show $ userId u) == (T.unpack id)) us

getAvatar :: [User] -> Text -> Text
getAvatar us id = userAvatar $ fromJust $ find (\u -> (show $ userId u) == (T.unpack id)) us

main = do
  (authToken:args) <- getArgs
  withFlowdockClient (UserAuth $ T.pack authToken) $ \client -> do
    let f = QualifiedFlow{flowOrganization = "mobiwm", flowFlow = "romper-room"}
    users <- listUsers client
    {-putStrLn $ show users-}
    messages <- listMessages client f
    messageClass <- newClass [
        defPropertyRO' "content" (\m -> return $ messageContent $ eventContent $ fromObjRef m),
        defPropertyRO' "nick" (\m -> return $ getNick users $ fromJust $ eventUserId $ fromObjRef m),
        defPropertyRO' "avatar" (\m -> return $ getAvatar users $ fromJust $ eventUserId $ fromObjRef m)]
    messagePool <- newFactoryPool (newObject messageClass)
    rootClass <- newClass [
        defPropertyRO' "messages" (\_ ->
            mapM (getPoolObject messagePool) messages),
        defMethod' "sendChatMessage" (\obj txt -> do
            response <- sendMessage client (message f txt)
            putStrLn $ show response
            return ())]
    ctx <- newObject rootClass ()
    runEngineLoop defaultEngineConfig {
         initialDocument = fileDocument "chat.qml",
         contextObject = Just $ anyObjRef ctx}
