extends Control


func _ready() -> void:
	$"Panel/Buttons/Play Again".visible = Globals.is_singleplayer
	
func _on_play_again_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/modes/singleplayer.tscn")

func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")
	if not Globals.is_singleplayer:
		get_tree().root.get_node("Game").queue_free()
	
func _on_game_update_game_over(win_string: String) -> void:
	$Panel/Title/WinLabel.text = "You %s!" % win_string
