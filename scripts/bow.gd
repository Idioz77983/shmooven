extends Node3D

@export var stats : weapon_stats

@onready var player = $"../../../.."

func ability():
	player.hit(true, -10)

func play_anim(anim_id: int):
	var anim_name = stats.animation_names[anim_id]
	
	$AnimationPlayer.stop()
	$AnimationPlayer.play(anim_name)
