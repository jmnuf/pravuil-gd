extends Schema

var _sub_schema: Schema


func _init(sub_schema: Schema, nullable: bool = false).(TYPE_ARRAY, nullable) -> void:
	_sub_schema = sub_schema


func parse(value, main_type_err_message: String = "", sub_type_err_message: String = "") -> Result:
	var result := .parse(value, main_type_err_message)
	if not result.ok:
		return result
	
	if sub_type_err_message.empty():
		sub_type_err_message = "Invalid element type at index %s: Expected {expected} but got {received}"
	
	for i in value.size():
		var sub_value = value[i]
		var err_message = sub_type_err_message % str(i)
		result = _sub_schema.parse(sub_value, err_message)
		if not result.ok:
			return result
	
	return result

