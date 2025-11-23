extends Node3D

var peer = ENetMultiplayerPeer.new()
var port = 1027
@export var player_scene : PackedScene
@onready var join_ip = $CanvasLayer/joinIp
@onready var join_port = $CanvasLayer/joinPort
@onready var host_port = $CanvasLayer/HostPort
@onready var hosts_ip = $"Host Info/Control/MarginContainer/VBoxContainer/HostsIP"
@onready var hosts_port = $"Host Info/Control/MarginContainer/VBoxContainer/HostsPort"
@onready var player_name = $CanvasLayer/MarginContainer/VBoxContainer/PlayerName


func _on_host_pressed():
	if host_port.text != "":
		port = host_port.text.to_int()
	
	peer.create_server(port)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(add_player)
	add_player()
	$CanvasLayer.hide()
	$"Host Info".show()
	
	hosts_ip.text = "sorry, you gotta find your ip :c"
	hosts_port.text = "Port: " + str(port)
	
	Global.IsHost = true
	if player_name.text != "": Global.LocalPlayerName = player_name.text


func _on_join_pressed():
	var ip = "127.0.0.1"
	if !join_ip.text == "":
		ip = join_ip.text
	if join_port.text != "":
		port = join_port.text.to_int()
	
	peer.create_client(ip, port)
	multiplayer.multiplayer_peer = peer
	$CanvasLayer.hide()
	
	if player_name.text != "": Global.LocalPlayerName = player_name.text

func add_player(id = 1):
	var player = player_scene.instantiate()
	player.name = str(id)
	call_deferred("add_child", player)

func exit_game(id):
	multiplayer.peer_disconnected.connect(del_player)
	del_player(id)

func del_player(id):
	rpc("_del_player", id)

func send_signal(id, signal_name, parameter = ""):
	rpc("_send_signal", id, signal_name, parameter)

@rpc("any_peer", "call_local")
func _del_player(id):
	get_node(str(id)).queue_free()
	
	if id == 1:
		$CanvasLayer.show()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
@rpc("any_peer", "call_local")
func _send_signal(id, signal_name, parameter = ""):
	if parameter:
		get_node(str(id)).call_deferred(signal_name, parameter)
	else:
		get_node(str(id)).call_deferred(signal_name)
