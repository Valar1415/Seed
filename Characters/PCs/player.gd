extends Area2D

signal turn_end

@onready var tile_map: TileMap = $"../TileMap"
@onready var tileMap_ground: TileMapLayer = $"../TileMap/Ground"
@onready var world = $".."

var turn := false
var chat_active := true


func _input(event: InputEvent) -> void:
	if turn and chat_active:
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


func _on_message_focus_entered() -> void:
	chat_active = false

func _on_message_focus_exited() -> void:
	chat_active = true



## ABILITIES

func _on_a_1_pressed() -> void:
	world.roll_dice("1d12 + 1d6")
