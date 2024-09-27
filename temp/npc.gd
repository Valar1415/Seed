extends Area2D

signal turn_end

@onready var tile_map: TileMapLayer = $"../../../TileMap/Ground"

@export var initiative := "1d20"
@export var max_health := 24
@export var health := 24
@export var movement := 0
@export var rolls := 0

var turn := false:
	set(value):
		if value == true:
			print("ahhahahaha")
			turn = false
			emit_signal("turn_end")


func _ready() -> void:
	var closest_tile = tile_map.local_to_map(global_position)
	global_position = tile_map.map_to_local(closest_tile)

func take_damage(amount):
	health -= amount
	%HealthBar.value = health
	%HealthLbl.text = str(health, "/", max_health)
	if health <= 0:
		%DeathIcon.show()
		add_to_group("dead")
