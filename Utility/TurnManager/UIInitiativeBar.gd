extends VBoxContainer

@export var placeholder_texture: PackedScene
@export var placeholder_circle: PackedScene
@export var placeholder_line: PackedScene


func _ready() -> void:
	UiEventBus.initiative_order.connect(add_initiative_bar)
	UiEventBus.turn_end.connect(sort_initiative_bar)
	

func add_initiative_bar(order) -> void:
	# Clear existing TextureRects before adding new ones
	clear_children()
	
	for entry in order:
		var char_name = entry["name"]
		#print(char_name)
		var char_sprite = get_character_sprite(char_name)
		
		
		# Instance the TextureRect from the template scene
		var texture_instance = placeholder_texture.instantiate()
		var circle_instance = placeholder_circle.instantiate()
		
		# Set the TextureRect sprite from the character's icon
		texture_instance.texture = char_sprite.texture
		
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


func sort_initiative_bar(_character):
	if get_child_count() > 0:
		var first_child = get_child(0)
		var second_child = get_child(1)
		remove_child(first_child)  # Remove the active character from the top
		remove_child(second_child)  # Remove the circle
		add_child(first_child)     # Add them back to the bottom
		add_child(second_child)     # Add them back to the bottom


# Helper function to get the character sprite (finds it from enemies/allies)
func get_character_sprite(char_name: String) -> Sprite2D:
	var characters_root = get_tree().root.get_node("World/Combatants")
	var character = characters_root.find_child(char_name, true, false)
	
	if character and character.has_node("Sprite2D"):
		return character.get_node("Sprite2D")
	
	return null

# Clears all child nodes (used to reset the UI each time)
func clear_children() -> void:
	for child in get_children():
		child.queue_free()
