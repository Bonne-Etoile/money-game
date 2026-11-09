class_name RecordChase
extends RefCounted
## The race against the player's record (best score) during a game: how far along it the
## score is, how many points are missing, and when it is beaten. The record that counts is the
## one at the start of the game: once beaten, the player is setting a new one.

## The best score when the game started (0: no record yet).
var record: int = 0


func _init(record_at_start: int) -> void:
	record = maxi(record_at_start, 0)


## Whether there is a record to beat (not on the very first game).
func has_record() -> bool:
	return record > 0


## Share of the record reached by `score`, in percent (0 to 100).
func percent(score: int) -> int:
	if record <= 0:
		return 0
	return clampi(score * 100 / record, 0, 100)


## Points missing to beat the record (0 once beaten, or without a record).
func missing(score: int) -> int:
	if record <= 0:
		return 0
	return maxi(record + 1 - score, 0)


## Whether `score` beats the record.
func is_beaten(score: int) -> bool:
	return record > 0 and score > record


## Whether going from `before` to `after` just beat the record (the moment to celebrate).
func beaten_between(before: int, after: int) -> bool:
	return not is_beaten(before) and is_beaten(after)
