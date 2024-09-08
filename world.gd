extends Node2D

var turnManager = preload("res://Utility/TurnManager/TurnManager.tres")
var initManager = preload("res://Utility/Initiative Bar/InitiativeManager.tres")

@onready var player = $Player

# Chat
@onready var send := %Send
@onready var message := %Message
@onready var chatbox := %Chatbox


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
	$Wolf.act()
	turnManager.turn = TurnManager.ALLY_TURN

func turn_end():
	print("turn end")
	player.turn = false
	turnManager.turn = TurnManager.ENEMY_TURN


func _on_send_pressed() -> void:
	%Send.release_focus()
	
	if message.text != "":
		chatbox.text += str("Knighter: ", message.text, "\n")
		chatbox.scroll_vertical = chatbox.get_line_height()
		roll_dice(message.text)
		message.text = ""


func roll_dice(dice):
	var result = DiceRoll.roll(dice)
	print(result)
	if result != 0:
		chatbox.text += str("Result = ", result, "\n")


#func pass_initiative(init):
	#
	#
	#await player_inits
	#initManager.set_initiative_order()
