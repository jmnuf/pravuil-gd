tool
extends EditorPlugin


func _enter_tree() -> void:
	add_autoload_singleton("Prav", "res://addons/pravuil/pravuil.gd")


func _exit_tree() -> void:
	remove_autoload_singleton("Prav")
