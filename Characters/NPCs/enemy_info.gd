extends VBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	UiEventBus.set_enemy_info.connect(set_info)



func set_info(movement, rolls):
	%Movement.text = str("Movement: ", movement)
	%Rolls.text = str("Rolls: ", rolls)
