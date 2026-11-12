class_name LevelSet
extends Resource
## The levels of the level mode, in order (levels.tres), and their shared settings.

@export var levels: Array[LevelDefinition] = []
## Pieces given by the "+5 pieces" rewarded ad when they run out, and how many times per
## attempt at a level.
@export var extra_pieces: int = 5
@export var extra_pieces_ads: int = 2
## Stars of a won level (shown on its end card): one for winning, one more for each of these
## numbers of pieces still left at the end.
@export var star_pieces: Array[int] = [1, 3]
