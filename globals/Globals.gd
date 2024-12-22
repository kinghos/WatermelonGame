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
	Fruits.CHERRY: load("res://scenes/fruits/cherry.tscn"),
	Fruits.STRAWBERRY: load("res://scenes/fruits/strawberry.tscn"),
	Fruits.GRAPE: load("res://scenes/fruits/grape.tscn"),
	Fruits.TANGERINE: load("res://scenes/fruits/tangerine.tscn"),
	Fruits.ORANGE: load("res://scenes/fruits/orange.tscn"),
	Fruits.APPLE: load("res://scenes/fruits/apple.tscn"),
	Fruits.LEMON: load("res://scenes/fruits/lemon.tscn"),
	Fruits.PEACH: load("res://scenes/fruits/peach.tscn"),
	Fruits.PINEAPPLE: load("res://scenes/fruits/pineapple.tscn"),
	Fruits.MELON: load("res://scenes/fruits/melon.tscn"),
	Fruits.WATERMELON: load("res://scenes/fruits/watermelon.tscn")
}

var Textures = {
	Fruits.CHERRY: load("res://assets/fruits/cherry.png"),
	Fruits.STRAWBERRY: load("res://assets/fruits/strawberry.png"),
	Fruits.GRAPE: load("res://assets/fruits/grape.png"),
	Fruits.TANGERINE: load("res://assets/fruits/tangerine.png"),
	Fruits.ORANGE: load("res://assets/fruits/orange.png"),
	Fruits.APPLE: load("res://assets/fruits/apple.png"),
	Fruits.LEMON: load("res://assets/fruits/lemon.png"),
	Fruits.PEACH: load("res://assets/fruits/peach.png"),
	Fruits.PINEAPPLE: load("res://assets/fruits/pineapple.png"),
	Fruits.MELON: load("res://assets/fruits/melon.png"),
	Fruits.WATERMELON: load("res://assets/fruits/watermelon.png")
}

var Scales = {
	Fruits.CHERRY: Vector2(0.085, 0.085),
	Fruits.STRAWBERRY: Vector2(0.1, 0.1),
	Fruits.GRAPE: Vector2(0.11, 0.11),
	Fruits.TANGERINE: Vector2(0.145, 0.145),
	Fruits.ORANGE: Vector2(0.205, 0.205),
	Fruits.APPLE: Vector2(0.25, 0.25),
	Fruits.LEMON: Vector2(0.29, 0.29),
	Fruits.PEACH: Vector2(0.35, 0.35),
	Fruits.PINEAPPLE: Vector2(0.54, 0.54),
	Fruits.MELON: Vector2(0.535, 0.535),
	Fruits.WATERMELON: Vector2(0.685, 0.685)
}

var BaseScores = {
	Fruits.CHERRY: 1,
	Fruits.STRAWBERRY: 2,
	Fruits.GRAPE: 3,
	Fruits.TANGERINE: 5,
	Fruits.ORANGE: 10,
	Fruits.APPLE: 20,
	Fruits.LEMON: 30,
	Fruits.PEACH: 50,
	Fruits.PINEAPPLE: 100,
	Fruits.MELON: 200,
	Fruits.WATERMELON: 500
}

var MergedScores = {
	Fruits.CHERRY: 2,
	Fruits.STRAWBERRY: 6,
	Fruits.GRAPE: 10,
	Fruits.TANGERINE: 15,
	Fruits.ORANGE: 20,
	Fruits.APPLE: 25,
	Fruits.LEMON: 50,
	Fruits.PEACH: 75,
	Fruits.PINEAPPLE: 100,
	Fruits.MELON: 200,
	Fruits.WATERMELON: 500
}

var Score = 0
