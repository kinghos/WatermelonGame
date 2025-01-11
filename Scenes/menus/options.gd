extends Control

func _on_close_pressed() -> void:
	if Globals.main_menu_options:
		get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")
	else:
		hide()
