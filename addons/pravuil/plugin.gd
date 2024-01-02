tool
extends EditorPlugin


const SchemaScript = preload("res://addons/pravuil/base_schema.gd")


func _enter_tree() -> void:
	add_autoload_singleton("Prav", "res://addons/pravuil/pravuil.gd")
	# TODO: Actually add the type through the add_custom_type method
#	add_custom_type("PravuilSchema", "Reference", SchemaScript, null)


func _exit_tree() -> void:
	remove_autoload_singleton("Prav")
#	remove_custom_type("PravuildSchema")
