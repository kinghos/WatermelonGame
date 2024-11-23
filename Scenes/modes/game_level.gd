extends Node2D

@onready var left_edge: Marker2D = $Board/LeftEdge
@onready var right_edge: Marker2D = $Board/RightEdge
@onready var fruit_delay: Timer = $FruitDelay
@onready var cloud: Sprite2D = $Board/Cloud
@onready var current_fruit_sprite = $Board/Cloud/CurrentFruit
@onready var next_fruit_sprite: TextureRect = $UI/GameUI/Background/InfoPanel/Info/BottomBox/VBoxContainer/NextFruitBox/TextureRect
@onready var held_fruit_sprite: TextureRect = $UI/GameUI/Background/InfoPanel/Info/BottomBox/VBoxContainer/HeldFruitBox/TextureRect

@export var queue_size = 20

func _process(delta: float) -> void:
	_update_fruit_preview()
	_update_ui()
	if Input.is_action_just_released("Click"):
		_place_fruit()
	
func _physics_process(delta: float) -> void:
	_check_fruit_merging()
	
	
func _update_ui():
	if not Globals.fruit_queue:
		return
	next_fruit_sprite.texture = Globals.Textures[Globals.fruit_queue[1]]
		
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
		current_fruit_sprite.hide()
		
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
				print("Merge")
				if fruit.type != Globals.Fruits["WATERMELON"]:
					var merged_fruit = Globals.Classes[fruit.type + 1].instantiate()
					
					# Take average position between fruits to find collision point
					merged_fruit.position = (fruit.position + contact.position) / 2
					merged_fruit.contact_monitor = true
					merged_fruit.max_contacts_reported = 10
					
					fruit.queue_free()
					contact.queue_free()
					$Fruits.add_child(merged_fruit)
					break
					
					
		
