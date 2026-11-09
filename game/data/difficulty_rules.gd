class_name DifficultyRules
extends Resource
## Settings of the adaptive difficulty (difficulty_rules.tres, read by DifficultyDirector): the
## more easily the player goes on, the harder the pieces they are given. A harder piece is the
## one with the least room on the grid among a few drawn at random: the game stays fair (any
## piece can come, the player can still turn it or use a bonus), it never becomes a wall.

## Games played before the player's past games raise the starting level (the score of the game
## under way always does): a new player first gets the hang of it.
@export var beginner_games: int = 2
## Points scored in the game under way that raise the difficulty a level.
@export var points_per_level: int = 200
## A level more at the start of a game for each of these points in the player's average score
## of their recent games (PlayerStats), up to `max_start_level`.
@export var average_points_per_start_level: int = 400
@export var max_start_level: int = 2
## Combo (moves in a row that cleared something) from which the player chains easily: a level
## more while it lasts. 0 turns it off.
@export var combo_for_extra_level: int = 3
## Pieces drawn for each new piece, per level (the first is level 0): the one with the least
## room is given. 1 is pure chance. The last entry is the highest level.
@export var candidates_per_level: Array[int] = [1, 2, 2, 3, 3, 4]
