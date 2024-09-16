extends Area2D

signal enemy_turn_finished

# Get nodes
@onready var tile_map: Node2D = $"../../TileMap"
@onready var tileMap_ground: TileMapLayer = $"../../TileMap/Ground"
@onready var player: Area2D = $"../../Allies/Player"
@onready var range: Area2D = $Range
@onready var allies: Node2D = $"../../Allies"

# Attack
var atk_targets: Array = []

# Attributes
@export var max_health := 24
@export var health := 24
@export var movement := 2
@export var rolls := 1

var path: Array[Vector2i]

func _ready():
	var closest_tile = tileMap_ground.local_to_map(global_position)
	global_position = tileMap_ground.map_to_local(closest_tile)
	

#func _unhandled_input(event: InputEvent) -> void: # DEBUG
	#if event.is_action_pressed("DEBUG_K"):
		#print("wolf move")
		#path = tile_map.astar.get_id_path(
			#tile_map.ground.local_to_map(global_position), 
			#tile_map.ground.local_to_map(player.position)
		#).slice(1) # Ignore first tile 
		#movement = 2
		#act()

func act():
	var target = pick_target()
	print_rich("[color=red][b]%s:[/b][/color] %s" % ["Enemy target", target.name])
	get_path_to_target(target)
	if path.is_empty():
		return
	
	check_atk_targets_in_range()
	if atk_targets.is_empty():
		move()
		if path.is_empty():
			print(path)
		if path.size() == 0:
			atk_targets.clear()
			check_atk_targets_in_range()
			if !atk_targets.is_empty(): # If found target, attack
				attack(target)
	else:
		attack(target)
	
	
	await get_tree().create_timer(1.5).timeout
	emit_signal("enemy_turn_finished")
	

func attack(target_enemy):
	while rolls > 0:
		var rolled_ability = DiceRoll.roll("1d6")
		match rolled_ability:
			1,2,3:
				var damage = DiceRoll.roll("1d12")
				if target_enemy != null:
					target_enemy.take_damage(damage)
			4,5:
				var damage = DiceRoll.roll("1d6 + 1d4")
				if target_enemy != null:
					target_enemy.take_damage(damage)
			6:
				var damage = DiceRoll.roll("3d6")
				if target_enemy != null:
					target_enemy.take_damage(damage)
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
		if area.is_in_group("dead"):
			pass
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

func get_path_to_target(target):
	path = tile_map.astar.get_id_path(
		tile_map.ground.local_to_map(global_position), 
		tile_map.ground.local_to_map(target.position)
	).slice(1) # Ignore first tile 


#func act()->void:
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
	health -= amount
	%HealthBar.value = health
	%HealthLbl.text = str(health, "/", max_health)
	if health <= 0:
		%DeathIcon.show()



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
