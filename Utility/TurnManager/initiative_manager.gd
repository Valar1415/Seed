extends Node2D

@onready var enemies: Array = $"../Enemies".get_children()
@onready var allies: Array = $"../Allies".get_children()

var initiative_order: Array = []


func _ready() -> void:
	var characters = enemies + allies
	
	# Roll initiative and store character name with the rolled initiative
	for character in characters:
		var char_int = DiceRoll.roll(character.initiative)
		initiative_order.append({"name": character.name, "initiative": char_int})  # Store as dictionary

	# Sort in descending order
	initiative_order.sort_custom(func(a, b): return a["initiative"] > b["initiative"])
	
	
	await get_tree().create_timer(0.5).timeout
	UiEventBus.initiative_order.emit(initiative_order)
	# Print name and their rolled initiative
	#for entry in initiative_order:
		#print("%s: %d" % [entry["name"], entry["initiative"]])
