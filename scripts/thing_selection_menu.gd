extends ScrollContainer

var is_trait_equipped : bool = false
var max_inventory = 99

func add_thing(thing_name : String, are_you_trait : bool):
	if !Global.equiped_things.has(thing_name):
		Global.equiped_things.append(thing_name)
	
	if are_you_trait:
		is_trait_equipped = true
		Global.HasTraitOn = true


func remove_thing(thing_name : String,  are_you_trait : bool):
	if Global.equiped_things.has(thing_name):
		Global.equiped_things.erase(thing_name)
		
	if are_you_trait:
		is_trait_equipped = false
		Global.HasTraitOn = false
