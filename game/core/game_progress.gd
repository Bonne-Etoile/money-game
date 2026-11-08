class_name GameProgress
extends RefCounted
## The state of a playthrough: pure logic, no node (docs/architecture.md, decision 3).
## Only GameState changes it, through its methods; scenes never write to it directly.
## Example content (money, play time): replace with the game's own state.

## Money is always a whole number, never a float.
var money: int = 0
## Seconds of play, pauses left out.
var play_time: float = 0.0


## Adds `amount` (ignored when not positive).
func earn(amount: int) -> void:
	if amount > 0:
		money += amount


## Takes `amount`; false (and nothing taken) when there is not enough.
func spend(amount: int) -> bool:
	if amount < 0 or amount > money:
		return false
	money -= amount
	return true


func to_dict() -> Dictionary:
	return {"money": money, "play_time": play_time}


## Reads saved progress without trusting it (JsonRead): anything invalid keeps its default.
static func from_dict(data: Dictionary) -> GameProgress:
	var progress: GameProgress = GameProgress.new()
	progress.money = maxi(JsonRead.integer(data, "money"), 0)
	progress.play_time = maxf(JsonRead.number(data, "play_time"), 0.0)
	return progress
