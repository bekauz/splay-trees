import Data.List hiding (insert,find)


-- Holds either nothing (leaf) or a node with its left and right subtrees

data Tree a = Leaf | Node (Tree a) a (Tree a)
	deriving (Show)

-- Holds data about the p of node in focus (direction taken & p itself)

data Path a = L a (Tree a) | R a (Tree a)
	deriving (Show)

-- Initialize empty tree

singleton :: a -> Tree a
singleton x = Node (Leaf) x (Leaf)

-- Initialize splay tree

splay :: Tree a -> [Path a] -> Tree a
splay tree [] = tree -- tree with no path to it is a new tree

{------------ Depth = 1 (single rotation over root) cases: ----------------}

-- Node splayed is a LEFT child: ZIG

splay (Node left x right) [L p p_rightChild] =
	Node left x (Node right p p_rightChild)

-- Node splayed is a RIGHT child: ZAG

splay (Node left x right) [R p p_leftChild] =
	Node (Node p_leftChild p left) x right

{--------- Depth >= 2 (double rotation over p/gp) ZIGZIG cases: ----------}

{-- Node splayed is a LEFT child of a LEFT child: --}

splay (Node left x right) (L p p_rightChild : L gp gp_rightChild : path) =
	splay (Node left x (Node right p (Node p_rightChild gp gp_rightChild))) path

{-- Node splayed is a RIGHT child of a RIGHT child: --}

splay (Node left x right) (R p p_leftChild : R gp gp_leftChild : path) =
	splay (Node (Node (Node gp_leftChild gp p_leftChild) p left) x right) path

{---- Depth >= 2 (double rotation over p/gp) ZIGZAG cases: --------}

{-- Node splayed is a RIGHT child of a LEFT child: --}

splay (Node left x right) (R p p_leftChild : L gp gp_rightchild : path) =
	splay (Node (Node p_leftChild p left) x (Node right gp gp_rightchild)) path

{-- Node splayed is a LEFT child of a RIGHT child: --}

splay (Node left x right) (L p p_rightChild : R gp gp_leftChild : path) =
	splay (Node (Node gp_leftChild gp left) x (Node right p p_rightChild)) path

{------------------------- Insertion into tree ---------------------------}

-- Insert value ’a’ into tree and return updated tree

insert :: (Ord a) => a -> Tree a -> Tree a
insert a tree = extendPath a [] tree

-- Insert element and extend path

extendPath :: (Ord a) => a -> [Path a] -> Tree a -> Tree a

-- If tree is empty or we reached a leaf node

extendPath a path Leaf = splay (Node Leaf a Leaf) path

-- If tree isn’t empty: start traversing downwards

extendPath a path (Node left x right)
| x < a = extendPath a ((R x left) : path) right
| x > a = extendPath a ((L x right) : path) left
| otherwise = error "Value already exists in the tree."

{-------------------------- Splay (find) element --------------------------}

find :: (Ord a) => a -> Tree a -> Tree a
find _ Leaf = Leaf

-- Call helper function with empty path

find a tree = findPath a [] tree
findPath :: (Ord a) => a -> [Path a] -> Tree a -> Tree a

-- If x has no children, splay x regardless

findPath a path (Node Leaf x Leaf) = splay (Node Leaf x Leaf) path

-- If x has no bigger children

findPath a path (Node left x Leaf)
| a > x = splay (Node left x Leaf) path
| a < x = findPath a ((L x Leaf) : path) left
| otherwise = splay (Node left x Leaf) path

-- If x has no smaller children

findPath a path (Node Leaf x right)
| a < x = splay (Node Leaf x right) path
| a > x = findPath a ((R x Leaf) : path) right
| otherwise = splay (Node Leaf x right) path

-- If x has both children

findPath a path (Node left x right)
| a < x = findPath a ((L x right) : path) left
| a > x = findPath a ((R x left) : path) right
| otherwise = splay (Node left x right) path

{--------------------------- Deletion from tree ---------------------------}

-- helper function

deleteNode :: (Ord a) => a -> Tree a -> Tree a
deleteNode _ Leaf = Leaf
deleteNode a (Node left x right) = deleteWithPath a [] (Node left x right)
deleteWithPath :: (Ord a) => a -> [Path a] -> Tree a -> Tree a

-- node in focus has no children

deleteWithPath a path (Node Leaf x Leaf)
| a == x = splayParent path Leaf
| otherwise = splay (Node Leaf x Leaf) path

-- node in focus has only smaller children

deleteWithPath a path (Node left x Leaf)
| a < x = deleteWithPath a (L x Leaf : path) left
| a == x = splayParent path left
| otherwise = splay (Node left x Leaf) path

-- node in focus has only bigger children

deleteWithPath a path (Node Leaf x right)
| a > x = deleteWithPath a (R x Leaf : path) right
| a == x = splayParent path right
| otherwise = splay (Node Leaf x right) path

-- node in focus has both smaller and bigger children

deleteWithPath a path (Node left x right)
| a < x = deleteWithPath a (L x right : path) left
| a > x = deleteWithPath a (R x left : path) right
| otherwise = splayParent path (Node (deleteMax left) (findMax left) right)

splayParent :: (Ord a) => [Path a] -> Tree a -> Tree a
splayParent ((L parent p_oC) : path) child =
	splay (Node child parent p_oC) path
splayParent ((R parent p_oC) : path) child =
	splay (Node child parent p_oC) path
	
-- returns max value from a tree

findMax :: (Ord a) => Tree a -> a
findMax (Node left x Leaf) = x
findMax (Node _ x right) = findMax right

-- deletes the biggest element from a tree

deleteMax :: (Ord a) => Tree a -> Tree a
deleteMax (Node left x Leaf) = left
deleteMax (Node left x right) = Node left x (deleteMax right)


