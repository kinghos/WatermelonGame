extends Control

const MAIN_MENU = preload("res://scenes/menus/main_menu.tscn")
var peer: ENetMultiplayerPeer
var scene = load("res://scenes/modes/multiplayer.tscn")
var started = false
var client_id
var game_over
@export var snapshot_frame_skip: int
@onready var status: Label = $Background/Title/Status

signal player_won(disconnected)

func _ready() -> void:
	multiplayer.peer_connected.connect(_peer_connected)
	multiplayer.peer_disconnected.connect(_peer_disconnected)
	multiplayer.connected_to_server.connect(_connected_to_server)
	multiplayer.connection_failed.connect(_connection_failed)
	

func _process(_delta) -> void:				
	if peer:
		$Background/Buttons/StartGame.disabled = !(len(multiplayer.get_peers()) == 1)
	
	if started and Engine.get_process_frames() % snapshot_frame_skip == 0 and not game_over:
		take_screen_capture.rpc()
		
	

@rpc("any_peer", "call_local", "unreliable_ordered")
func take_screen_capture():
	var img = get_viewport().get_texture().get_image()
	
	# Capture a region of the screen, starting 800 pixels down, and ending 1000 pixels early
	var region = Rect2i(0, 800, img.get_width(), img.get_height() - 1000)
	region = img.get_region(region)
	
	var raw: PackedByteArray = region.save_jpg_to_buffer()
	update_preview.rpc(raw, Globals.Score)

@rpc("any_peer", "call_remote", "reliable")
func update_preview(tex: PackedByteArray, opponent_score):
	var image_class = Image.new()
	image_class.load_jpg_from_buffer(tex)
	Globals.preview_texture = image_class
	Globals.Opponent_score = opponent_score

# Called on servers and clients
func _peer_connected(id):
	print("Player connected with ID ", id)
	client_id = id

func _peer_disconnected(id):
	print("Player disconnected with ID ", id)
	$Background/Buttons/StartGame.disabled = true
	_update_status.rpc("Disconnected")
	if started and not game_over:
		player_won.emit(true)
		game_over = true
		peer.close()

# Called on clients only
func _connected_to_server():
	print("Connected to server")
	_update_status.rpc("Connected!")
	
func _connection_failed():
	print("Couldn't connect")
	_update_status.rpc("Couldn't connect")
	
func _on_quit_pressed() -> void:
	if peer:
		peer.close()
	get_tree().change_scene_to_packed(MAIN_MENU)

func _on_host_pressed() -> void:
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(Globals.port, 2)
	if error != OK:
		print("Cannot host: ", error)
		status.text = "Cannot host, server exists"
		return
	$Background/Buttons/Join.disabled = true
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER) # Sets compression mode
	
	multiplayer.set_multiplayer_peer(peer)
	print("Waiting for players")
	status.text = "Waiting..."
	
func _on_join_pressed() -> void:
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_client("127.0.0.1", Globals.port)
	if error != OK:
		print("Cannot join: ", error)
		status.text = "Cannot join"
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)
	status.text = "Joining..."

@rpc("any_peer", "call_local", "reliable") # Called on all devices, remote and local, and packets are sent with TCP
func _start_game():
	started = true
	get_tree().root.add_child(scene.instantiate())
	self.hide()
	get_parent().get_node("Game").player_lost.connect(_on_player_lost)
	get_parent().get_node("Game/UI/PauseMenu").unpaused.connect(_on_unpaused)

func _on_start_game_pressed() -> void:
	_start_game.rpc()
	
func _on_player_lost(drew):
	game_over = true
	if not drew:
		_player_wins.rpc()
	await get_tree().create_timer(3).timeout # 3 second wait
	peer.close()
	
@rpc("any_peer", "call_remote", "reliable")
func _player_wins():
	game_over = true
	player_won.emit(false)
	peer.close()

@rpc("any_peer", "call_local", "reliable")
func _update_status(text):
	status.text = text

func _on_unpaused():
	peer.close()
