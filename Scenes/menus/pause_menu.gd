extends Control

signal unpaused

func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")
	
	if not Globals.is_singleplayer:
		unpaused.emit()
		get_tree().root.get_node("Game").queue_free()

func _on_close_pressed() -> void:
	unpaused.emit()
