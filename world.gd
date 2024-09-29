extends Node2D


# Characters
@export var PlayerScene : PackedScene
@onready var allies: Node2D = $Combatants/Allies


# Chat
@onready var send := %Send
@onready var message := %Message
@onready var chatbox := %Chatbox


func _ready(): # Multiplayer Spawn & Authority?
	var index = 0
	for i in GameManager.Players:
		var currentPlayer = PlayerScene.instantiate()
		currentPlayer.name = str(GameManager.Players[i].id)
		allies.add_child(currentPlayer)
		for spawn in get_tree().get_nodes_in_group("PlayerSpawnPoint"):
			if spawn.name == str(index):
				currentPlayer.global_position = spawn.global_position
		index += 1
	




func _on_send_pressed() -> void:
	%Message.release_focus()
	
	if message.text != "":
		chatbox.text += str("Knighter: ", message.text, "\n")
		chatbox.scroll_vertical = chatbox.get_line_height()
		roll_dice(message.text)
		message.text = ""



func roll_dice(dice): 
	var result = DiceRoll.roll(dice)
	print(result)
	if result != 0:
		type_dice_result(result)
		return result

func type_dice_result(result):
		chatbox.text += str("Result = ", result, "\n")
		chatbox.scroll_vertical = chatbox.get_line_height()
