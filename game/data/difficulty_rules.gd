class_name DifficultyRules
extends Resource
## Settings of the adaptive difficulty (difficulty_rules.tres, read by DifficultyDirector): the
## more easily the player goes on, the harder the pieces they are given; a new player, or one
## who keeps failing, gets easier ones (levels below 0). A harder piece is the one with the
## least room on the grid among a few drawn at random, an easier one the one with the most:
## the game stays fair (any piece can come, the player can still turn it or use a bonus), it
## never becomes a wall. The difficulty never reads the state of the ads.

## Games played before the player's past games raise the starting level (the score of the game
## under way always does): a new player first gets the hang of it, helped (`help_level`).
@export var beginner_games: int = 3
## Points scored in the game under way that raise the difficulty a level (until the player has
## a record of `record_points_from`; afterwards the climb follows the record, below).
@export var points_per_level: int = 200
## Record (best score before the game) from which the difficulty follows it instead of
## `points_per_level`: the start of a game stays calm whatever the record, the tension comes
## near it. 0 turns it off.
@export var record_points_from: int = 1000
## Share of the record (percent) under which the score of the game does not raise the level.
@export var record_calm_percent: int = 30
## From `record_calm_percent` on, a level more for each of these shares of the record
## (percent): with 30 and 15, +1 at 30 %, +2 at 45 %, +3 at 60 %, +4 at 75 %, +5 at 90 %.
## Scores grow faster as a game goes on (combos): 30 % of the record comes about halfway.
@export var record_percent_per_level: int = 15
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
## Pieces drawn for each new piece below level 0 (the first is level -1): the one with the
## most room is given (in practice, smaller and easier pieces).
@export var help_candidates_per_level: Array[int] = [2, 3]
## Starting level of a helped game: a new player's first games, and after a run of poor games.
@export var help_level: int = -1
## Games in a row under the player's average score after which the next game starts helped
## (0 turns it off). The score of the game raises the level back as usual.
@export var poor_games_for_help: int = 2
## Playability guarantee: while the grid is filled up to this share (percent), a new hand never
## leaves the player without a piece that fits somewhere (in some turn). Beyond it, losing is
## fair. 0 turns it off.
@export var playable_until_fill_percent: int = 70
