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

func _init(type: int, nullable: bool = false) -> void:
	# Make sure the type is not null and it's not beyond the types enum (ignore special types)
	assert(0 < type and type < TYPE_MAX, "Unkown type provided to schema")
	_type = type
	
	_nullable = nullable


func parse(value, err_message: String = "") -> SchemaResult:
	var value_type = typeof(value)
	if value_type == _type :
		return SchemaResult.Ok(value)
	
	if err_message.empty():
		err_message = "Invalid type: Expected {expected} but got {received}"
	
	err_message = err_message.format({
		"expected": TYPES[_type],
		"received": TYPES[value_type]
	})
	
	return SchemaResult.Err(err_message)


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
	
	static func Ok(val) -> SchemaResult:
		return SchemaResult.new(true, val)
	
	static func Err(err : String) -> SchemaResult:
		return SchemaResult.new(false, err)
