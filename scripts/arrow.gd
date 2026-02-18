extends Node3D

var speed : float = 30
var charge_count : int = 0
var damage : float = 10

var id : String
var is_original : bool = false

@onready var timer: Timer = $Timer
@onready var area_3d: Area3D = $Area3D

func _enter_tree() -> void:
	set_multiplayer_authority(int(id))

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.start(5)
	
	if is_multiplayer_authority():
		
		area_3d.monitoring = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		position += transform.basis * Vector3(1, 0, 0) * delta * speed * charge_count
		
		


func _on_timer_timeout() -> void:
	queue_free()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D and body.name != id:
		$"../".send_signal(body.name, "take_damage", damage * charge_count, id)
	queue_free()
