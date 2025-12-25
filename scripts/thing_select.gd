extends Button

@export var thing : String
@export var am_i_a_trait : bool

@warning_ignore("unused_parameter")
func _process(delta):
	if am_i_a_trait == true and $"../../../..".is_trait_equipped == true and !button_pressed:
		disabled = true
	else:
		disabled = false
	
	if Global.equiped_things.size() == $"../../../..".max_inventory and !button_pressed:
		disabled = true

func _on_pressed():
	if button_pressed == true:
		$"../../../..".add_thing(thing, am_i_a_trait)
		
	else:
		$"../../../..".remove_thing(thing, am_i_a_trait)
