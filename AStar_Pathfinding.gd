extends Node2D

var astar = AStarGrid2D.new()

#const TILE_SIZE = Vector2(70,70)

@onready var tile_map: Node2D = $"."
@onready var bounds: TileMapLayer = $Bounds
@onready var ground: TileMapLayer = $Ground
@onready var tilemap_layers := tile_map.get_children()
@onready var tilemap_size = bounds.get_used_rect().end - bounds.get_used_rect().position
@onready var enemies := $"../Enemies".get_children()



func _ready() -> void:
	
	var map_rect = Rect2i(Vector2i.ZERO, tilemap_size)
	
	var tile_size = ground.tile_set.tile_size # cell size 70 x 70
	
	astar.region = map_rect
	astar.cell_size = tile_size
	astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_EUCLIDEAN
	astar.default_estimate_heuristic = AStarGrid2D.HEURISTIC_EUCLIDEAN
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ALWAYS
	astar.update()
	
	
	update_obstacles()


func update_obstacles():
	for layer in tilemap_layers: # Tilemap obstacles
		for i in tilemap_size.x:
			for j in tilemap_size.y:
				var coords = Vector2i(i,j)
				var tile_data = layer.get_cell_tile_data(coords)
				if tile_data and tile_data.get_custom_data("walkable") != true:
					astar.set_point_solid(coords) # Obstacle
	
	#for enemy in enemies: # Enemy obstacles
		#var enemy_pos = ground.local_to_map(enemy.global_position)
		#astar.set_point_solid(enemy_pos, true)
