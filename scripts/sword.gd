extends Node3D

@export var stats : weapon_stats

@onready var player = $"../../../../../../.."

func ability():
	player.dash(25, false)
	player.speed = 50
