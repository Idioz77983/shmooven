extends Node3D

@export var stats : weapon_stats

@onready var player = $"../../../.."

func ability():
	player.dash(25, false)
	player.speed = 50

func play_anim(anim_id: int):
	var anim_name = stats.animation_names[anim_id]
	
	$AnimationPlayer.stop()
	$AnimationPlayer.play(anim_name)
