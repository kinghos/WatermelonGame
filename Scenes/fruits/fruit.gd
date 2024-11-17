extends RigidBody2D
class_name Fruit

var type: int
#
#signal add_fruit(node: Node)
#
#func _ready() -> void:
	#contact_monitor = true
	#max_contacts_reported = 8
#
#func _process(delta: float) -> void:
	#var contacts = get_colliding_bodies()
	#for body in contacts:
		#print(body)
		#if body is Fruit:
			#print("FRUIT!")
			#if body.type == type:
				#print(type + 1)
				###var merged_fruit = Globals.Classes[type + 1]
				##merged_fruit = merged_fruit.instatiate()
				### Find midpoint between fruits
				##merged_fruit.global_position = (global_position + body.global_position) / 2
				##add_fruit.emit(merged_fruit)
				##
				#
