extends Area2D

@onready var tile_map: TileMapLayer = $"../TileMap/Ground"

func _ready():
	var closest_tile = tile_map.local_to_map(global_position)
	global_position = tile_map.map_to_local(closest_tile)

@export var max_health := 24
@export var health := 24

func act():
	position += Vector2.DOWN * 70

func take_damage(amount):
	health -= amount
	%HealthBar.value = health
	%HealthLbl.text = str(health, "/", max_health)
	if health <= 0:
		%DeathIcon.show()
