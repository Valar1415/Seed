extends Node2D

@onready var enemies: Array = $"../Combatants/Enemies".get_children()
@onready var allies: Array = $"../Combatants/Allies".get_children()

var initiative_order: Array = []


func _ready() -> void:
	var characters = enemies + allies
	
	# Roll initiative and store character name with the rolled initiative
	for character in characters:
		var char_int = DiceRoll.roll(character.initiative)
		initiative_order.append({"name": character.name, "initiative": char_int})  # Store as dictionary

	# Sort in descending order
	initiative_order.sort_custom(func(a, b): return a["initiative"] > b["initiative"])
	
	
	await get_tree().create_timer(0.1).timeout
	UiEventBus.initiative_order.emit(initiative_order)
	# Print name and their rolled initiative
	#for entry in initiative_order:
		#print("%s: %d" % [entry["name"], entry["initiative"]])
	start_turns()

func start_turns() -> void:
	# Loop through the initiative order
	for combatant in initiative_order:
		var character = find_combatant_by_name(combatant["name"])
		if character.is_in_group("enemy"):
			#print(combatant["name"], " initiative: ", combatant["initiative"])
			enemy_turn_start(character)
			character.act()  # Call the act function on the active combatant
			await UiEventBus.turn_end # Wait before the next turn
		elif character.is_in_group("player"):
			ally_turn_start(character)
			await UiEventBus.turn_end
			character.turn = false
	start_turns()


func find_combatant_by_name(name: String) -> Node:
	var characters = enemies + allies
	for character in characters:
		if character.name == name:
			return character
	return null


func ally_turn_start(player):
	player.turn = true
	player.movement = 1
	player.rolls = 1
	player.end_turn_button.disabled = false
	print_rich("[color=#ADD8E6]Ally turn:[/color] %s" % player.name)



func enemy_turn_start(enemy):
	enemy.movement = 2
	enemy.rolls = 1
	print_rich("[color=#ADD8E6]Enemy turn:[/color] %s" % enemy.name)
