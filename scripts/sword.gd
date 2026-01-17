extends Node3D

@onready var player = $"../../../../../../.."

func ability():
	player.dash(25, false)
	player.speed = 50
