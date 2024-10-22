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
		if self.is_in_group("player"):
			%Movement.text = str("Movement: ", value)
@export var rolls: int = 1:
	get: return rolls
	set(value):
		rolls = value
		if self.is_in_group("player"):
			%Rolls.text = str("Rolls: ", value)
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

func set_attributes():
	%HealthBar.max_value = max_health
	%HealthBar.value = max_health
	%HealthLbl.text = str(max_health, "/", max_health)
	%ArmorBar.max_value = max_armor
	%ArmorLbl.text = str(max_armor, "/", max_armor)
	movement = base_movement
	rolls = base_rolls
#endregion


#region MISC
func snap_to_nearest_tile():
	var closest_tile = tileMap_ground.local_to_map(global_position)
	global_position = tileMap_ground.map_to_local(closest_tile)


@rpc("any_peer", "call_local", "reliable")
func die():
	%DeathIcon.show()
	current_state = States.CORPSE
	combatants.remove_from_initiative(self)
#endregion

#region GUI
# Spaghetti code
@onready var IntBar: VBoxContainer = $"../../../GUI/InitiativeBar/PanelContainer/ScrollContainer/IntBar"
var UI_inititative_texture_array: Array
var char_reference
var texture_reference

func _mouse_enter() -> void:
	match_reference()
	texture_reference.show_highlighter()
	show_highlighter()
	display_enemy_info()

func _mouse_exit() -> void:
	texture_reference.hide_highlighter()
	hide_highlighter()
	hide_enemy_info()

func match_reference():
	var reference_str
	for i in UI_inititative_texture_array.size():
		var TextRect = UI_inititative_texture_array[i]
		if TextRect == self.name:
			texture_reference = find_TexRect_by_name(TextRect)
			char_reference = find_combatant_by_name(TextRect)
			return

func show_highlighter():
	%Highlighter.show()

func hide_highlighter():
	%Highlighter.hide()

func display_enemy_info():
	pass

func hide_enemy_info():
	pass
#endregion

#region HELPER FUNCTIONS
func find_combatant_by_name(char_name: String) -> Node:
	return combatants.find_child(char_name, true, false)

func find_TexRect_by_name(ref_name: String) -> Node:
	return IntBar.find_child(ref_name, true, false)
#endregion
