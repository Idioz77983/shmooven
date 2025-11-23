extends Area3D




func _on_body_entered(body):
	if body is CharacterBody3D:
		body.take_damage(1000)
