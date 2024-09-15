extends Area2D


# Get nodes
@onready var tile_map: Node2D = $"../TileMap"
@onready var tileMap_ground: TileMapLayer = $"../TileMap/Ground"
@onready var player: Area2D = $"../Player"

# Attack
@onready var raycast: RayCast2D = $RayCast2D

# Attributes
@export var max_health := 24
@export var health := 24
@export var movement := 2

var current_path: Array[Vector2i]

func _ready():
	var closest_tile = tileMap_ground.local_to_map(global_position)
	global_position = tileMap_ground.map_to_local(closest_tile)
	

#func _unhandled_input(event: InputEvent) -> void: # DEBUG
	#if event.is_action_pressed("DEBUG_K"):
		#print("wolf move")
		#current_path = tile_map.astar.get_id_path(
			#tile_map.ground.local_to_map(global_position), 
			#tile_map.ground.local_to_map(player.position)
		#).slice(1) # Ignore first tile 
		#movement = 2
		#act()

func act():
	get_path_to_target()
	if current_path.is_empty():
		return
	
	raycast.enabled = true
	
	while movement > 0:
		var target_pos = tile_map.ground.map_to_local(current_path.front()) # For movement
		var second_pos = tile_map.ground.map_to_local(current_path[1]) # For attacks
		
		global_position = target_pos # Move Wolf
		$DebugIcon.global_position = second_pos
		
		raycast.target_position = to_local(second_pos) # Target position for raycast
		
		
		await get_tree().create_timer(0.5).timeout
		
		if global_position == target_pos:
			current_path.pop_front()
			movement -= 1
	
	raycast.enabled = false

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

func get_path_to_target():
	current_path = tile_map.astar.get_id_path(
		tile_map.ground.local_to_map(global_position), 
		tile_map.ground.local_to_map(player.position)
	).slice(1) # Ignore first tile 
