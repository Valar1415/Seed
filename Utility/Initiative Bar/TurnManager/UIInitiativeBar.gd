extends VBoxContainer

@export var placeholder_texture: PackedScene
@export var placeholder_circle: PackedScene
@export var placeholder_line: PackedScene


func _ready() -> void:
	UiEventBus.initiative_order.connect(emit_add_initiative_bar)
	UiEventBus.turn_end.connect(emit_sort_initiative_bar)
	UiEventBus.character_death.connect(emit_character_death)
	


@rpc("any_peer", "call_local", "reliable")
func add_initiative_bar(order) -> void:
	# Clear existing TextureRects before adding new ones
	clear_children()
	
	for entry in order:
		var char_name = entry["name"]
		#print(char_name)
		var char_sprite = get_character_sprite(char_name)
		var character = get_character_ref(char_name)
		
		# Instance the TextureRect from the template scene
		var texture_instance = placeholder_texture.instantiate()
		var circle_instance = placeholder_circle.instantiate()
		
		# Set the TextureRect sprite from the character's icon
		texture_instance.texture = char_sprite.texture
		texture_instance.character_reference = character
		
		# Add the TextureRect to the VBoxContainer
		add_child(texture_instance)
		add_child(circle_instance)
	
	
	# Remove last circle from bar
	var children_amount: int = get_child_count()
	var last_circle = get_child(children_amount - 1)
	remove_child(last_circle)
	
	# Add break line
	var line_instance = placeholder_line.instantiate()
	add_child(line_instance)


@rpc("any_peer", "call_local", "reliable")
func sort_initiative_bar(_character):
	if get_child_count() > 0:
		var first_child = get_child(0)
		var second_child = get_child(1)
		remove_child(first_child)  # Remove the active character from the top
		remove_child(second_child)  # Remove the circle
		add_child(first_child)     # Add them back to the bottom
		add_child(second_child)     # Add them back to the bottom

@rpc("any_peer", "call_local", "reliable")
func character_death(character): # Remove from initiative bar
	for i in range(get_child_count()):
		var child = get_child(i)
		
		if child.is_in_group("character_texture"):
			if child.character_reference == character:
				remove_child(child)
				
				if i + 1 < get_child_count():  # Check if there is a next child
					var next_child = get_child(i)  # Get the next chil
					remove_child(next_child)  # Remove the circle texture rect
				break  # Stop after removing the relevant child

#region RPC signals
func emit_add_initiative_bar(order):
	add_initiative_bar.rpc(order) # Broadcast the RPC to all peers

func emit_sort_initiative_bar(character):
	sort_initiative_bar.rpc(character) # Broadcast the RPC to all peers

func emit_character_death(character):
	character_death.rpc(character) # Broadcast the RPC to all peers
#endregion

#region get functions
# Helper function to get the character sprite (finds it from enemies/allies)
func get_character_sprite(char_name: String) -> Sprite2D:
	var combatants = get_tree().root.get_node("CombatScene/Combatants")
	var character = combatants.find_child(char_name, true, false)
	
	if character and character.has_node("Sprite2D"):
		return character.get_node("Sprite2D")
	
	return null

# Helper function to get the character reference
func get_character_ref(char_name: String) -> Node:
	var allies = get_tree().root.get_node("CombatScene/Combatants/Allies").get_children()
	var enemies = get_tree().root.get_node("CombatScene/Combatants/Enemies").get_children()
	var characters = enemies + allies
	for character in characters:
		if character.name == char_name:
			return character
	return null
#endregion


# Clears all child nodes (used to reset the UI each time)
func clear_children() -> void:
	for child in get_children():
		child.queue_free()
