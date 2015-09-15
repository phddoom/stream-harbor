{-# LANGUAGE OverloadedStrings, RankNTypes, DeriveDataTypeable, TypeFamilies #-}

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
import Control.Concurrent

getNick :: [User] -> Text -> Text
getNick us id = userNick $ fromJust $ find (\u -> (show $ userId u) == (T.unpack id)) us

getAvatar :: [User] -> Text -> Text
getAvatar us id = userAvatar $ fromJust $ find (\u -> (show $ userId u) == (T.unpack id)) us

createWindow :: FlowdockClient(UserAuth)-> [User] -> Flow -> IORef [Event] -> SignalKey( IO ()) -> IO (ObjRef ())
createWindow client users f messagesVar changeKey = do
    messageClass <- newClass [
        defPropertyRO' "content" (\m -> return $ messageContent $ eventContent $ fromObjRef m),
        defPropertyRO' "nick" (\m -> return $ getNick users $ fromJust $ eventUserId $ fromObjRef m),
        defPropertyRO' "avatar" (\m -> return $ getAvatar users $ fromJust $ eventUserId $ fromObjRef m)]
    messagePool <- newFactoryPool (newObject messageClass)
    rootClass <- newClass [
        defPropertySigRO' "messages" changeKey (\_ -> do
            messages <- readIORef messagesVar
            mapM (getPoolObject messagePool) messages),
        defMethod' "sendChatMessage" (\obj txt -> do
            response <- sendMessage client (message f txt)
            putStrLn $ show response
            return ())]
    newObject rootClass ()

main :: IO ()
main = do
  (authToken:args) <- getArgs
  withFlowdockClient (UserAuth $ T.pack authToken) $ \client -> do
    let f = QualifiedFlow{flowOrganization = "mobiwm", flowFlow = "romper-room"}
    users <- listUsers client
    m <- listMessages client f
    messages <- newIORef m
    changeKey <- newSignalKey
    ctx <- createWindow client users f messages changeKey
    forkOS $ forever $ do
        threadDelay 3000000
        m' <- listMessages client f
        writeIORef messages m'
        fireSignal changeKey ctx
    runEngineLoop defaultEngineConfig {
         initialDocument = fileDocument "chat.qml",
         contextObject = Just $ anyObjRef ctx}
