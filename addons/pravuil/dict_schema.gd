extends Schema

var _shape: Dictionary
var _exact: bool

func _init(shape: Dictionary, exact: bool = false, nullable: bool = false).(TYPE_DICTIONARY, nullable) -> void:
	for k in shape.keys():
		var value = shape[k]
		assert(value is Schema, "Dictionary schema shape values must ALL be Schemas")
	
	_shape = shape
	_exact = exact


func parse(value, main_type_err_message: String = "", sub_type_err_message: String = "") -> Result:
	var result := .parse(value, main_type_err_message)
	if not result.ok:
		return result
	
	if sub_type_err_message.empty():
		sub_type_err_message = "Expected {expected} but got {received}"
	
	var val_keys = value.keys()
	var shape_keys = _shape.keys()
	for k in shape_keys:
		if val_keys.has(k):
			continue
		
		result = Result.new(false, "Shape mismatch: Passed element is missing key `%s`" % str(k))
		return result
	
	if _exact:
		for k in val_keys:
			if shape_keys.has(k):
				continue
			
			result = Result.new(false, "Shape mismatch: Passed element has extra key `%s`" % str(k))
			return result
	
	var val := {} if _exact else value
	for k in shape_keys:
		var sub_value = value[k]
		var schema = _shape[k]
		
		result = schema.parse(sub_value, sub_type_err_message)
		if result.ok:
			val[k] = result.value
			continue
		
		var err_message = "Invalid element type at key %s: %s" % [str(k), result.value]
		return Result.new(false, err_message)
	
	return Result.new(true, val)
