class_name FrameStats
extends RefCounted
## Samples of one measure taken frame after frame (a time in milliseconds, a count), and
## their summary: mean, a percentile, the largest (performance measurement).

var _samples: PackedFloat64Array = PackedFloat64Array()


func add(value: float) -> void:
	_samples.append(value)


func count() -> int:
	return _samples.size()


func mean() -> float:
	if _samples.is_empty():
		return 0.0
	var total: float = 0.0
	for value in _samples:
		total += value
	return total / _samples.size()


## The value under which `share` (0 to 1) of the samples are (nearest rank).
func percentile(share: float) -> float:
	if _samples.is_empty():
		return 0.0
	var sorted: PackedFloat64Array = _samples.duplicate()
	sorted.sort()
	var rank: int = clampi(ceili(clampf(share, 0.0, 1.0) * sorted.size()) - 1, 0, sorted.size() - 1)
	return sorted[rank]


func maximum() -> float:
	if _samples.is_empty():
		return 0.0
	var largest: float = _samples[0]
	for value in _samples:
		largest = maxf(largest, value)
	return largest
