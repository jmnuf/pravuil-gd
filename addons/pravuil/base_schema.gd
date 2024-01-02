extends Reference
class_name Schema

const TYPES := {
	TYPE_NIL: "Null",
	TYPE_BOOL: "bool",
	TYPE_INT: "int",
	TYPE_REAL: "float",
	TYPE_STRING: "String",
	TYPE_VECTOR2: "Vector2",
	TYPE_RECT2: "Rect2",
	TYPE_VECTOR3: "Vector3",
	TYPE_TRANSFORM2D: "Transform2D",
	TYPE_PLANE: "Plane",
	TYPE_QUAT: "Quat",
	TYPE_AABB: "AABB",
	TYPE_BASIS: "Basis",
	TYPE_TRANSFORM: "Transform",
	TYPE_COLOR: "Color",
	TYPE_NODE_PATH: "NodePath",
	TYPE_RID: "RID",
	TYPE_OBJECT: "Object",
	TYPE_DICTIONARY: "Dictionary",
	TYPE_ARRAY: "Array",
	TYPE_RAW_ARRAY: "PoolByteArray",
	TYPE_INT_ARRAY: "PoolIntArray",
	TYPE_REAL_ARRAY: "PoolRealArray",
	TYPE_STRING_ARRAY: "PoolStringArray",
	TYPE_VECTOR2_ARRAY: "PoolVector2Array",
	TYPE_VECTOR3_ARRAY: "PoolVector3Array",
	TYPE_COLOR_ARRAY: "PoolColorArray",
}

var _type: int
var _nullable: bool
var _or_schema : Schema

func _init(type: int, nullable: bool = false) -> void:
	# Make sure the type is not null and it's not beyond the types enum (ignore special types)
	assert(0 < type and type < TYPE_MAX, "Unkown type provided to schema")
	_type = type
	
	_nullable = nullable
	
	_or_schema = null


func parse(value, err_message: String = "") -> SchemaResult:
	var res := _parse(value, err_message)
	
	if res.ok:
		return res
	
	if _or_schema:
		var or_res := _or_schema.parse(value)
		if or_res.ok:
			return or_res
	
	var value_type = typeof(value)
	
	if err_message.empty():
		err_message = "Invalid type: Expected {expected} but got {received}"
	
	err_message = err_message.format({
		"expected": get_valid_types().join(" or "),
		"received": TYPES[value_type]
	})
	
	return SchemaResult.Err(err_message)


func _parse(value, err_message: String = "") -> SchemaResult:
	var value_type = typeof(value)
	if value_type == _type :
		return SchemaResult.Ok(value)
	
	if err_message.empty():
		err_message = "Invalid type: Expected {expected} but got {received}"
	
	err_message = err_message.format({
		"expected": get_type_name(),
		"received": self.typeof(value_type)
	})
	
	return SchemaResult.Err(err_message)


func alt(schema : Schema) -> Schema:
	if _or_schema:
		_or_schema.alt(schema)
	else:
		_or_schema = schema
	return self


## Overrideable
func get_type_name() -> String:
	return TYPES.get(_type, "???")


# final method, should not be changed
func get_type() -> String:
	return TYPES.get(_type, "???")


func get_valid_types() -> PoolStringArray:
	var type = get_type_name()
	var types = PoolStringArray([type])
	if not _or_schema:
		return types
	
	types.append_array(_or_schema.get_valid_types())
	return types


func _to_string() -> String:
	return "{ PravuilSchema@@<{id}>, \"base_type\": <{type}>, \"accepts\": <{valid}> }".format({
		"id": get_instance_id(),
		"type": JSON.print(get_type_name()),
		"valid": JSON.print(get_valid_types())
	}, "<{_}>")


class SchemaResult extends Reference:
	var ok: bool
	var value
	
	func _init(status_ok: bool, status_value) -> void:
		ok = status_ok
		if ok:
			value = status_value
			return
		
		assert(status_value is String, "Error must be a String")
		value = status_value
	
	func get_error() -> String:
		if ok:
			return ""
		
		return value
	
	func _to_string() -> String:
		var id = get_instance_id()
		return "{ SchemaResult@@%d, ok: %s, \"%s\": %s }" % [
			id, "true" if ok else "false",
			"value" if ok else "error",
			JSON.print(value)
		]
	
	func _get(property: String):
		if property == "error" and not ok:
			return value
		return null
	
	static func Ok(val) -> SchemaResult:
		return SchemaResult.new(true, val)
	
	static func Err(err : String) -> SchemaResult:
		return SchemaResult.new(false, err)


static func typeof(value) -> String:
	return TYPES.get(typeof(value), "???")
