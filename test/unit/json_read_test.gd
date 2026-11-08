extends GdUnitTestSuite
## JsonRead (game/core/json_read.gd): values read out of JSON without trusting them.


func test_numbers_accept_ints_and_floats_only() -> void:
	var data: Dictionary = {"a": 3, "b": 2.5, "c": "4", "d": INF}
	assert_float(JsonRead.number(data, "a")).is_equal(3.0)
	assert_float(JsonRead.number(data, "b")).is_equal(2.5)
	assert_float(JsonRead.number(data, "c", 9.0)).is_equal(9.0)
	assert_float(JsonRead.number(data, "d", 1.0)).is_equal(1.0)
	assert_float(JsonRead.number(data, "missing", 7.0)).is_equal(7.0)


func test_json_numbers_are_floats_rounded_to_integers() -> void:
	var parsed: Dictionary = JSON.parse_string('{"count": 12}')
	assert_int(JsonRead.integer(parsed, "count")).is_equal(12)
	assert_int(JsonRead.integer({"count": 2.6}, "count")).is_equal(3)


func test_wrong_types_give_the_default() -> void:
	var data: Dictionary = {"text": 5, "list": "x", "dict": []}
	assert_str(JsonRead.text(data, "text", "none")).is_equal("none")
	assert_array(JsonRead.array(data, "list")).is_empty()
	assert_dict(JsonRead.dictionary(data, "dict")).is_empty()


func test_vectors_need_exactly_three_numbers() -> void:
	assert_vector(JsonRead.vector3({"v": [1, 2, 3]}, "v")).is_equal(Vector3(1, 2, 3))
	assert_vector(JsonRead.vector3({"v": [1, 2]}, "v", Vector3.ONE)).is_equal(Vector3.ONE)
	var value: Vector3 = Vector3(0.5, -1, 4)
	assert_vector(JsonRead.vector3({"v": JsonRead.from_vector3(value)}, "v")).is_equal(value)
