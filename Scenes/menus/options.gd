extends Control

var sfx_index
var music_index
@onready var sfx_slider: HSlider = $Background/OptionsList/Controls/SFXSlider
@onready var music_slider: HSlider = $Background/OptionsList/Controls/MusicSlider

func _on_close_pressed() -> void:
	if Globals.main_menu_options:
		get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")
	else:
		hide()

func _ready() -> void:
	sfx_index = AudioServer.get_bus_index("SFX")
	music_index = AudioServer.get_bus_index("Music")
	
	# Updates sliders to current volume
	sfx_slider.value = db_to_linear(AudioServer.get_bus_volume_db(sfx_index))
	music_slider.value = db_to_linear(AudioServer.get_bus_volume_db(music_index))

func _on_sfx_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(sfx_index, linear_to_db(sfx_slider.value))

func _on_music_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(music_index, linear_to_db(music_slider.value))
