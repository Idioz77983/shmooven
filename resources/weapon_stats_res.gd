extends Resource

class_name weapon_stats

@export var id : int
@export_group("Basic Stats")
@export var damage : float
@export var attack_speed : float
@export var attack_range : float
@export var hitbox_size : float
@export var grav_multi : float
@export var slowness : float
@export_group("Animations")
@export var animation_player_name : String = "AnimationPlayer" 
@export var animation_names : Dictionary[int, String]
@export_group("Weapon Behaviors")
@export var type: WeaponType
@export var can_crit: bool
@export var charge_length: float
@export_subgroup("Ranged Settings")
@export var projectile: PackedScene

enum WeaponType {
	MELEE,
	PROJECTILE
}
