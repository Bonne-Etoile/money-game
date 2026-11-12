class_name AdPacingRules
extends Resource
## How often rewarded ads may be offered (ad_pacing_rules.tres, read by AdPacing and
## TileBlocksGame): a few, at the moments they are worth the most, so that the player does not
## tire of them (docs/reglages-recommandes.md, Stelio's go of 2026-11-11). Only rewarded ads,
## chosen by the player: no forced ad (decision of 2026-11-09). 0 turns a limit off.

## Rewarded ads, all kinds together (continue, bonuses, extra pieces), in one game or one
## attempt at a level.
@export var ads_per_game: int = 4
## Rewarded ads for bonuses (all bonuses together) in one game.
@export var bonus_ads_per_game: int = 3
## Pieces placed, at least, between two rewarded ads for bonuses: no chain of ads at the same
## moment of trouble.
@export var moves_between_bonus_ads: int = 5
## Rewarded ads watched per day, at most; then no ad is offered until the next day.
@export var rewarded_per_day: int = 15
## Games of the endless mode (and daily challenge) played before the first ad is offered: a new
## player learns the game and tries the bonuses with their free uses first.
@export var games_without_ads: int = 3
## A continue after an ad is offered only when the score reached this share (percent) of the
## record: a continue of a poor game is worth little and wears the offer out.
@export var revive_min_record_percent: int = 40
## ... except in the first games, where the record means little and the player discovers the
## offer.
@export var revive_always_games: int = 5
