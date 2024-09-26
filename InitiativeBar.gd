extends VBoxContainer


func _ready() -> void:
	UiEventBus.initiative_order.connect(_on_gay)

func _on_gay(order):
	print(order)
