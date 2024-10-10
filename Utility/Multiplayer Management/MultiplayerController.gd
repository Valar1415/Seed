extends Control

@export var Address = "127.0.0.1"
@export var port = 8910
var peer

var selected_class = "Knighter"

# Called when the node enters the scene tree for the first time.
func _ready():
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	multiplayer.connected_to_server.connect(connected_to_server)
	multiplayer.connection_failed.connect(connection_failed)
	if "--server" in OS.get_cmdline_args():
		hostGame()


# this get called on the server and clients
func peer_connected(id):
	print("Player Connected " + str(id))
	
# this get called on the server and clients
func peer_disconnected(id):
	print("Player Disconnected " + str(id))
	GameManager.Players.erase(id)
	var players = get_tree().get_nodes_in_group("player")
	for i in players:
		if i.name == str(id):
			i.queue_free()

# called only from clients
func connected_to_server():
	print("connected To Sever!")
	SendPlayerInformation.rpc_id(1, $PlayerName.text, multiplayer.get_unique_id(), selected_class)

# called only from clients
func connection_failed():
	print("Couldnt Connect")

@rpc("any_peer")
func SendPlayerInformation(name, id, selected_class):
	if !GameManager.Players.has(id):
		GameManager.Players[id] ={
			"name" : name,
			"id" : id,
			"class": selected_class
		}
	
	if multiplayer.is_server():
		for i in GameManager.Players:
			SendPlayerInformation.rpc(GameManager.Players[i].name, i, GameManager.Players[i].class)

@rpc("any_peer","call_local")
func StartGame():
	var main_scene = load("res://world.tscn").instantiate()
	get_tree().root.add_child(main_scene)
	self.hide()
	
func hostGame():
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, 3)
	if error != OK:
		print("cannot host: " + error)
		return
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	
	multiplayer.set_multiplayer_peer(peer)
	print("Waiting For Players!")
	
	
func _on_host_button_down():
	hostGame()
	SendPlayerInformation($PlayerName.text, multiplayer.get_unique_id(), selected_class)
	pass # Replace with function body.


func _on_join_button_down():
	peer = ENetMultiplayerPeer.new()
	peer.create_client(Address, port)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)	
	pass # Replace with function body.


func _on_start_game_button_down():
	StartGame.rpc()
	pass # Replace with function body.


## CLASS SELECTION

func _on_knighter_class_pressed() -> void:
	selected_class = "knighter"
	#enable_buttons()

func _on_ranger_class_pressed() -> void:
	selected_class = "ranger"
	#enable_buttons()


#func enable_buttons():
	#$Host.disabled = false
	#$Join.disabled = false
	#$StartGame.disabled = false