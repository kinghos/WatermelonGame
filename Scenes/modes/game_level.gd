extends Node2D

@onready var left_edge: Marker2D = $Board/LeftEdge
@onready var right_edge: Marker2D = $Board/RightEdge
@onready var fruit_delay: Timer = $FruitDelay
@onready var cloud: Sprite2D = $Board/Cloud
@onready var current_fruit_sprite = $Board/Cloud/CurrentFruit
@onready var next_fruit_sprite: TextureRect = $UI/GameUI/InfoPanel/Info/BottomBox/VBoxContainer/NextFruitBox/Box/TextureRect
@onready var held_fruit_sprite: TextureRect = $UI/GameUI/InfoPanel/Info/BottomBox/VBoxContainer/HeldFruitBox/Box/TextureRect
@onready var score_label: Label = $UI/GameUI/InfoPanel/Info/TopBox/ScoreBox/Score
@onready var opponent_preview: TextureRect = $UI/GameUI/OpponentPanel/OpponentPreview
@export var queue_size = 20
@onready var opponent_score_label: Label = $UI/GameUI/OpponentPanel/OpponentScoreLabel
@onready var high_score_box: VBoxContainer = $UI/GameUI/InfoPanel/Info/TopBox/HighScoreBox
@onready var high_score_label: Label = $UI/GameUI/InfoPanel/Info/TopBox/HighScoreBox/HighScore
@onready var timer_label = $UI/GameUI/InfoPanel/Info/TopBox/TimerBox/Timer
@onready var multiplayer_timer: Timer = $MultiplayerTimer
@onready var filter: ColorRect = $UI/Filter
@onready var pause_menu: Control = $UI/PauseMenu
@onready var instructions: Control = $UI/Instructions
@onready var pop: AudioStreamPlayer = $Pop
@onready var merge: AudioStreamPlayer = $Merge

const pop_sfx = preload("res://assets/audio/pop.mp3")

var just_held = false
var initial_time
var end_area_fruits: Dictionary
var game_over = false
var connected = false

signal player_lost(drew)
signal update_game_over(won: bool)

func _ready() -> void:
	$UI/GameUI.connect("hold_fruit", _hold_fruit)
	initial_time = Time.get_unix_time_from_system()
	multiplayer_timer.start()
	Globals.Score = 0
	Globals.held_fruit = null
	
	if Globals.is_singleplayer:
		$UI/GameUI/OpponentPanel.hide()
		$UI/GameUI/InfoPanel.size.x = 1040
		high_score_box.show()
		var file = FileAccess.open("user://highscore.dat", FileAccess.READ)
		if file:
			high_score_label.text = str(file.get_32())
		
		instructions.show()
		filter.show()
		get_tree().paused = true
	else:
		$UI/GameUI/OpponentPanel.show()
		$UI/GameUI/InfoPanel.size.x = 631
		high_score_box.hide()
		

func _process(delta: float) -> void:
	if not game_over:
		_update_fruit_preview()
		_update_ui()
		_update_opponent_preview()
		_update_timer()
		_check_end_fruits()
	if not Globals.is_singleplayer and not connected:
		var error = get_parent().get_node("Network Menu").player_won.connect(_on_player_won)
		if error == OK:
			connected = true
		
	
func _update_timer():
	if Globals.is_singleplayer:
		var current_time = Time.get_unix_time_from_system()
		var diff = current_time - initial_time
		timer_label.text = Time.get_time_string_from_unix_time(diff).substr(3)
	else:
		var time_left = multiplayer_timer.time_left
		var format = "%02d:%02d"
		timer_label.text = format % [time_left / 60, int(time_left) % 60]
		
func _update_opponent_preview():
	var img = Globals.preview_texture
	if img:
		var tex = ImageTexture.create_from_image(img)
		opponent_preview.texture = tex
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("Click") and not game_over:
		_place_fruit()
		_update_ui()
		
func _physics_process(delta: float) -> void:
	_check_fruit_merging()

	
func _update_ui():
	if not Globals.fruit_queue:
		return
	next_fruit_sprite.texture = Globals.Textures[Globals.fruit_queue[1]]
	if not (Globals.held_fruit == null):		
		held_fruit_sprite.texture = Globals.Textures[Globals.held_fruit]
	score_label.text = str(Globals.Score)
	opponent_score_label.text = "Score: " + str(Globals.Opponent_score)
	
		
func _update_fruit_preview():
	if len(Globals.fruit_queue) < 2:
		_create_fruit_queue()
	Globals.current_fruit = Globals.fruit_queue[0]
	var coords = get_global_mouse_position()
	coords = coords.clamp(left_edge.global_position, right_edge.global_position) # Ensure the cloud cannot go out of bounds
	cloud.global_position = coords
	current_fruit_sprite.texture = Globals.Textures[Globals.current_fruit]
	current_fruit_sprite.scale = Globals.Scales[Globals.current_fruit]
	

func _place_fruit():
	if fruit_delay.is_stopped():
		fruit_delay.start()
		var coords = get_global_mouse_position()
		coords = coords.clamp(left_edge.global_position, right_edge.global_position) # Ensure the fruit cannot fall out of bounds
		
		var fruit = Globals.Classes[Globals.current_fruit].instantiate()
		fruit.position = coords
		fruit.contact_monitor = true
		fruit.max_contacts_reported = 10
		$Fruits.add_child(fruit)
		
		pop.play()
		
		Globals.Score += Globals.BaseScores[Globals.current_fruit]
		
		current_fruit_sprite.hide()
		just_held = false
		
func _create_fruit_queue():
	var fruit_queue = Globals.fruit_queue
	# 2 oranges, 4 tangerines, 5 grapes, 5 strawberries, 4 cherries
	for i in range(2):
		fruit_queue += [Globals.Fruits.ORANGE]
	for i in range(4):
		fruit_queue += [Globals.Fruits.TANGERINE]
		fruit_queue += [Globals.Fruits.CHERRY]
	for i in range(5):
		fruit_queue += [Globals.Fruits.GRAPE]
		fruit_queue += [Globals.Fruits.STRAWBERRY]
	
	# Fischer-Yates Shuffle
	var i = len(fruit_queue) - 1
	while i > 0:
		var j = randi_range(0, i)
		# Swap
		var temp = fruit_queue[i]
		fruit_queue[i] = fruit_queue[j]
		fruit_queue[j] = temp
		i -= 1
	
	Globals.fruit_queue = fruit_queue
	
func _on_fruit_delay_timeout() -> void:
	Globals.fruit_queue.pop_front()
	_update_fruit_preview()
	current_fruit_sprite.show()

func _on_merged_fruit(node):
	add_child(node)
	
func _check_fruit_merging():
	var fruits: Array[Node] = $Fruits.get_children()
	for fruit: RigidBody2D in fruits:
		# Filter out all non-RigidBody nodes
		var contacts = fruit.get_colliding_bodies().filter( 
			func(node): return node if node is RigidBody2D else null)
		
		for contact in contacts:
			# Check if touching fruits are alike
			if contact.type == fruit.type:
				if fruit.type != Globals.Fruits["WATERMELON"]:
					var merged_fruit = Globals.Classes[fruit.type + 1].instantiate()
					
					# Take average position between fruits to find collision point
					merged_fruit.position = (fruit.position + contact.position) / 2
					merged_fruit.contact_monitor = true
					merged_fruit.max_contacts_reported = 10
					Globals.Score += Globals.MergedScores[fruit.type + 1]
					fruits.erase(contact)
					fruit.free()
					contact.free()
					$Fruits.add_child(merged_fruit)
					merge.play()
					break
				else:
					Globals.Score += Globals.MergedScores[Globals.Fruits.WATERMELON]
					fruits.erase(contact)
					fruit.free()
					contact.free()
					break
					
func _hold_fruit():
	if not just_held and $FruitDelay.is_stopped():
		var temp = Globals.current_fruit
		Globals.fruit_queue.pop_front()
		
		if not(Globals.held_fruit == null):
			Globals.current_fruit = Globals.held_fruit
			Globals.fruit_queue.insert(0, Globals.current_fruit) # Makes sure it isnt overriden in _update_fruit_preview
			
		
		_update_fruit_preview()
		Globals.held_fruit = temp
		just_held = true
		_update_ui()


func _on_end_area_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		end_area_fruits[body] = Time.get_unix_time_from_system()
	
func _on_end_area_body_exited(body: Node2D) -> void:
	if body is RigidBody2D:
		end_area_fruits.erase(body)
	
func _check_end_fruits():
	for body in end_area_fruits:
		var time_in_area = Time.get_unix_time_from_system() - end_area_fruits[body]
		if time_in_area >= 1:
			print("Game Over!")
			_game_over_state("lost")
			
func _game_over_state(win_string: String):
	game_over = true
	var fruits = $Fruits.get_children()
	for fruit in fruits:
		fruit.freeze = true
	filter.visible = true
	$"UI/GameOver".visible = true
	update_game_over.emit(win_string)
	if not Globals.is_singleplayer:
		player_lost.emit(Globals.Opponent_score == Globals.Score)
	else:
		var save_file = FileAccess.open("user://highscore.dat", FileAccess.WRITE_READ)
		if save_file:
			var high_score = save_file.get_32()
			if Globals.Score > int(high_score):
				save_file.store_32(Globals.Score)
		else:
			save_file.store_32(Globals.Score)
			
		

func _on_player_won(disconnected):
	# Ternary operator
	var message = " (Opponent disconnected)" if disconnected else ""
	_game_over_state("won" + message)
	
func _on_multiplayer_timer_timeout() -> void:
	if Globals.Score < Globals.Opponent_score:
		_game_over_state("lost")
	elif Globals.Score == Globals.Opponent_score:
		_game_over_state("drew")

func _on_pause_pressed() -> void:
	if Globals.is_singleplayer:
		get_tree().paused = true
	filter.visible = true
	pause_menu.show()

func _on_pause_menu_unpaused() -> void:
	get_tree().paused = false
	filter.visible = false
	pause_menu.hide()

func _on_instructions_unpaused() -> void:
	get_tree().paused = false
	filter.visible = false
	instructions.hide()
