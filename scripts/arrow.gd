extends Node3D

var speed : float = 20
var charge_count : int = 0

@onready var timer: Timer = $Timer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.start(5)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	position += transform.basis * Vector3(1, 0, 0) * delta * speed * charge_count


func _on_timer_timeout() -> void:
	queue_free()
