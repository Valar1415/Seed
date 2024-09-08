extends Node2D

var turnManager = preload("res://Utility/TurnManager/TurnManager.tres")
var initManager = preload("res://Utility/Initiative Bar/InitiativeManager.tres")

@onready var player = $Player

# Chat


func _ready():
	ally_turn_start()
	turnManager.connect("ally_turn_started", Callable(self, "ally_turn_start"))
	turnManager.connect("enemy_turn_started", Callable(self, "enemy_turn_start"))
	
	player.connect("turn_end", Callable(self, "turn_end"))
	
	DiceRoll.roll("d6")
	print(DiceRoll.roll("d6"))

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

#func pass_initiative(init):
	#
	#
	#await player_inits
	#initManager.set_initiative_order()
