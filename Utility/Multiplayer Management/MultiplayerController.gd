extends Control

#region Export Variables
@export var address = "127.0.0.1"
@export var port = 8910
#endregion Export Variables

#region Public Variables
var peer
var selected_class = "Knighter"
#endregion Public Variables

# Called when the node enters the scene tree for the first time
func _ready():
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	
	if "--server" in OS.get_cmdline_args():
		HostGame()

#region Multiplayer Callbacks
# This get called on the server and clients
func _on_peer_connected(id : int):
	MultiplayerManager.peer_print("Peer connected %d" % id)
	
# This get called on the server and clients
func _on_peer_disconnected(id : int):
	MultiplayerManager.peer_print("Peer disconnected %d" % id)
	
	GameManager.Players.erase(id)
	var players = get_tree().get_nodes_in_group("player")
	for i in players:
		if i.name == str(id):
			i.queue_free()

# Called only from clients
func _on_connected_to_server():
	MultiplayerManager.peer_print("Connected to server, sending PI")
	SendPlayerInformation.rpc_id(1, $PlayerName.text, multiplayer.get_unique_id(), selected_class)

# Called only from clients
func _on_connection_failed():
	MultiplayerManager.peer_print("Couldn't connect")
#endregion Multiplayer Callbacks

#region Multiplayer Methods
@rpc("any_peer")
func SendPlayerInformation(name, id, selected_class):
	if !GameManager.Players.has(id):
		MultiplayerManager.peer_print("Received PI: name=%s id=%s class=%s" % [name, id, selected_class])
		GameManager.Players[id] ={
			"name" : name,
			"id" : id,
			"class": selected_class
		}
		
		MultiplayerManager.peer_print("Players registered: %s" % str(GameManager.Players))
	else:
		MultiplayerManager.peer_print("Received REPEATED PI: id=%s" % id)
	
	if multiplayer.is_server():
		MultiplayerManager.peer_print("Sending PIs to peers")
		for i in GameManager.Players:
			SendPlayerInformation.rpc(GameManager.Players[i].name, i, GameManager.Players[i].class)

@rpc("any_peer", "call_local")
func StartGame():
	var main_scene = load("res://world.tscn").instantiate()
	get_tree().root.add_child(main_scene)
	self.hide()
	
func HostGame():
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, 3)
	if error != OK:
		print("Cannot host: " + error)
		return
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	
	multiplayer.set_multiplayer_peer(peer)
	
	MultiplayerManager.peer_print("Hosting and waiting for players, sending PI")
	SendPlayerInformation($PlayerName.text, multiplayer.get_unique_id(), selected_class)
#endregion Multiplayer Methods

func _on_host_button_down():
	HostGame()

func _on_join_button_down():
	peer = ENetMultiplayerPeer.new()
	peer.create_client(address, port)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)

func _on_start_game_button_down():
	# TODO: Assert every player has a name
	StartGame.rpc()

#region Class Selection Callbacks
func _on_knighter_class_pressed() -> void:
	selected_class = "knighter"

func _on_ranger_class_pressed() -> void:
	selected_class = "ranger"
#endregion Class Selection Callbacks
