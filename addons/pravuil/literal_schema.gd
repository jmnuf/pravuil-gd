extends Schema

var _value

func _init(val, nullable = false).(typeof(val)) -> void:
	_value = val


func parse(value, type_error_message: String = "") -> SchemaResult:
	if type_error_message.empty():
		# TODO: Probably error should say something different per type
		type_error_message = "Invalid type: Expected literal value %s of type {expected} but got a {received}" % str(_value)
	
	var res := .parse(value, type_error_message)
	if not res.ok:
		return res
	
	if _type <= TYPE_RID:
		if _value == value:
			return res
		
		return SchemaResult.Err("Invalid {TYPE} value: Expected literal value {EXP} but got {GOT}".format({
			"TYPE": TYPES.get(_type, "???"),
			"EXP": _value,
			"GOT": value,
		}))
	
	match _type:
		TYPE_DICTIONARY:
			return _compare_dictionaries(_value, value, "dict")
				
		TYPE_OBJECT:
			return _compare_objects(_value, value, "obj")
		
		TYPE_ARRAY:
			return _compare_arrays(_value, value, "arr")
	
	var type_name:String = TYPES.get(_type, "???")
	if type_name.begins_with("Pool") and type_name.ends_with("Array"):
		var base_length:int = _value.size()
		var othr_length:int = value.size()
		if base_length < othr_length:
			return SchemaResult.Err("Array Mismatch:{SUFFIX}Other array is too long, expected to {EXP} elements but found {GOT} elements".format({
				"SUFFIX": _get_suffix("arr"),
				"EXP": base_length,
				"GOT": othr_length,
			}))
		elif base_length > othr_length:
			return SchemaResult.Err("Array Mismatch:{SUFFIX}Other array is too short, expected to {EXP} elements but found {GOT} elements".format({
				"SUFFIX": _get_suffix("arr"),
				"EXP": base_length,
				"GOT": othr_length,
			}))
		
		for i in range(base_length):
			var base_val = _value[i]
			var other_val = value[i]
			if base_val != other_val:
				return SchemaResult.Err("Invalid value:{SUFFIX}At index {IDX} expected literal value {EXP_VAL} but got {GOT_VAL}".format({
					"SUFFIX": _get_suffix("arr"),
					"IDX": i,
					"EXP_VAL": base_val,
					"GOT_VAL": other_val,
				}))
		
		return res
	
	push_warning("Unsupported type %s (%d) in literal value check is ignored" % [TYPES.get(_type), _type])
	
	return res


func _compare_dictionaries(base : Dictionary, other : Dictionary, suffix : String = "") -> SchemaResult:
	var base_keys = base.keys()
	var other_keys = other.keys()
	for key in base_keys:
		if not (key in other_keys):
			return SchemaResult.Err("MissingKey:{SUFFIX}Inputted Dictionary is missing key {KEY}".format({
				"SUFFIX": _get_suffix(suffix),
				"KEY": key
			}))
		
		var base_val = base.get(key)
		var other_val = other.get(key)
		var bvt = typeof(base_val)
		var ovt = typeof(other_val)
		if bvt != ovt:
			return SchemaResult.Err("Invalid type:{SUFFIX}For key {KEY} expected {EXP_TYPE} but got {GOT_TYPE}".format({
				"SUFFIX": _get_suffix(suffix),
				"KEY": key,
				"EXP_TYPE": TYPES.get(bvt, "???"),
				"GOT_TYPE": TYPES.get(ovt, "???"),
			}))
		
		if bvt <= TYPE_RID:
			if base_val == other_val:
				return SchemaResult.Ok(other_val)
			else:
				return SchemaResult.Err("Invalid value:{SUFFIX}For key {KEY} expected literal value {EXP_VAL} but got {GOT_VAL}".format({
					"SUFFIX": _get_suffix(suffix),
					"KEY": key,
					"EXP_VAL": base_val,
					"GOT_VAL": other_val,
				}))
		
		var sub_suffix:String = "%s.%s" % [suffix, str(key)]
		match bvt:
			TYPE_DICTIONARY:
				var res := _compare_dictionaries(base_val, other_val, sub_suffix)
				if not res.ok:
					return res
			TYPE_OBJECT:
				var res := _compare_objects(base_val, other_val, sub_suffix)
				if not res.ok:
					return res
			TYPE_ARRAY:
				var res := _compare_arrays(base_val, other_val, sub_suffix)
				if not res.ok:
					return res
	
	return SchemaResult.Ok(other)


func _compare_objects(base: Object, other : Object, suffix : String = "") -> SchemaResult:
	# I don't want to write a deep comparisons for objects so this will do for now
	if base.get_class() != other.get_class():
		return SchemaResult.Err("Invalid Class:{SUFFIX}Expected class {EXP} instance but found class {GOT} instance".format({
			"SUFFIX": _get_suffix(suffix),
			"EXP": base.get_class(),
			"GOT": other.get_class()
		}))
	
	return SchemaResult.Ok(other)


func _compare_arrays(base: Array, other : Array, suffix : String = "") -> SchemaResult:
	var bal := base.size()
	var oal := other.size()
	
	if bal < oal:
		return SchemaResult.Err("Array Mismatch:{SUFFIX}Other array is too long, expected to have {EXP} elements but found {GOT} elements".format({
			"SUFFIX": _get_suffix(suffix),
			"EXP": bal,
			"GOT": oal,
		}))
	elif bal > oal:
		return SchemaResult.Err("Array Mismatch:{SUFFIX}Other array is too short, expected to have {EXP} elements but found {GOT} elements".format({
			"SUFFIX": _get_suffix(suffix),
			"EXP": bal,
			"GOT": oal,
		}))
	
	for i in range(bal):
		var base_val = base[i]
		var other_val = other[i]
		var bvt = typeof(base_val)
		var ovt = typeof(other_val)
		if bvt != ovt:
			return SchemaResult.Err("Invalid type:{SUFFIX}At index {IDX} expected {EXP_TYPE} but got {GOT_TYPE}".format({
				"SUFFIX": _get_suffix(suffix),
				"IDX": i,
				"EXP_TYPE": TYPES.get(bvt, "???"),
				"GOT_TYPE": TYPES.get(ovt, "???"),
			}))
		
		if bvt <= TYPE_RID:
			if base_val == other_val:
				return SchemaResult.Ok(other_val)
			else:
				return SchemaResult.Err("Invalid value:{SUFFIX}At index {IDX} expected literal value {EXP_VAL} but got {GOT_VAL}".format({
					"SUFFIX": _get_suffix(suffix),
					"IDX": i,
					"EXP_VAL": base_val,
					"GOT_VAL": other_val,
				}))
		
		match bvt:
			TYPE_DICTIONARY:
				var res := _compare_dictionaries(base_val, other_val, "%s[%s]" % [suffix, str(i)])
				if not res.ok:
					return res
			TYPE_OBJECT:
				var res := _compare_objects(base_val, other_val, "%s[%s]" % [suffix, str(i)])
				if not res.ok:
					return res
			TYPE_ARRAY:
				var res := _compare_arrays(base_val, other_val, "%s[%s]" % [suffix, str(i)])
				if not res.ok:
					return res
	
	return SchemaResult.Ok(other)



func _get_suffix(base:String) -> String:
	return " %s - " % base if not base.empty() else " "
