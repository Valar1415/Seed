extends Node2D

var turnManager = preload("res://Utility/TurnManager.tres")

@onready var player = $Player

func _ready():
	ally_turn_start()
	turnManager.connect("ally_turn_started", Callable(self, "ally_turn_start"))
	turnManager.connect("enemy_turn_started", Callable(self, "enemy_turn_start"))
	
	player.connect("turn_end", Callable(self, "turn_end"))

func ally_turn_start():
	player.turn = true
	print("ally turn")

func enemy_turn_start():
	print("enemy turn")
	turnManager.turn = TurnManager.ALLY_TURN

func turn_end():
	print("turn end")
	player.turn = false
	turnManager.turn = TurnManager.ENEMY_TURN
