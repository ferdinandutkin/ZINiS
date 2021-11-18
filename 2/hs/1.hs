import qualified Data.Char as Char (toLower)
import qualified Data.Map.Lazy as Map (fromListWith, map, toList)
import           Data.Maybe ( fromMaybe )
import           System.Environment (getArgs)
import           Text.Printf ( printf )


data CharCount = CharCount Char Int deriving Show
count :: CharCount -> Int
count (CharCount _ cnt) = cnt

char :: CharCount -> Char
char (CharCount c _) = c

chars :: [CharCount] -> [Char]
chars = map char

counts :: [CharCount] -> [Int]
counts = map count

prob :: CharCount -> [CharCount] -> Float
prob charCount xs = fromIntegral (count charCount) / fromIntegral (sum $ counts xs)

probs :: [CharCount] -> [Float]
probs xs = map (`prob` xs) xs

countChars :: String -> [CharCount]
countChars text = Prelude.map (uncurry CharCount) $ Map.toList $ Map.fromListWith (+) [(c, 1) | c <- text]


shenon :: [CharCount] -> Float
shenon xs = -sum (map (\a -> a * logBase 2 a) $ probs xs)

hartley :: [Char] -> Float
hartley xs = logBase 2 $ fromIntegral $ length xs

safeIndex :: [a] -> Int -> Maybe a
safeIndex xs i
    | (i> -1) && (length xs > i) = Just (xs!!i)
    | otherwise = Nothing


defIndex :: [a] -> Int -> a -> a
defIndex xs i def = Data.Maybe.fromMaybe def $ Main.safeIndex xs i


printShenon :: String -> IO ()
printShenon text = do
    let charCount = countChars text
    let shenonEntropy = shenon charCount
    printf "shenon: %f\n" shenonEntropy

filterNonAlphabet :: String -> [Char] -> String
filterNonAlphabet text alphabet = filter (`elem` alphabet) $ map Char.toLower text

printHartley :: [Char] -> IO ()
printHartley alphabet = do
    printf "alphabet: %s\n" $ show alphabet
    printf "hartley entropy: %f\n" $ hartley alphabet


printRedundancy :: String -> [Char] -> IO ()
printRedundancy text alphabet = do
    printf "redundancy: %f %%\n" $ redundancy text alphabet


printInfo :: [Char] -> String -> IO ()
printInfo fileName alphabet = do
    fileContent <- readFile fileName
    let filtered = filterNonAlphabet fileContent alphabet
    let cnts =  countChars filtered
    print cnts
    print $ probs cnts
    printShenon filtered
    printHartley alphabet
    printRedundancy fileContent alphabet

redundancy :: String -> [Char] -> Float
redundancy text alphabet = (hartleyEntropy - shenon (countChars text) / hartleyEntropy) * 100 where hartleyEntropy = hartley alphabet


main :: IO ()
main = do
    args <- getArgs

    let inputFileName =  defIndex args 0 "input.txt"
    let outputFileName = defIndex args 1 "output.txt"

    let englishAlphabet = ['a'..'z']
    let base64Alphabet = ['A'.. 'Z'] ++  ['a'..'z'] ++ ['0'..'9'] ++ ['+', '/', '=']

    print "English: "
    printInfo inputFileName englishAlphabet


    print "Base64: "
    printInfo outputFileName base64Alphabet




 