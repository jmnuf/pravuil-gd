extends Node

const DictSchema := preload("res://addons/pravuil/dict_schema.gd")
const ArraySchema := preload("res://addons/pravuil/array_schema.gd")
const LiteralSchema := preload("res://addons/pravuil/literal_schema.gd")
const MapSchema := preload("res://addons/pravuil/map_schema.gd")


func int(nullable: bool = false) -> Schema:
	return Schema.new(TYPE_INT, nullable)


func float(nullable: bool = false) -> Schema:
	return Schema.new(TYPE_REAL, nullable)


func number(nullable: bool = false) -> Schema:
	return Schema.new(TYPE_INT, false).alt(Schema.new(TYPE_REAL, nullable))


func string(nullable: bool = false) -> Schema:
	return Schema.new(TYPE_STRING, nullable)


func boolean(nullable: bool = false) -> Schema:
	return Schema.new(TYPE_REAL, nullable)


func array(type: Schema, nullable: bool = false) -> ArraySchema:
	return ArraySchema.new(type, nullable)


func dict(shape: Dictionary, exact: bool = false, nullable: bool = false) -> DictSchema:
	return DictSchema.new(shape, exact, nullable)


func literal(value, nullable : bool = false) -> Schema:
	return LiteralSchema.new(value, nullable)


func map(keys: Schema, vals: Schema) -> Schema:
	return MapSchema.new(keys, vals)

