{- import           Data.Bits ( Bits((.&.), shiftR, popCount) )
import GHC.Data.Maybe (fromJust)
import Data.List (find)



toBool :: Int -> Bool
toBool = (== 1)



normalizeList ::  Show a =>  a -> Int -> [a] -> [a]
normalizeList x targetLen xs
  | len == targetLen = xs
  | len < targetLen = replicate (targetLen - len) x ++ xs
  | otherwise = error $ "list too big" ++ show xs ++ "  " ++ show targetLen 
  where
      len = length xs


toBitList ::  Int -> [Bool]
toBitList 0 = []
toBitList c = toBitList (c `shiftR` 1) ++ [toBool(c .&. 1)]

count :: Eq a => a -> [a] -> Int
count x = length . filter (x==)


zipWithNotEq :: (Eq a) => [a] -> [a] -> [Bool]
zipWithNotEq = zipWith (/=)


countDifferent :: Eq a => [a] -> [a] -> Int
countDifferent xs0 xs1 = count True (zipWithNotEq xs0 xs1)

countBitListDifference :: [Bool] -> [Bool] -> Int
countBitListDifference xs0 xs1 = countDifferent xs1n xs0n
    where
        xs0n = normalize xs0
        xs1n = normalize xs1
        normalize = normalizeList False commonLen
        commonLen = max (length  xs0) (length xs1)


 

pFromStartAndDmin :: Int -> Int -> [Int]
pFromStartAndDmin start dmin =  found : pFromStartAndDmin found dmin 
    where
        found = fromJust $ find (\x -> countBitListDifference  (toBitList x) (toBitList start) >= dmin) [start..]


pFromStartDminAndWmin :: Int -> Int -> Int -> [Int]
pFromStartDminAndWmin start dmin wmin = filter (\x -> weight x >= wmin) $ pFromStartAndDmin start dmin


weight :: (Bits a) => a -> Int
weight = popCount




matrixGen ::  (Int -> Int -> a) -> Int -> Int -> [[a]]
matrixGen filler cols rows  = [[filler i j | j <- [1..cols] ] | i <- [1..rows]]

d :: Int -> Int -> [[Bool]]
d cols rows = take rows $ map (normalizeList False cols . toBitList) (pFromStartDminAndWmin 0 3 2)

p :: Int -> [[Bool]]
p rows = matrixGen (==) rows rows


g :: Int -> Int -> [[Bool]]
g cols rows  = catMatrices (d (cols - rows) rows) $ p rows


catMatrices :: [[a]] -> [[a]] -> [[a]]
catMatrices = zipWith (++)

-- r - число корректирующих битов
r :: Int -> Int
r = ceiling . (+1) . logBase 2 . fromIntegral
-- k - число битов полезной нагрузки

printLineByLine :: Show a => [a] -> IO ()

printLineByLine (x:xs)  = do
    print x
    printLineByLine xs


main :: IO ()
main = printLineByLine $ hammingMatrix 4

hammingMatrix :: Int -> [[Bool]]
hammingMatrix k = g (r k + k) k



 -}