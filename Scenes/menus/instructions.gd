extends Control

signal unpaused

func _on_ok_pressed() -> void:
	get_tree().paused = false
	unpaused.emit()
	
