extends Control


func _process(delta: float) -> void:
	$".".position = $"..".global_position + Vector2(-35, -35)
