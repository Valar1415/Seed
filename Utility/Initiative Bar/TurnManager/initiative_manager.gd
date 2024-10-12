extends Node2D

var enemies: Array
var allies: Array

var initiative_order: Array = []


func _ready() -> void:
	if multiplayer.is_server():
		emit_inititative_order()

func emit_inititative_order():
	await get_tree().process_frame
	enemies = $"../Combatants/Enemies".get_children()
	allies = $"../Combatants/Allies".get_children()
	var characters = enemies + allies
	
	# Roll initiative and store character name with the rolled initiative
	for character in characters:
		var char_int = DiceRoll.roll(character.initiative)
		initiative_order.append({"node": character, "name": character.name, "initiative": char_int})  # Store as dictionary

	# Sort in descending order
	initiative_order.sort_custom(func(a, b): return a["initiative"] > b["initiative"])
	
	UiEventBus.initiative_order.emit(initiative_order)
	# Print name and their rolled initiative
	#for entry in initiative_order:
		#print("%s: %d" % [entry["name"], entry["initiative"]])
	
	await get_tree().create_timer(1).timeout
	start_turns()


func start_turns() -> void:
	# Loop through the initiative order
	for combatant in initiative_order:
		var character = combatant["node"]
		if character.is_in_group("enemy"):
			print(character["name"], " initiative: ", character["initiative"])
			enemy_turn_start(character)
			character.act.rpc()  # Call the act function on the active character
			await UiEventBus.turn_end # Wait before the next turn
			print("Passed await, Wolf")
		elif character.is_in_group("player"):
			ally_turn_start.rpc_id(character.player_id, character.name)
			await UiEventBus.turn_end
			print("Passed await, Player")
			character.turn = false
	start_turns()

@rpc("any_peer", "call_local", "reliable")
func ally_turn_start(player_name):
	var player = find_combatant_by_name(player_name) # Encoded object to player
	#print("found player: ", player)
	player.turn = true
	player.movement = 1
	player.rolls = 1
	player.end_turn_button.disabled = false
	print_rich("[color=#ADD8E6]Ally turn:[/color] %s" % player.name)


func enemy_turn_start(enemy):
	enemy.movement = 2
	enemy.rolls = 1
	print_rich("[color=#ADD8E6]Enemy turn:[/color] %s" % enemy.name)

func find_combatant_by_name(char_name: String) -> Node:
	var characters_root = get_tree().root.get_node("World/Combatants")
	return characters_root.find_child(char_name, true, false)
