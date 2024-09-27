extends Node2D


# Characters
@onready var player: Area2D = $Combatants/Allies/Player


# Chat
@onready var send := %Send
@onready var message := %Message
@onready var chatbox := %Chatbox



func _on_send_pressed() -> void:
	%Send.release_focus()
	
	if message.text != "":
		chatbox.text += str("Knighter: ", message.text, "\n")
		chatbox.scroll_vertical = chatbox.get_line_height()
		player.roll_dice(message.text)
		message.text = ""


func type_dice_result(result):
		chatbox.text += str("Result = ", result, "\n")
		chatbox.scroll_vertical = chatbox.get_line_height()

#func roll_dice(dice): # ovo je bilo prije nego smo trebali passat value abilitiu
	#var result = DiceRoll.roll(dice)
	#print(result)
	#if result != 0:
		#chatbox.text += str("Result = ", result, "\n")
		#chatbox.scroll_vertical = chatbox.get_line_height()


#func pass_initiative(init):
	#
	#
	#await player_inits
	#initManager.set_initiative_order()
