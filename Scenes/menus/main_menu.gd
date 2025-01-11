extends Control

func _on_singleplayer_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/modes/singleplayer.tscn")
	Globals.is_singleplayer = true

func _on_multiplayer_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/network_menu.tscn")
	Globals.is_singleplayer = false

func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/options.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()
