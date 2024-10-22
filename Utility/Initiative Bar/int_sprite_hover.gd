extends TextureRect

var character_reference: Object:
	set(char_ref):
		character_reference = char_ref
		self.name = char_ref.name

func _ready() -> void:
	UiEventBus.pass_texture_ref.emit(self.name)

func _on_mouse_entered() -> void:
	show_highlighter()
	character_reference.show_highlighter()

func _on_mouse_exited() -> void:
	hide_highlighter()
	character_reference.hide_highlighter()

func show_highlighter():
	$Highlighter.show()

func hide_highlighter():
	$Highlighter.hide()
