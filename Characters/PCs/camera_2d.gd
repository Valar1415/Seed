extends Camera2D

var dragging := false
var last_mouse_position := Vector2.ZERO

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_MIDDLE:
		if event.pressed:
			# Start dragging
			dragging = true
			last_mouse_position = event.position
		else:
			# Stop dragging
			dragging = false

	if event is InputEventMouseMotion and dragging:
		# Calculate the difference in position and move the camera
		var delta = event.position - last_mouse_position
		position -= delta / zoom  # Adjust with camera zoom
		last_mouse_position = event.position
