extends Area2D

signal turn_end

@onready var tile_map: Node2D = $"../TileMap"
@onready var tileMap_ground: TileMapLayer = $"../TileMap/Ground"
@onready var world = $".."
@onready var target_icon: Sprite2D = $TargetIcon
@onready var raycast: RayCast2D = $RayCast2D

## ATTRIBUTES
var movement: int = 1
var rolls: int = 1

## ABILITIES
enum Abilities {A0,A1,A2,A3,A4,A5,A6}

var current_ability: Abilities = Abilities.A0
var targeting_active: bool = false
var dice_result: int = 0

var turn := false
var chat_inactive := true

func _process(delta) -> void:
	var mouse_pos = get_global_mouse_position()
	var mouse_local_pos = tileMap_ground.to_local(mouse_pos)
	var tile_pos: Vector2i = tileMap_ground.local_to_map(mouse_local_pos)
	
	
	if target_icon.visible:
		target_icon.global_position = tileMap_ground.map_to_local(tile_pos)
		raycast.target_position = tileMap_ground.map_to_local(tile_pos) - global_position
		raycast.enabled = true



func _input(event: InputEvent) -> void:
	if turn and chat_inactive and movement:
		if event.is_action_pressed("ui_up"):
			move(Vector2.UP)
		elif event.is_action_pressed("ui_down"):
			move(Vector2.DOWN)
		elif event.is_action_pressed("ui_left"):
			move(Vector2.LEFT)
		elif  event.is_action_pressed("ui_right"):
			move(Vector2.RIGHT)
	
	if event.is_action_pressed("ui_accept"): # Enter
		world._on_send_pressed()
	
	if (event is InputEventMouseButton) and event.pressed: # Release focus from chat
		var evLocal = make_input_local(event)
		if !Rect2(Vector2(0,0), %Message.get_size()).has_point(evLocal.position):
			%Message.release_focus()
		
		if targeting_active:
			# Calculate the mouse position in the TileMap's local space
			var mouse_pos = get_global_mouse_position()
			var mouse_local_pos = tileMap_ground.to_local(mouse_pos)
			var tile_pos = tileMap_ground.local_to_map(mouse_local_pos)
			
			# Execute the ability with the target tile position
			var target_pos = Vector2(tile_pos.x, tile_pos.y)
			var target_enemy = raycast.get_collider()
			
			if rolls > 0:
				execute_ability(current_ability, target_pos, target_enemy)
			
			# Deactivate targeting
			targeting_active = false
			target_icon.visible = false
			raycast.enabled = false

func move(direction: Vector2):
	var current_tile: Vector2i = tileMap_ground.local_to_map(global_position)
	
	var target_tile: Vector2i = Vector2i(current_tile.x + direction.x, current_tile.y + direction.y)
	
	# Get info on the tile you're stepping on
	var tilemap_layers = tile_map.get_children()
	
	for i in tilemap_layers:
		var tile_data: TileData = i.get_cell_tile_data(target_tile)
		if tile_data == null:
			continue
		elif tile_data.get_custom_data("walkable") == false:
			return
	
	
	global_position = tileMap_ground.map_to_local(target_tile)
	movement -= 1

func execute_ability(ability: Abilities, target_pos: Vector2,
target_enemy) -> void:
	print("Ability executed at position: ", target_pos)
	print("target enemy name: ", target_enemy)
	if target_enemy != null:
		match ability:
			Abilities.A1:
				var result = roll_dice("1d12 + 1d6")
				target_enemy.take_damage(result)
				rolls -= 1

func _on_end_turn_button_pressed() -> void:
	emit_signal("turn_end")


func _on_message_focus_entered() -> void:
	chat_inactive = false

func _on_message_focus_exited() -> void:
	chat_inactive = true



## ABILITIES

func roll_dice(dice): 
	var result = DiceRoll.roll(dice)
	print(result)
	if result != 0:
		world.type_dice_result(result)
		return result

func _on_a_1_pressed() -> void:
	#world.roll_dice("1d12 + 1d6")
	target_icon.visible = true
	targeting_active = true
	current_ability = Abilities.A1

func _on_a_2_pressed() -> void:
	world.roll_dice("3d4")
	world.roll_dice("2d6")

func _on_a_3_pressed() -> void:
	pass

func _on_a_4_pressed() -> void:
	world.roll_dice("1d12 + 1d6")

func _on_a_5_pressed() -> void:
	world.roll_dice("4d6")

func _on_a_6_pressed() -> void:
	world.roll_dice("2d8 + 1d10 + 1d4")
