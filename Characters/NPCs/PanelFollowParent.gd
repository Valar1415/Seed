extends PanelContainer


func _process(delta: float) -> void:
	global_position = $"../..".global_position + Vector2(45, 0)
