extends Marker3D


func switch_hand_model(WeaponId = 0):
	for i in get_children():
		i.hide()
	
	match WeaponId:
		1:
			$SwordFPM.show()
		2:
			$ScytheFPM.show()
		3:
			$BowFPM.show()
		_:
			return
	

func get_weapon(id):
	for weapon in get_children():
		if weapon.stats.id == id:
			return weapon
