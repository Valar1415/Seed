extends Area2D
class_name Enemy

## SIGNALS
signal turn_end

## GET NODES
@onready var tile_map: Node2D = $"../../../TileMap"
@onready var tileMap_ground: TileMapLayer = $"../../../TileMap/Ground"
@onready var range: Area2D = $Range
@onready var allies: Node2D = $"../../Allies"

## ATTACK
var atk_targets: Array = []

## ATTRIBUTES
@export var base_movement := 2
@export var initiative := "1d400"
@export var max_health := 24
@export var health := 24
@export var movement := 2
@export var rolls := 1
@export var max_armor: int = 15
@export var armor: int = 0

## STATES
enum States {ALIVE, CORPSE}

var current_state: States = States.ALIVE

## PATHFINDING
@onready var astar = tile_map.astar
var path: Array[Vector2i]

func _ready():
	var closest_tile = tileMap_ground.local_to_map(global_position)
	global_position = tileMap_ground.map_to_local(closest_tile)
	set_tilemap_obstacle(true)

#func _unhandled_input(event: InputEvent) -> void: # DEBUG
	#if event.is_action_pressed("DEBUG_K"):
		#print("wolf move")
		#path = tile_map.astar.get_id_path(
			#tile_map.ground.local_to_map(global_position), 
			#tile_map.ground.local_to_map(player.position)
		#).slice(1) # Ignore first tile 
		#movement = 2
		#act()

@rpc("any_peer", "call_local", "reliable")
func act():
	if current_state == States.CORPSE: # Not good, rather get him out of init array
		return
	
	set_tilemap_obstacle(false)
	var target = pick_target()
	print_rich("[color=red][b]%s:[/b][/color] %s" % ["Enemy target", target.name])
	get_path_to_target(target)
	if path.is_empty(): # Do nothing if target inaccessible
		return
	
	
	atk_targets.clear()
	check_atk_targets_in_range()
	if atk_targets.is_empty():
		await move()
		
		atk_targets.clear()
		check_atk_targets_in_range()
		if !atk_targets.is_empty(): # If found target, attack
			await rotate_towards_target(target.global_position)
			attack(target)
		else: # Use roll for movement
			movement = base_movement
			rolls = 0
			await move()
	else:
		await rotate_towards_target(target.global_position)
		attack(target)
	
	
	await get_tree().create_timer(2).timeout
	set_tilemap_obstacle(true)
	UiEventBus.turn_end.emit(self)
	emit_signal("turn_end")
	

func attack(target_enemy):
	while rolls > 0:
		var rolled_ability = DiceRoll.roll("1d6")
		match rolled_ability:
			1,2,3:
				pass
			4,5:
				pass
			6:
				pass
		rolls -= 1
		atk_targets.clear()
		check_atk_targets_in_range()
		await get_tree().create_timer(0.5).timeout

func move():
	while movement > 0:
		if path.size() == 1:
			break
		var target_pos = tile_map.ground.map_to_local(path.front()) # For movement
		
		global_position = target_pos # Move Wolf
		
		
		await get_tree().create_timer(0.5).timeout
		
		if global_position == target_pos:
			path.pop_front()
			movement -= 1

func check_atk_targets_in_range():
	var areas = range.get_overlapping_areas()
	if areas.is_empty():
		return
	
	for area in areas:
		if area.is_in_group("dead") or area.is_in_group("obstacle"):
			continue
		else:
			atk_targets.append(area)

func pick_target():
	var closest_target = null
	var closest_distance = INF  # Start with a very large number for comparison
	
	#var allies = get_tree().get_nodes_in_group("allies")  # Get all allies in the group
	for ally in allies.get_children():
		if not ally.is_in_group("dead"):
			var distance = global_position.distance_to(ally.global_position)
			
			if distance < closest_distance:  # Compare current ally's distance
				closest_distance = distance  # Update closest distance
				closest_target = ally          # Set this ally as the closest one
	
	return closest_target  # Return the closest ally

func rotate_towards_target(target):
	var direction = (target - global_position).normalized()
	
	# Determine the closest cardinal direction
	var cardinal_direction = Vector2()
	
	if abs(direction.x) > abs(direction.y):
		cardinal_direction.x = sign(direction.x)  # Either 1 or -1 for left/right
	else:
		cardinal_direction.y = sign(direction.y)  # Either 1 or -1 for up/down
	
	# Set the rotation based on the cardinal direction
	if cardinal_direction.x == 1:
		rotation = 0  # Right
	elif cardinal_direction.x == -1:
		rotation = deg_to_rad(180)  # Left
	elif cardinal_direction.y == 1:
		rotation = deg_to_rad(90)  # Down
	elif cardinal_direction.y == -1:
		rotation = deg_to_rad(-90)  # Up
	
	rotation += deg_to_rad(-90)
	await get_tree().create_timer(0.5).timeout

func get_path_to_target(target):
	path = tile_map.astar.get_id_path(
		tile_map.ground.local_to_map(global_position), 
		tile_map.ground.local_to_map(target.position)
	).slice(1) # Ignore first tile 

#func act()->void: # Nešto u vezi movementa
	  #if bSawPlayer:
		  ## This variable holds an array
		  ## with the path towards the player.
		  #var path=global.tilemap.getAStarPath(self.global_position, global.player.global_position)
		  #if path.size() > 2:
			  #path.pop_front() # This removes the starting point from the path
			  #var vTarget=path.pop_front() # This gives us the point towards the enemy should move
			  #self.moveTo(vTarget)
		  #else:
			  ## This "if" checks if the enemy
			  ## is right next to the player,
			  ## so that it can attack
			  #if tilemapAStar.are_points_connected(global.tilemap.getAStarWorldVectorId(self.global_position),global.tilemap.getAStarWorldVectorId(global.player.global_position)):
				  #self.attack(global.player)
#
	#position += Vector2.DOWN * 70


func take_damage(amount):
	if armor > 0:
		var damage_to_armor = min(amount, armor)  # Reduce only the amount available in armor
		armor -= damage_to_armor
		amount -= damage_to_armor
	
	if amount > 0:
		health -= amount
	
	if health <= 0:
		health = 0
		die.rpc()
	%HealthBar.value = health
	%HealthLbl.text = str(health, "/", max_health)
	%ArmorBar.value = armor
	%ArmorLbl.text = str(armor, "/", max_armor)

@rpc("any_peer", "call_local", "reliable")
func die():
	%DeathIcon.show()
	current_state = States.CORPSE
	UiEventBus.character_death.emit(self)

## OVO JE BILO ZA RAYCASTTRACKING MOVEMENT
#var second_pos = tile_map.ground.map_to_local(path[1]) # For attacks
#raycast.target_position = to_local(second_pos) # Target position for raycast
#$DebugIcon.global_position = second_pos
	#raycast.enabled = true
	#
	#if raycast.is_colliding(): # Check for valid attack target
		#var target = raycast.get_collider()
		#attack(target.position)
		#print("hello?")
		#return
	#raycast.enabled = false

func set_tilemap_obstacle(value):
	var current_position = tileMap_ground.local_to_map(global_position)
	astar.set_point_solid(current_position, value)
