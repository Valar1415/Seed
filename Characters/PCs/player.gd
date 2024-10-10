extends Area2D

## MULTIPLAYER
@onready var authority = get_multiplayer_authority() == multiplayer.get_unique_id()
@onready var player_data = GameManager.Players[multiplayer.get_unique_id()]
@export var player_id: int:
	set(id):
		#print("Setting player_id for player: ", id)
		player_id = id
		set_multiplayer_authority(id)

## GET NODES
@onready var enemies: Array = $"../../Enemies".get_children()
@onready var sprite: Sprite2D = $Sprite2D


## ENVIRONMENT
@onready var tile_map: Node2D = $"../../../TileMap"
@onready var tileMap_ground: TileMapLayer = $"../../../TileMap/Ground"
@onready var world: Node2D = $"../../.."

## TARGETING
@onready var target_icon: Sprite2D = $TargetIcon
@onready var raycast: RayCast2D = $RayCast2D

## MISC
@onready var debuffIcon = preload("res://Utility/debuff_icon.tscn")
var chat_inactive := true

## TURN ORDER
@onready var end_turn_button: Button = %EndTurnButton
var turn := false

## MOUSE DRAG
var is_dragging = false

## ATTRIBUTES
var movement: int = 1:
	get: return movement
	set(value):
		movement = value
		%Movement.text = str("Movement: ", value)
var rolls: int = 1:
	get: return rolls
	set(value):
		rolls = value
		%Rolls.text = str("Rolls: ", value)

var initiative := "1d6600"
var max_health: int = 100
var health: int = 100
var max_armor: int = 15
var armor: int = 0

## ABILITIES
enum Abilities {A0,A1,A2,A3,A4,A5,A6}

var current_ability: Abilities = Abilities.A0
var targeting_active: bool = false
var dice_result: int = 0




func _ready() -> void:
	await get_tree().process_frame
	
	if is_multiplayer_authority():
		print("Player ID: ", player_id, " has authority.")
	else:
		print("Player ID: ", player_id, " does not have authority.")
	
	#%HealthLbl.max_value = max_health
	#%ArmorLbl.max_value = max_armor
	snap_to_nearest_tile()
	$Camera2D.position = global_position
	%lblPlayerName.text = name #set name to playerID
	
	if is_multiplayer_authority():
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
			if event.is_action_pressed("ui_up"):
				move(Vector2.UP)
			elif event.is_action_pressed("ui_down"):
				move(Vector2.DOWN)
			elif event.is_action_pressed("ui_left"):
				move(Vector2.LEFT)
			elif  event.is_action_pressed("ui_right"):
				move(Vector2.RIGHT)
		
			if event.is_action_pressed("mouse_left_click") and targeting_active:
				# Calculate the mouse position in the TileMap's local space
				var n = calculate_mouse_pos()
				var tile_pos = n[1]
				
				# Find enemy on selected tile
				var target_pos = Vector2(tile_pos.x, tile_pos.y)
				var target_enemy = find_enemy_on_tile(tile_pos)
				
				# Check if ranged attack is blocked
				#print("collided with: ", raycast.get_collider().name)
				var range_atk_collider = raycast.get_collider()
				
				# Execute the ability with the target tile position
				if !range_atk_collider.is_in_group("obstacle"): # Check if ranged attack is blocked
					if rolls > 0:
							execute_ability(current_ability, target_pos, target_enemy)
				
				# Deactivate targeting
				targeting_active = false
				target_icon.visible = false
				raycast.enabled = false
	
	
	if event.is_action_pressed("ui_accept"): # Enter - Send message
		world._on_send_pressed()
	
	#if (event is InputEventMouseButton) and event.pressed: # Release focus from chat
		#var evLocal = make_input_local(event)
		#if !Rect2(Vector2(0,0), %Message.get_size()).has_point(evLocal.position):
			#%Message.release_focus()
		

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

func execute_ability(ability: Abilities, target_pos: Vector2, target_enemy) -> void:
	print("Ability executed at position: ", target_pos)
	print("target enemy name: ", target_enemy)
	match ability:
		Abilities.A1:
			var damage = roll_dice("1d12 + 1d6")
			if target_enemy != null:
				target_enemy.take_damage(damage)
			rolls -= 1
		Abilities.A2:
			var damage = roll_dice("3d4")
			var armor_ = roll_dice("2d6")
			if target_enemy != null:
				target_enemy.take_damage(damage)
			gain_armor(armor_)
			rolls -= 1
		Abilities.A3:
			var shield_icon = debuffIcon.instantiate()
			%Buffs.add_child(shield_icon)
			shield_icon.texture = load("res://temp/Shield.png")
			rolls -= 1
		Abilities.A4:
			var damage = roll_dice("1d12 + 1d6")
			if target_enemy != null:
				target_enemy.take_damage(damage)
			rolls -= 1
		Abilities.A5:
			var armor_ = roll_dice("4d6")
			gain_armor(armor_)
			rolls -= 1
		Abilities.A6:
			var damage = roll_dice("2d8 + 1d10 + 1d4")
			if target_enemy != null:
				target_enemy.take_damage(damage)
			rolls -= 1




## ATTRIBUTES

func gain_health(amount):
	health += amount
	if health > max_health:
		health = max_health
	%HealthBar.value = health
	%HealthLbl.text = str(health, "/", max_health)

func gain_armor(amount):
	armor += amount
	if armor > max_armor:
		armor = max_armor
	%ArmorBar.value = armor
	%ArmorLbl.text = str(armor, "/", max_armor)

func take_damage(amount):
	if armor > 0:
		var damage_to_armor = min(amount, armor)  # Reduce only the amount available in armor
		armor -= damage_to_armor
		amount -= damage_to_armor
	
	if amount > 0:
		health -= amount
	
	if health <= 0:
		health = 0
		%DeathIcon.show()
	%HealthBar.value = health
	%HealthLbl.text = str(health, "/", max_health)
	%ArmorBar.value = armor
	%ArmorLbl.text = str(armor, "/", max_armor)



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
	target_icon.visible = true
	targeting_active = true
	current_ability = Abilities.A2

func _on_a_3_pressed() -> void:
	current_ability = Abilities.A3
	if rolls > 0:
		execute_ability(current_ability, Vector2(0,0), Vector2(0,0))
	pass

func _on_a_4_pressed() -> void:
	target_icon.visible = true
	targeting_active = true
	current_ability = Abilities.A4

func _on_a_5_pressed() -> void:
	current_ability = Abilities.A5
	if rolls > 0:
		execute_ability(current_ability, Vector2(0,0), Vector2(0,0))
	pass

func _on_a_6_pressed() -> void:
	current_ability = Abilities.A6
	target_icon.visible = true
	targeting_active = true
	pass

## MISC

func find_enemy_on_tile(tile_pos: Vector2) -> Node:
	var tile_pos_int: Vector2i = tile_pos.floor()  # Convert to Vector2i (rounds down to integer coordinates)
	for enemy in enemies:
		var enemy_tile_pos = tileMap_ground.local_to_map(enemy.global_position)  # Convert enemy position to tile position
		if enemy_tile_pos == tile_pos_int:
			return enemy  # Return the enemy if it's on the clicked tile
	return null  # No enemy found on this tile

func check_ranged_obstacles():
	pass
	

func calculate_mouse_pos():
	var mouse_pos = get_global_mouse_position()
	var mouse_local_pos = tileMap_ground.to_local(mouse_pos)
	var tile_pos = tileMap_ground.local_to_map(mouse_local_pos)
	
	return [mouse_pos, tile_pos]

func snap_to_nearest_tile():
	var closest_tile = tileMap_ground.local_to_map(global_position)
	global_position = tileMap_ground.map_to_local(closest_tile)

func reveal_local_UI():
	$GUI_Local.show()


## SIGNALS

func _on_end_turn_button_pressed() -> void:
	end_turn_button.disabled = true
	UiEventBus.turn_end.emit(self)

func _on_message_focus_entered() -> void:
	chat_inactive = false

func _on_message_focus_exited() -> void:
	chat_inactive = true
