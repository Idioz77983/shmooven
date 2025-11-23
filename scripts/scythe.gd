extends Node3D


@onready var player = $"../../../../../../.."

func ability():
	player.hit(true, 25)
