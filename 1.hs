import Data.Bits ( Bits((.&.), shiftR) )
import qualified Data.Char as Char (toLower)
import qualified Data.Map.Lazy as Map (fromListWith, map, toList)
import Data.Word ()
import Text.Printf ( printf )

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
probs xs = map (prob' xs) xs where prob' a b = prob b a


toAsciiCodes :: String -> [Int]
toAsciiCodes = map fromEnum


toBitLists :: String -> [[Bool]]
toBitLists = map (normalizeBitList . toBitList)

normalizeBitList :: [Bool] -> [Bool]

normalizeBitList xs
  | len == 8 = xs
  | len < 8 = replicate (8 - len) False ++ xs
  | otherwise = error "list too big"
  where
      len = length xs

toBitList :: Char -> [Bool]
toBitList '\0' = []
toBitList c = toBitList (toEnum(fromEnum c `shiftR` 1) :: Char) ++ [toBool(fromEnum c .&. 1)]


toCharList :: [Bool] -> [Char]
toCharList = map (\a -> if a then '1' else '0')


toBool :: Int -> Bool
toBool 0 = False
toBool _ = True

toFlatBitList :: String -> [Bool]
toFlatBitList xs = concat $ toBitLists xs


countChars :: String -> [CharCount]
countChars text = Prelude.map toCharCount $ Map.toList $ Map.fromListWith (+) [(c, 1) | c <- text] where toCharCount (a, b) = CharCount a b


shenon :: [CharCount] -> Float

shenon xs = -sum (map probmult $ probs xs) where probmult a = a * logBase 2 a

hartley :: [Char] -> Float
hartley xs = logBase 2 $ fromIntegral $ length xs

filterNonAlphabet :: String -> [Char] -> String
filterNonAlphabet text alphabet = filter (`elem` alphabet) $ map Char.toLower text




informationAmount :: Float -> Int -> Float
informationAmount entropy textLen = entropy * fromIntegral textLen

coalesce :: Float -> Float -> Float
coalesce x y = if isNaN x || isInfinite x then y else x

conditionalEntropy :: Float -> Float
conditionalEntropy p = -(p * coalesce (logBase 2 p) 0) - (q * coalesce (logBase 2 q) 0) where q = 1 - p


effectiveEntropy :: Float -> Float -> Float
effectiveEntropy entropy conditionalEntropy = entropy - conditionalEntropy

main :: IO ()
main = do
    englishText <- readFile "holocaust.txt"

--a
    let filtered = filterNonAlphabet englishText ['a'..'z']
    print filtered

    let englishCharCount = countChars filtered

    print englishCharCount

    let englishEntropy = shenon englishCharCount

    printf "English entropy %f\n" englishEntropy

--b
    let bitText = toCharList $ toFlatBitList filtered

    let bitCharCount = countChars bitText
    let bitEntropy = shenon bitCharCount

    printf "Binary entropy %f\n" bitEntropy
--c
    let name = "Tumash Stanislav Igorevich"

    let englishLen = length name
    let engInfoAmount entropy = informationAmount entropy englishLen

    let englishInformationAmount = engInfoAmount englishEntropy

    printf "English information amount %f\n" englishInformationAmount

    let bitLen = englishLen * 8
    let bitInfoAmount entropy = informationAmount entropy bitLen

    let bitInformationAmount = bitInfoAmount bitEntropy

    printf "Binary information amount %f\n" bitInformationAmount

--d

    let p0 = 0.1
    let p1 = 0.5
    let p2 = 1

    let conditionalEntropy0 = conditionalEntropy p0
    let conditionalEntropy1 = conditionalEntropy p1
    let conditionalEntropy2 = conditionalEntropy p2

    let effectiveEnglishEntropy0 = effectiveEntropy englishEntropy conditionalEntropy0
    let effectiveEnglishEntropy1 = effectiveEntropy englishEntropy conditionalEntropy1
    let effectiveEnglishEntropy2 = effectiveEntropy englishEntropy conditionalEntropy2

    let englishInformationAmount0 = engInfoAmount effectiveEnglishEntropy0
    let englishInformationAmount1 = engInfoAmount effectiveEnglishEntropy1
    let englishInformationAmount2 = engInfoAmount effectiveEnglishEntropy2

    let englishFormatString = "English information amount (p = %f): %f\n"

    printf englishFormatString p0 englishInformationAmount0
    printf englishFormatString p1 englishInformationAmount1
    printf englishFormatString p2 englishInformationAmount2


    let effectiveBitEntropy0 = effectiveEntropy bitEntropy conditionalEntropy0
    let effectiveBitEntropy1 = effectiveEntropy bitEntropy conditionalEntropy1
    let effectiveBitEntropy2 = effectiveEntropy bitEntropy conditionalEntropy2

    let bitInformationAmount0 = bitInfoAmount effectiveBitEntropy0
    let bitInformationAmount1 = bitInfoAmount effectiveBitEntropy1
    let bitInformationAmount2 = bitInfoAmount effectiveBitEntropy2


    let bitFormatString = "English information amount (p = %f): %f\n"

    printf bitFormatString p0 bitInformationAmount0
    printf bitFormatString p1 bitInformationAmount1
    printf bitFormatString p2 bitInformationAmount2





 