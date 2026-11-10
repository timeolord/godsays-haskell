module Main where

import Bible (godphrases)
import Control.Monad (unless)
import qualified Data.ByteString as BS
import qualified Data.ByteString.UTF8 as BSU
import Data.List (isInfixOf, isPrefixOf)
import EmbeddedBible (bible_table)
import VerseTable (lookup_verse)

assert_equal :: (Eq a, Show a) => String -> a -> a -> IO ()
assert_equal label expected actual = unless (expected == actual) $
  error (label ++ ": expected " ++ show expected ++ ", got " ++ show actual)

split_fields :: String -> [String]
split_fields row = case break (== '\t') row of
  (field, '\t' : rest) -> field : split_fields rest
  (field, _) -> [field]

source_references :: [String] -> [(String, String)]
source_references [book, first, final, source, _] =
  case (break (== ':') first, break (== ':') final) of
    ((chapter, ':' : start), (last_chapter, ':' : end)) | chapter == last_chapter ->
      [(unwords [book, chapter ++ ":" ++ show verse], source) | verse <- [read start :: Int .. read end]]
    _ -> error "invalid source range"
source_references _ = error "invalid source fields"

main :: IO ()
main = do
  assert_equal "empty input" [] (godphrases BS.empty)
  assert_equal "whitespace" [] (godphrases $ BSU.fromString " \n\t ")
  assert_equal "wrapped and inline verses"
    [ "Genesis 1:1 In the beginning."
    , "Genesis 1:2 Wrapped text with 123 and a colon: here."
    , "Genesis 2:1 Next chapter."
    , "Exodus 1:1 Next book’s opening."
    ]
    (godphrases $ BSU.fromString "1:1 In the\nbeginning.\n\n1:2 Wrapped text with 123 and a colon: here. 2:1 Next chapter.\n\n1:1 Next book’s opening.")
  assert_equal "preserve source typography"
    ["Genesis 1:1 said ſaid against bleſſed his Spirit s's s’s ⁊ ye."]
    (godphrases $ BSU.fromString "1:1 said ſaid against bleſſed his Spirit s's s’s ⁊ ye.")
  verses <- godphrases <$> BS.readFile "app/bible.txt"
  assert_equal "compiled lookup preserves every verse" verses
    [BSU.toString $ lookup_verse bible_table index | index <- [0 .. toInteger (length verses) - 1]]
  assert_equal "compiled lookup wraps" (head verses)
    (BSU.toString $ lookup_verse bible_table $ toInteger $ length verses)
  assert_equal "compiled lookup accepts negative seeds" (last verses)
    (BSU.toString $ lookup_verse bible_table (-1))
  assert_equal "compiled lookup accepts large timestamps" (verses !! fromInteger (86400000000000000 `mod` toInteger (length verses)))
    (BSU.toString $ lookup_verse bible_table 86400000000000000)
  let openings = filter (isInfixOf " 1:1 ") verses
  assert_equal "verse count" 31102 (length verses)
  assert_equal "book count" 66 (length openings)
  assert_equal "first verse"
    "Genesis 1:1 IN the beginning God created the Heauen, and the Earth."
    (head verses)
  assert_equal "1611 spelling and long s"
    "Genesis 1:2 And the earth was without forme, and voyd; and darkeneſſe was vpon the face of the deepe: and the Spirit of God mooued vpon the face of the waters."
    (verses !! 1)
  assert_equal "last verse"
    "Revelation 22:21 The grace of our Lord Ieſus Chriſt be with you all. Amen."
    (last verses)
  assert_equal "numbered book" True ("1 Samuel 1:1 " `isPrefixOf` (openings !! 8))
  assert_equal "multiword book" True ("Song of Solomon 1:1 " `isPrefixOf` (openings !! 21))
  assert_equal "new testament boundary" True ("Matthew 1:1 " `isPrefixOf` (openings !! 39))
  assert_equal "final book" True ("Revelation 1:1 " `isPrefixOf` last openings)
  assert_equal "scan pages fill the missing revelation book page"
    ["Revelation 21:22 And I ſaw no Temple therein: For the Lord God Almightie, and the Lambe, are the Temple of it."]
    (filter (isPrefixOf "Revelation 21:22 ") verses)
  assert_equal "preserve short s in the wikisource transcription" True
    (any (\verse -> "Obadiah 1:1 " `isPrefixOf` verse && "against her" `isInfixOf` verse) verses)
  assert_equal "complete a partial verse without duplicate punctuation"
    ["Matthew 6:22 The light of the body is the eye: If therefore thine eye be ſingle, thy whole body ſhalbe full of light."]
    (filter (isPrefixOf "Matthew 6:22 ") verses)
  assert_equal "reconstruction fills an unavailable book"
    ["Exodus 1:1 Nowe theſe are the names of the children of Iſrael, which came into Egypt, euery man & his houſehold, came with Iacob."]
    (filter (isPrefixOf "Exodus 1:1 ") verses)
  sources <- lines . BSU.toString <$> BS.readFile "app/bible-sources.tsv"
  assert_equal "source header" ["book\tfirst\tlast\tsource\turls"] (take 1 sources)
  let references = concatMap (source_references . split_fields) (drop 1 sources)
  assert_equal "source coverage" (length verses) (length references)
  assert_equal "source order and verse references" True
    (and $ zipWith (\(reference, _) verse -> (reference ++ " ") `isPrefixOf` verse) references verses)
  assert_equal "wikisource verses" 1442 (length $ filter ((== "wikisource") . snd) references)
  assert_equal "partially reconstructed verses" 4 (length $ filter ((== "mixed") . snd) references)
  assert_equal "reconstructed verses" 29656 (length $ filter ((== "reconstructed") . snd) references)
  assert_equal "no import artifacts" False
    (any (\verse -> any (`isInfixOf` verse) ["CHAP.", "Page:", "An image should", "{{", "::"]) verses)
  putStrLn "all bible tests passed"
