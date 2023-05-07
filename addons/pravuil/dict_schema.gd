extends Schema

var _shape: Dictionary
var _exact: bool

func _init(shape: Dictionary, exact: bool = false, nullable: bool = false).(TYPE_DICTIONARY, nullable) -> void:
	for k in shape.keys():
		var value = shape[k]
		assert(value is Schema, "Dictionary schema shape values must all be Schemas")
	
	_shape = shape
	_exact = exact
