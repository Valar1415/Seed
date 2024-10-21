extends Area2D
class_name Entity

#region GET NODES
## FIGHTERS
@onready var combatants: Node2D = $"../.."
@onready var allies: Node2D = $"../../Allies"
@onready var enemies: Node2D = $"../../Enemies"

## ENVIRONMENT
@onready var tile_map: Node2D = $"../../../TileMap"
@onready var tileMap_ground: TileMapLayer = $"../../../TileMap/Ground"
#endregion

#region ATTRIBUTES
@export var base_movement := 1
@export var base_rolls := 1
@export var initiative := "1d400"
@export var movement: int:
	get: return movement
	set(value):
		movement = value
		update_UI("Movement", value)
@export var rolls: int = 1:
	get: return rolls
	set(value):
		rolls = value
		update_UI("Rolls", value)
@export var health: int= 24
@export var max_health: int= 24
@export var armor: int = 0
@export var max_armor: int = 15
#endregion

#region TURN ORDER
var turn := false

func turn_start():
	turn = true
	movement = base_movement
	rolls = base_rolls
	MultiplayerManager.peer_print("TURN STARTEEEEEEEEEEEEEEEED")
#endregion

#region STATES
enum States {ALIVE, CORPSE}
var current_state: States = States.ALIVE
#endregion

#region ATTRIBUTE UPDATES
@rpc("any_peer", "call_local", "reliable")
func gain_health(amount):
	health += amount
	if health > max_health:
		health = max_health
	%HealthBar.value = health
	%HealthLbl.text = str(health, "/", max_health)

@rpc("any_peer", "call_local", "reliable")
func gain_armor(amount):
	armor += amount
	if armor > max_armor:
		armor = max_armor
	%ArmorBar.value = armor
	%ArmorLbl.text = str(armor, "/", max_armor)

@rpc("any_peer", "call_local", "reliable")
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
	combatants.remove_from_initiative(self)
#endregion


#region MISC
func snap_to_nearest_tile():
	var closest_tile = tileMap_ground.local_to_map(global_position)
	global_position = tileMap_ground.map_to_local(closest_tile)

func update_UI(type_name: String, value):
	if type_name == "Movement":
		if has_node("%Movement") and %Movement != null:
			%Movement.text = str("Movement: ", value)
	elif type_name == "Rolls":
		if has_node("%Rolls") and %Rolls != null:
			%Rolls.text = str("Rolls: ", value)
	
#endregion

#region GUI
var UI_inititative_texture: Array
var reference

func _mouse_enter() -> void:
	match_reference()
	UI_inititative_texture[reference].show_highlighter()
	show_highlighter()

func _mouse_exit() -> void:
	UI_inititative_texture[reference].hide_highlighter()
	hide_highlighter()

func match_reference():
	for index in range(UI_inititative_texture.size()):
		var TextRect = UI_inititative_texture[index]
		if TextRect.character_reference == self:
			reference = index  # Store the index
			return

func show_highlighter():
	%Highlighter.show()

func hide_highlighter():
	%Highlighter.hide()
#endregion
