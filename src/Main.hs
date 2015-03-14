module Main where

import Idris.Core.TT
import Idris.AbsSyntax
import Idris.ElabDecls
import Idris.REPL

import IRTS.Compiler
import IRTS.CodegenEmpty

import System.Environment
import System.Exit

import Paths_idris_c_boehm

data Opts = Opts { inputs :: [FilePath],
                   output :: FilePath }

showUsage = do putStrLn "Usage: idris-c-boehm <ibc-files> [-o <output-file>]"
               exitWith ExitSuccess

getOpts :: IO Opts
getOpts = do xs <- getArgs
             return $ process (Opts [] "a.out") xs
  where
    process opts ("-o":o:xs) = process (opts { output = o }) xs
    process opts (x:xs) = process (opts { inputs = x:inputs opts }) xs
    process opts [] = opts

cg_main :: Opts -> Idris ()
cg_main opts = do elabPrims
                  loadInputs (inputs opts) Nothing
                  mainProg <- elabMain
                  ir <- compile (Via "c-boehm") (output opts) mainProg
                  runIO $ codegenEmpty ir

main :: IO ()
main = do opts <- getOpts
          if (null (inputs opts)) 
             then showUsage
             else runMain (cg_main opts)


