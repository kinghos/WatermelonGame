extends Control

func _on_singleplayer_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/singplayer_game.tscn")


func _on_multiplayer_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/multiplayer_game.tscn")


func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/options.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
