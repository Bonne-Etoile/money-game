class_name DailyChallenge
extends RefCounted
## The daily challenge (G16): one game a day with the same pieces for everyone, from a seed
## made from the date. Days are numbered from the Unix epoch (1970-01-01 is day 0).

const SECONDS_PER_DAY: int = 86400
## Mixed into the seed, so that the daily pieces differ from any other seeded game.
const SALT: int = 0x5EED_B10C


## The day number of a calendar date.
static func day_of(year: int, month: int, day: int) -> int:
	var unix: int = Time.get_unix_time_from_datetime_dict(
		{"year": year, "month": month, "day": day, "hour": 0, "minute": 0, "second": 0}
	)
	return unix / SECONDS_PER_DAY


## The seed of `day`'s challenge: the same for everyone, different from one day to the next.
static func seed_for(day: int) -> int:
	# Knuth's multiplicative hash: plain integer arithmetic, the same on every device.
	return ((day + SALT) * 2654435761) & 0x7FFFFFFF
