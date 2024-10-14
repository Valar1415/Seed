extends Button

@onready var combatants: Node2D = $"../../Combatants"

func _ready() -> void:
	UiEventBus.turn_end.connect(update)


func update(_owner) -> void:
	var is_local_turn_owner: bool = combatants.is_local_player_turn_owner()
	print(is_local_turn_owner)
	disabled = not is_local_turn_owner
