class_name JsonRead
extends RefCounted
## Reads values out of parsed JSON (saves, settings) without trusting them: a missing or invalid
## value gives the default. JSON numbers are floats.


static func number(data: Dictionary, key: String, default: float = 0.0) -> float:
	var value: Variant = data.get(key)
	if value is int:
		var whole: int = value
		return float(whole)
	if value is float:
		var number_value: float = value
		return number_value if is_finite(number_value) else default
	return default


static func integer(data: Dictionary, key: String, default: int = 0) -> int:
	var value: Variant = data.get(key)
	if value is int:
		var whole: int = value
		return whole
	if value is float:
		var number_value: float = value
		return roundi(number_value) if is_finite(number_value) else default
	return default


static func text(data: Dictionary, key: String, default: String = "") -> String:
	var value: Variant = data.get(key)
	if value is String:
		var string_value: String = value
		return string_value
	return default


static func dictionary(data: Dictionary, key: String) -> Dictionary:
	var value: Variant = data.get(key)
	if value is Dictionary:
		var found: Dictionary = value
		return found
	return {}


static func array(data: Dictionary, key: String) -> Array:
	var value: Variant = data.get(key)
	if value is Array:
		var found: Array = value
		return found
	return []


## Numbers of a JSON array, in order; anything else in it is left out.
static func numbers(values: Array) -> PackedFloat32Array:
	var result: PackedFloat32Array = PackedFloat32Array()
	for value: Variant in values:
		if value is int or value is float:
			var number_value: float = value
			if is_finite(number_value):
				result.append(number_value)
	return result


## A Vector3 saved as [x, y, z], or `default`.
static func vector3(data: Dictionary, key: String, default: Vector3 = Vector3.ZERO) -> Vector3:
	var values: PackedFloat32Array = numbers(array(data, key))
	if values.size() != 3:
		return default
	return Vector3(values[0], values[1], values[2])


## A rotation saved as a quaternion [x, y, z, w], or no rotation.
static func quaternion(data: Dictionary, key: String) -> Quaternion:
	var values: PackedFloat32Array = numbers(array(data, key))
	if values.size() != 4:
		return Quaternion.IDENTITY
	var rotation: Quaternion = Quaternion(values[0], values[1], values[2], values[3])
	if rotation.length_squared() < 0.0001:
		return Quaternion.IDENTITY
	return rotation.normalized()


static func from_vector3(value: Vector3) -> Array[float]:
	return [value.x, value.y, value.z]


static func from_quaternion(value: Quaternion) -> Array[float]:
	return [value.x, value.y, value.z, value.w]
