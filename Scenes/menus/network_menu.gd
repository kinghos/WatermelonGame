extends Control

const MAIN_MENU = preload("res://scenes/menus/main_menu.tscn")
var peer: ENetMultiplayerPeer
var scene = load("res://scenes/modes/multiplayer.tscn")
var started = false

var client_id

func _ready() -> void:
	multiplayer.peer_connected.connect(_peer_connected)
	multiplayer.peer_disconnected.connect(_peer_disconnected)
	multiplayer.connected_to_server.connect(_connected_to_server)
	multiplayer.connection_failed.connect(_connection_failed)

func _process(_delta) -> void:				
	if peer:
		$Background/Buttons/StartGame.disabled = !(len(multiplayer.get_peers()) == 1)
	
	if started and Engine.get_process_frames() % 5 == 0:
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

# Called on clients only
func _connected_to_server():
	print("Connected to server")
	
func _connection_failed():
	print("Couldn't connect")
	
func _on_quit_pressed() -> void:
	if peer:
		peer.close()
	get_tree().change_scene_to_packed(MAIN_MENU)

func _on_host_pressed() -> void:
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(Globals.port, 2)
	if error != OK:
		print("Cannot host: ", error)
		return
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER) # Sets compression mode
	
	multiplayer.set_multiplayer_peer(peer)
	print("Waiting for players")
	
func _on_join_pressed() -> void:
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_client("127.0.0.1", Globals.port)
	if error != OK:
		print("Cannot join: ", error)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)

@rpc("any_peer", "call_local", "reliable") # Called on all devices, remote and local, and packets are sent with TCP
func _start_game():
	started = true
	get_tree().root.add_child(scene.instantiate())
	self.hide()

func _on_start_game_pressed() -> void:
	_start_game.rpc()
