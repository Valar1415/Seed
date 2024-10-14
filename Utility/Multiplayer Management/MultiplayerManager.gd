extends Node

#region Private Variables
var _server_color : String = "red"

var _peer_color_pool : Array[String] = [
	"red",
	"green",
	"yellow",
	"blue",
	"magenta",
	"pink",
	"purple",
	"cyan",
	"orange"
]
#endregion Private Variables

#region Public Methods
func peer_print(message) -> void:
	var color := _get_peer_color()
	var id := multiplayer.get_unique_id()
	
	print_rich("[color=%s](%s)[/color] %s" % [color, id, message])
#endregion Public Methods

#region Private Methods
func _get_peer_color() -> String:
	if multiplayer.is_server():
		return _server_color
	
	var index := multiplayer.get_unique_id() % _peer_color_pool.size()
	return _peer_color_pool[index]
#endregion Private Methods
