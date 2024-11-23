extends Control

signal hold_fruit

func _on_texture_rect_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("Click"):
		hold_fruit.emit()
		
