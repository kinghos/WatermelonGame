extends Control

const MAIN_MENU = preload("res://scenes/menus/main_menu.tscn")
var peer: ENetMultiplayerPeer
var scene = load("res://scenes/modes/multiplayer.tscn")

func _ready() -> void:
	multiplayer.peer_connected.connect(_peer_connected)
	multiplayer.peer_disconnected.connect(_peer_disconnected)
	multiplayer.connected_to_server.connect(_connected_to_server)
	multiplayer.connection_failed.connect(_connection_failed)

func _process(_delta) -> void:
	if peer:
		if len(peer.host.get_peers()) == 1:
			$Background/Buttons/StartGame.disabled = false

# Called on servers and clients
func _peer_connected(id):
	print("Player connected with ID ", id)

func _peer_disconnected(id):
	print("Player disconnected with ID ", id)
	$Background/Buttons/StartGame.disabled = true

# Called on clients only
func _connected_to_server():
	print("Connected to server")
	
func _connection_failed():
	print("Couldn't connect")
	
func _on_quit_pressed() -> void:
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
		return
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)

@rpc("any_peer", "call_local")
func _start_game():
	get_tree().root.add_child(scene.instantiate())
	self.hide()

func _on_start_game_pressed() -> void:
	_start_game.rpc()
