extends Entity
class_name Player


## MULTIPLAYER
@onready var authority = get_multiplayer_authority() == multiplayer.get_unique_id()
@onready var player_data = GameManager.Players[multiplayer.get_unique_id()]
@export var player_id: int:
	set(id):
		#print("Setting player_id for player: ", id)
		player_id = id
		set_multiplayer_authority(id)


## ENVIRONMENT
@onready var world: Node2D = $"../../.."

## TARGETING
@onready var target_icon: Sprite2D = $TargetIcon
@onready var raycast: RayCast2D = $RayCast2D

## MISC
@onready var camera = %Camera2D
@onready var debuffIcon = preload("res://Utility/debuff_icon.tscn")
var chat_inactive := true


## MOUSE DRAG
var is_dragging = false

## ABILITIES
enum Abilities {A0,A1,A2,A3,A4,A5,A6}

var current_ability: Abilities = Abilities.A0
var targeting_active: bool = false

#@export var dice_result: int = 0 # Was used die roll for rpc sync
#@export var dice_result2: int = 0

func _ready() -> void:
	await get_tree().process_frame # Do not remove
	
	#if is_multiplayer_authority():
		#print("Player ID: ", player_id, " has authority.")
	#else:
		#print("Player ID: ", player_id, " does not have authority.")
	
	snap_to_nearest_tile()
	%lblPlayerName.text = name #set name to playerID
	
	
	if is_multiplayer_authority():
		UiEventBus.pass_texture_ref.connect(set_UI_texture_reference)
		combatants.local_player = self
		activate_camera()
		set_attributes()
		reveal_local_UI()
	



func _process(_delta) -> void:
	var n = calculate_mouse_pos()
	var mouse_pos = n[0]
	var tile_pos = n[1]
	
	
	if target_icon.visible: # Aiming
		target_icon.global_position = tileMap_ground.map_to_local(tile_pos)
		raycast.enabled = true
		raycast.target_position = tileMap_ground.map_to_local(tile_pos) - global_position
		
	
	if is_dragging: # Mouse Drag&Drop
		global_position = mouse_pos

func _input_event(_viewport, event, _shape_idx): # Mouse Drag&Drop
	if is_multiplayer_authority():
		if event is InputEventMouseButton and event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT:
				is_dragging = true
				#print("Mouse button pressed on player")
		
		
		if event is InputEventMouseButton and not event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT:
				is_dragging = false
				snap_to_nearest_tile()

func _input(event: InputEvent) -> void:
	if is_multiplayer_authority():
		if turn and chat_inactive and movement:
			input_move_direction(event)
			select_atk_target(event)
			
		if event.is_action_pressed("mouse_right_click") and targeting_active:
			deactivate_targeting()
		
		camera_zoom(event)
	
	if event.is_action_pressed("ui_accept"): # Enter - Send message
		world._on_send_pressed()
	
	#if (event is InputEventMouseButton) and event.pressed: # Release focus from chat
		#var evLocal = make_input_local(event)
		#if !Rect2(Vector2(0,0), %Message.get_size()).has_point(evLocal.position):
			#%Message.release_focus()
		


func input_move_direction(event): # Called from input
	if event.is_action_pressed("ui_up"):
		move(Vector2.UP)
	elif event.is_action_pressed("ui_down"):
		move(Vector2.DOWN)
	elif event.is_action_pressed("ui_left"):
		move(Vector2.LEFT)
	elif  event.is_action_pressed("ui_right"):
		move(Vector2.RIGHT)

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

func select_atk_target(event): # Called from input
	if event.is_action_pressed("mouse_left_click") and targeting_active:
		# Calculate the mouse position in the TileMap's local space
		var n = calculate_mouse_pos()
		var target_pos = n[1]
		
		# Find enemy on selected tile
		var target_enemy = find_enemy_on_tile(target_pos)
		var target_enemy_string_ref = target_enemy.get_path() # Multiplayer fix (EncodedObjectAsID)
		
		# Check if ranged attack is blocked
		var range_atk_collider = raycast.get_collider()
		
		# Execute the ability with the target tile position
		if range_atk_collider == null or !range_atk_collider.is_in_group("obstacle"): # Check if ranged attack is blocked
			if rolls > 0:
					execute_ability.rpc(current_ability, target_pos, target_enemy_string_ref)
		else:
			print("Attack blocked by obstacle")
		
		deactivate_targeting()

func deactivate_targeting(): # Called from input
	targeting_active = false
	target_icon.visible = false
	raycast.enabled = false

@rpc("any_peer", "call_local", "reliable")
func execute_ability(ability: Abilities, target_pos: Vector2, target_enemy_path) -> void:
	var target_enemy = get_node(target_enemy_path)
	print("Ability executed at position: ", target_pos)
	print("target enemy name: ", target_enemy)
	match ability:
		Abilities.A1:
			pass
		Abilities.A2:
			pass
		Abilities.A3:
			pass
		Abilities.A4:
			pass
		Abilities.A5:
			pass
		Abilities.A6:
			pass


## MISC

func find_enemy_on_tile(tile_pos: Vector2) -> Node:
	var tile_pos_int: Vector2i = tile_pos.floor()  # Convert to Vector2i (rounds down to integer coordinates)
	for enemy in enemies.get_children():
		var enemy_tile_pos = tileMap_ground.local_to_map(enemy.global_position)  # Convert enemy position to tile position
		if enemy_tile_pos == tile_pos_int:
			return enemy  # Return the enemy if it's on the clicked tile
	return null  # No enemy found on this tile


func calculate_mouse_pos():
	var mouse_pos = get_global_mouse_position()
	var mouse_local_pos = tileMap_ground.to_local(mouse_pos)
	var tile_pos = tileMap_ground.local_to_map(mouse_local_pos)
	
	return [mouse_pos, tile_pos]

func set_attributes():
	%HealthBar.max_value = max_health
	%HealthBar.value = max_health
	%HealthLbl.text = str(max_health, "/", max_health)
	%ArmorBar.max_value = max_armor
	%ArmorLbl.text = str(max_armor, "/", max_armor)

func activate_camera():
	camera.position = global_position
	camera.enabled = true

func reveal_local_UI():
	$GUI_Local.show()

func camera_zoom(event):
	if event.is_action_pressed("zoom_in"):
		camera.zoom += Vector2(0.1, 0.1)  # Zoom step
		camera.zoom = camera.zoom.clamp(Vector2(0.75, 0.75), Vector2(1.5, 1.5))
	
	elif event.is_action_pressed("zoom_out"):
		camera.zoom -= Vector2(0.1, 0.1)  # Zoom step
		camera.zoom = camera.zoom.clamp(Vector2(0.75, 0.75), Vector2(1.5, 1.5))

func set_UI_texture_reference(tex_reference):
	UI_inititative_texture.append(tex_reference)

func roll_dice(skill: Skill): 
	if multiplayer.is_server():
		skill.dice_result_dmg = DiceRoll.roll(skill.dice_roll_dmg)
		skill.dice_result_armor = DiceRoll.roll(skill.dice_roll_armor)
		world.type_dice_result.rpc(skill.dice_result_dmg)
		MultiplayerManager.peer_print(skill.dice_result_dmg)
		if skill.dice_result_armor != 0:
			world.type_dice_result.rpc(skill.dice_result_armor)
			MultiplayerManager.peer_print(skill.dice_result_armor)
		#sync_diceroll.rpc(attack)
		##return result
#
#@rpc("any_peer", "call_local", "reliable")
#func sync_diceroll(attack: Attack):
	#
	#dice_result2 = result2
	#MultiplayerManager.peer_print(result2)
