extends Node

var current_fruit
var held_fruit
var fruit_queue: Array

enum Fruits {CHERRY, STRAWBERRY, GRAPE, TANGERINE, ORANGE,
APPLE, LEMON, PEACH, PINEAPPLE, MELON, WATERMELON}

var Names = {
	Fruits.CHERRY: "Cherry",
	Fruits.STRAWBERRY: "Strawberry",
	Fruits.GRAPE: "Grape",
	Fruits.TANGERINE: "Tangerine",
	Fruits.ORANGE: "Orange",
	Fruits.APPLE: "Apple",
	Fruits.LEMON: "Lemon",
	Fruits.PEACH: "Peach",
	Fruits.PINEAPPLE: "Pineapple",
	Fruits.MELON: "Melon",
	Fruits.WATERMELON: "Watermelon"
}

var Classes = {
	Fruits.CHERRY: preload("res://scenes/fruits/cherry.tscn"),
	Fruits.STRAWBERRY: preload("res://scenes/fruits/strawberry.tscn"),
	Fruits.GRAPE: preload("res://scenes/fruits/grape.tscn"),
	Fruits.TANGERINE: preload("res://scenes/fruits/tangerine.tscn"),
	Fruits.ORANGE: preload("res://scenes/fruits/orange.tscn"),
	Fruits.APPLE: preload("res://scenes/fruits/apple.tscn"),
	Fruits.LEMON: preload("res://scenes/fruits/lemon.tscn"),
	Fruits.PEACH: preload("res://scenes/fruits/peach.tscn"),
	Fruits.PINEAPPLE: preload("res://scenes/fruits/pineapple.tscn"),
	Fruits.MELON: preload("res://scenes/fruits/melon.tscn"),
	Fruits.WATERMELON: preload("res://scenes/fruits/watermelon.tscn")
}

var Textures = {
	Fruits.CHERRY: preload("res://assets/fruits/cherry.png"),
	Fruits.STRAWBERRY: preload("res://assets/fruits/strawberry.png"),
	Fruits.GRAPE: preload("res://assets/fruits/grape.png"),
	Fruits.TANGERINE: preload("res://assets/fruits/tangerine.png"),
	Fruits.ORANGE: preload("res://assets/fruits/orange.png"),
	Fruits.APPLE: preload("res://assets/fruits/apple.png"),
	Fruits.LEMON: preload("res://assets/fruits/lemon.png"),
	Fruits.PEACH: preload("res://assets/fruits/peach.png"),
	Fruits.PINEAPPLE: preload("res://assets/fruits/pineapple.png"),
	Fruits.MELON: preload("res://assets/fruits/melon.png"),
	Fruits.WATERMELON: preload("res://assets/fruits/watermelon.png")
}

var Scales = {
	Fruits.CHERRY: Vector2(0.121, 0.121),
	Fruits.STRAWBERRY: Vector2(0.121, 0.121),
	Fruits.GRAPE: Vector2(0.12, 0.12),
	Fruits.TANGERINE: Vector2(0.1, 0.1),
	Fruits.ORANGE: Vector2(0.14, 0.14),
	Fruits.APPLE: Vector2(0.13, 0.13),
	Fruits.LEMON: Vector2(0.11, 0.11),
	Fruits.PEACH: Vector2(0.16, 0.16),
	Fruits.PINEAPPLE: Vector2(0.18, 0.18),
	Fruits.MELON: Vector2(0.2, 0.2),
	Fruits.WATERMELON: Vector2(0.25, 0.25)
}
