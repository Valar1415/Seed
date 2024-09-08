extends Area2D

signal turn_end

@onready var tile_map: TileMap = $"../TileMap"
@onready var tileMap_ground: TileMapLayer = $"../TileMap/Ground"

var turn = false

func _input(event: InputEvent) -> void:
	if turn:
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


func _on_end_turn_button_pressed() -> void:
	emit_signal("turn_end")
