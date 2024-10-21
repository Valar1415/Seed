extends Node2D

var enemies: Array
var allies: Array

var initiative_order: Array = []
var turn: int = 0
var turnInit: int = 0

var local_player: Player # Set from individual Player scripts

func _ready() -> void:
	if multiplayer.is_server():
		emit_inititative_order()
	

#region Initiative order
func emit_inititative_order():
	await get_tree().create_timer(1).timeout
	enemies = $"../Combatants/Enemies".get_children()
	allies = $"../Combatants/Allies".get_children()
	var characters = enemies + allies
	
	# Roll initiative and store character name with the rolled initiative
	for character in characters:
		var char_int = DiceRoll.roll(character.initiative)
		#print(character, " initiative: ", char_int)
		initiative_order.append({"node": character, "name": character.name, "initiative": char_int})  # Store as dictionary
	
	# Sort in descending order
	initiative_order.sort_custom(func(a, b): return a["initiative"] > b["initiative"])
	
	
	UiEventBus.initiative_order.emit(initiative_order)
	# Print name and their rolled initiative
	#for entry in initiative_order:
		#print("%s: %d" % [entry["name"], entry["initiative"]])
	
	await get_tree().create_timer(1).timeout
	broadcast_initative_order.rpc(initiative_order)
	connect_NPC_signals.rpc()
	#var turn_owner_name = initiative_order[turnInit]["name"]
	start_first_turn.rpc()
	

@rpc("any_peer", "call_local", "reliable")
func broadcast_initative_order(order):
	initiative_order = order
	for character in initiative_order:
		character["node"] = find_combatant_by_name(character["name"])

func remove_from_initiative(character):
	for i in range(initiative_order.size()):
		if initiative_order[i]["node"] == character:
			initiative_order.remove_at(i)
			UiEventBus.character_death.emit(character)
			
			return
	
	print("Character not found in initiative order")
#endregion

func get_current_turn_owner() -> Object:
	var turn_owner_name = initiative_order[turnInit]["name"]
	var turn_owner = find_combatant_by_name(turn_owner_name)
	return turn_owner
	#return initiative_order[turn]["node"] # Or my_players_parent.get_children()[turn]

func is_local_player_turn_owner() -> bool:
	var local_player_scene = get_current_turn_owner()
	return local_player_scene == local_player

@rpc("any_peer", "call_local", "reliable")
func end_turn() -> void:
	turnInit = (turn + 1) % initiative_order.size() # Wrap around initiative order
	turn += 1
	
	var turn_owner = get_current_turn_owner()
	#MultiplayerManager.peer_print(turn_owner)
	#MultiplayerManager.peer_print(is_local_player_turn_owner())
	if multiplayer.is_server():
		MultiplayerManager.peer_print(get_current_turn_owner())
	
	
	if is_local_player_turn_owner(): # Ally turn
		owner_turn_start(turn_owner)
		UiEventBus.turn_end.emit(turn_owner)
	elif !turn_owner.is_in_group("player"): # Enemy turn
		if multiplayer.is_server():
			owner_turn_start(turn_owner)
			turn_owner.act()
			UiEventBus.turn_end.emit(turn_owner)
	

func owner_turn_start(turn_owner):
	turn_owner.turn_start()
	update_ui.rpc()
	#MultiplayerManager.peer_print("my turn")


@rpc("any_peer", "call_local", "reliable")
func start_first_turn():
	var turn_owner = get_current_turn_owner()
	
	if is_local_player_turn_owner():
		owner_turn_start(turn_owner)
	elif !turn_owner.is_in_group("player"): # Enemy turn
		if multiplayer.is_server():
			owner_turn_start(turn_owner)
			turn_owner.act()
	#MultiplayerManager.peer_print(get_current_turn_owner())
	

@rpc("any_peer", "call_local", "reliable")
func update_ui() -> void: # Button
	%EndTurnButton.update()


func find_combatant_by_name(char_name: String) -> Node:
	var characters_root = get_tree().root.get_node("CombatScene/Combatants")
	return characters_root.find_child(char_name, true, false)

func _on_end_turn_pressed() -> void: # Called on button press & enemy.act()
	end_turn.rpc()



@rpc("any_peer", "call_local", "reliable")
func connect_NPC_signals():
	for character in initiative_order:
		if character["node"].is_in_group("enemy"):
			character["node"].turn_end.connect(Callable(self, "_on_end_turn_pressed"))



## Deprecated turn management
#func start_turns() -> void:
	## Loop through the initiative order
	#for combatant in initiative_order:
		#var character = combatant["node"]
		#if character.is_in_group("enemy"):
			#print(character["name"], " initiative: ", character["initiative"])
			#enemy_turn_start(character)
			#character.act.rpc()  # Call the act function on the active character
			#await UiEventBus.turn_end # Wait before the next turn
			#print("Passed await, Wolf")
		#elif character.is_in_group("player"):
			#ally_turn_start.rpc_id(character.player_id, character.name)
			#await UiEventBus.turn_end
			#print("Passed await, Player")
			#character.turn = false
	#start_turns()
#
#@rpc("any_peer", "call_local", "reliable")
#func ally_turn_start(player_name):
	#var player = find_combatant_by_name(player_name) # Encoded object to player
	##print("found player: ", player)
	#player.turn = true
	#player.movement = 1
	#player.rolls = 1
	#player.end_turn_button.disabled = false
	#print_rich("[color=#ADD8E6]Ally turn:[/color] %s" % player.name)
#
#
#func enemy_turn_start(enemy):
	#enemy.movement = 2
	#enemy.rolls = 1
	#print_rich("[color=#ADD8E6]Enemy turn:[/color] %s" % enemy.name)
