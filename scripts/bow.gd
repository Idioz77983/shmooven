extends Node3D

@export var stats : weapon_stats

@onready var player = $"../../../.."
@onready var arrow: Node3D = $Bow/Arrow

func ability():
	player.hit(false, -10)

func play_anim(anim_id: int):
	var anim_name = stats.animation_names[anim_id]
	
	$AnimationPlayer.stop()
	$AnimationPlayer.play(anim_name)

func make_shot_visible(visibility):
	arrow.visible = visibility
