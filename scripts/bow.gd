extends Node3D

@export var stats = weapon_stats

@onready var player = $"../../../../../../.."

func ability():
	player.hit(true, -10)
