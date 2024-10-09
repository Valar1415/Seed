extends TextureRect

var character_reference: Object

@onready var char_HL = character_reference.find_child("Highlighter")


func _on_mouse_entered() -> void:
	$Highlighter.show()
	if char_HL != null:
		char_HL.show()

func _on_mouse_exited() -> void:
	$Highlighter.hide()
	if char_HL != null:
		char_HL.hide()
