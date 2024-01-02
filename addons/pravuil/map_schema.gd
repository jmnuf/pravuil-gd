extends Schema


var _key_schema : Schema
var _val_schema : Schema


func _init(key_schema : Schema, val_schema : Schema).(TYPE_DICTIONARY) -> void:
	_key_schema = key_schema
	_val_schema = val_schema


func _parse(value, err_message: String = "") -> SchemaResult:
	var res := ._parse(value, err_message)
	if not res.ok:
		return res
	
	for k in value.keys():
		res = _key_schema.parse(k)
		
		if not res.ok:
			var message:String = res.error
			var split = message.split(":")
			split.insert(1, "At Map[{key}]".format({"key": JSON.print(k) }))
			message = split.join(":")
			return SchemaResult.Err(message)
		
		var val = value.get(k)
		res = _val_schema.parse(val)
		if not res.ok:
			var message:String = res.error
			var split = message.split(":")
			split.insert(1, "At Map[{key}]".format({"key": JSON.print(k) }))
			message = split.join(":")
			return SchemaResult.Err(message)
	
	return SchemaResult.Ok(value)


func get_type_name() -> String:
	return "Map<%s, %s>" % [
		_key_schema.get_valid_types().join("|"),
		_key_schema.get_valid_types().join("|"),
	]
