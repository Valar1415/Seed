extends TextureRect

var character_reference: Object

#@onready var char_HL = character_reference.find_child("Highlighter")

func _ready() -> void:
	UiEventBus.pass_texture_ref.emit(self)

func _on_mouse_entered() -> void:
	$Highlighter.show()
	character_reference.show_highlighter()

func _on_mouse_exited() -> void:
	$Highlighter.hide()
	character_reference.hide_highlighter()

func show_highlighter():
	$Highlighter.show()

func hide_highlighter():
	$Highlighter.hide()
