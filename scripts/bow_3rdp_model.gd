extends Node3D

@onready var arrow : Node3D = $Bow/Arrow

func show_special_part(ja_oder_nein: bool):
	arrow.visible = ja_oder_nein
