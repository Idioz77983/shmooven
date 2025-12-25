extends Node3D

var peer = ENetMultiplayerPeer.new()
var port = 1027
@export var player_scene : PackedScene
@export var Maps : Dictionary[int, PackedScene] = {}
@onready var join_ip = $CanvasLayer/joinIp
@onready var join_port = $CanvasLayer/joinPort
@onready var host_port = $CanvasLayer/HostPort
@onready var hosts_ip = $"Host Info/Control/MarginContainer/VBoxContainer/HostsIP"
@onready var hosts_port = $"Host Info/Control/MarginContainer/VBoxContainer/HostsPort"
@onready var player_name = $CanvasLayer/MarginContainer/VBoxContainer/PlayerName
@onready var round_timer = $Timers/RoundTimer
@onready var round_time = $"Host Info/Control/MarginContainer/VBoxContainer/RoundTime"

func _ready():
	change_map(0)

@warning_ignore("unused_parameter")
func _process(delta):
	if Global.equiped_things.is_empty():
		$CanvasLayer/Host.disabled = true
		$CanvasLayer/Join.disabled = true
	else:
		$CanvasLayer/Host.disabled = false
		$CanvasLayer/Join.disabled = false


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

func send_signal(id, signal_name, parameter = null, parameter2 = null):
	rpc("_send_signal", id, signal_name, parameter, parameter2)

@rpc("any_peer", "call_local")
func _del_player(id):
	get_node(str(id)).queue_free()
	
	if id == 1:
		$CanvasLayer.show()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
@rpc("any_peer", "call_local")
func _send_signal(id, signal_name, parameter = null, parameter2 = null):
	if parameter:
		if parameter2 == null:
			get_node(str(id)).call_deferred(signal_name, parameter)
		if parameter2 != null:
			get_node(str(id)).call_deferred(signal_name, parameter, parameter2)
	else:
		get_node(str(id)).call_deferred(signal_name)

@rpc("any_peer", "call_local")
func change_map(map_id):
	if get_node("Map"):
		get_node("Map").name = "old_map"
		get_node("old_map").queue_free()
	var map_to_add = Maps[map_id].instantiate()
	map_to_add.name = "Map"
	add_child(map_to_add, true)
	

@rpc("any_peer", "call_local")
func reset_player_positions(going_into_round = false):
	for i in get_children():
		if i is CharacterBody3D:
			i.call("reset_position", going_into_round)

@rpc("any_peer", "call_local")
func add_point(Recipiant, Amount):
	for i in get_children():
		if i is CharacterBody3D and i.name == Recipiant:
			i.add_point(Amount)

func _on_change_map_pressed():
	rpc("change_map", 1)
	rpc("reset_player_positions", false)

func _on_back_to_lobby_pressed():
	rpc("change_map", 0)
	rpc("reset_player_positions", false)

func _on_start_round_pressed():
	var round_length : int
	if int(round_time.text) > 0:
		round_length = int(round_time.text)
	else:
		round_length = 120
	round_time.text = ""
	rpc("change_map", 1)
	rpc("reset_player_positions", true)
	round_timer.start(round_length)


func _on_round_timer_timeout():
	rpc("change_map", 0)
	rpc("reset_player_positions", false)
