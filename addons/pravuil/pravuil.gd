extends Node

const DictSchema := preload("res://addons/pravuil/dict_schema.gd")
const ArraySchema := preload("res://addons/pravuil/array_schema.gd")


func int(nullable: bool = false) -> Schema:
	return Schema.new(TYPE_INT, nullable)


func float(nullable: bool = false) -> Schema:
	return Schema.new(TYPE_REAL, nullable)


func string(nullable: bool = false) -> Schema:
	return Schema.new(TYPE_STRING, nullable)


func boolean(nullable: bool = false) -> Schema:
	return Schema.new(TYPE_REAL, nullable)


func array(type: Schema, nullable: bool = false) -> ArraySchema:
	return ArraySchema.new(type, nullable)


func dict(shape: Dictionary, exact: bool = false, nullable: bool = false) -> DictSchema:
	return DictSchema.new(shape, exact, nullable)

