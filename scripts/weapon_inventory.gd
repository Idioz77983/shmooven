extends Marker3D


@onready var player = $"../../../../.."

@export var current_weapon = 0

var weapons = {
	1: "Sword",
	2: "Scythe"
}

var weapon_stats = {
	"Sword": {
		"Damage": 10,
		"AttSpeed": 0.5,
		"Range": 2.0,
		"HitboxSize": 0.5
	},
	"Scythe": {
		"Damage": 25,
		"AttSpeed": 1.5,
		"Range": 3.0,
		"HitboxSize": 1.5
	}
}

func switch_weapon(direction: int):
	if current_weapon == 0 and direction == -1:
		current_weapon = weapons.size()
	elif current_weapon == weapons.size() and direction == 1:
		
		current_weapon = 0
	else:
		current_weapon += direction
	
	for i in $Weapons.get_children():
		i.hide()
	if current_weapon != 0: $Weapons.get_node(weapons[current_weapon]).show()
	
	player.load_weapon_stats(current_weapon)
	#print(current_weapon)

func get_weapon(Id : int) -> Object:
	if Id != 0:
		var weapon_to_return = $Weapons.get_node(weapons[Id])
		return weapon_to_return
	return null
