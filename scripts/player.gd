extends CharacterBody3D

var has_esc_been_pressed = false

var speed = 6
const default_speed = 6
const JUMP_VELOCITY = 10
const gravity = -20
const mouse_sens = 0.3
var friction = 0.1
var dash_power = 17.5
var is_dashing = false
var can_ability = true

var can_dash = true
var available_dashes = 1
var max_dashes = 1
var can_wavedash = false
var score = 0
var is_parying : bool = false

var health = 100
var is_dead = false
var attack_damage = 0
var attack_speed = 0
var can_attack = true
var hit_connected = false
var grav_multi = 1
var slowness = 0
var is_in_round = false
var grapple_point : Vector3
var hooked_player = null
var can_trait : bool = true
var grapple_stam : float = 100
var can_regen_stam : bool = true

@onready var head = $head
@onready var cam = $head/Camera3D
@onready var model_head = $TempPlayerModel/Blobert/UpperBody/Head
@onready var animation_player = $TempPlayerModel/AnimationPlayer
@onready var dash_timer = $Timers/DashAnimTimer
@onready var arm_anims = $TempPlayerModel/ArmAnimator
@onready var hand = $TempPlayerModel/Blobert/UpperBody/RightArm/GripSpot
@onready var nametag = $Nametag
@onready var hit_bar = $head/HitBar
@onready var attack_length = $Timers/AttackLength
@onready var attack_cooldown = $Timers/AttackCooldown
@onready var respawn_timer = $Timers/RespawnTimer
@onready var health_bar = $head/Camera3D/CanvasLayer/MarginContainer/HealthBar
@onready var overhealth_bar = $head/Camera3D/CanvasLayer/MarginContainer/OverhealthBar
@onready var firstperson_models = $"head/FP Hand/FirstpersonModels"
@onready var wave_dash_timer = $Timers/WaveDashTimer
@onready var fpm_anims = $"head/FPM Anims"
@onready var ability_cooldown = $Timers/AbilityCooldown
@onready var hit_sfx = $SoundFX/hit_sfx
@onready var death_sfx = $SoundFX/death_sfx
@onready var attack_icon = $head/Camera3D/CanvasLayer/CanAttack
@onready var ability_icon = $head/Camera3D/CanvasLayer/AbilityAvailable
@onready var score_label = $head/Camera3D/CanvasLayer/MarginContainer/Score
@onready var grapple_cast = $head/GrappleCast
@onready var line_renderer_3d = $"head/GrappleLineFPM Marker/LineRenderer3D"
@onready var parry_timer = $Timers/ParryTimer
@onready var trait_cooldown = $Timers/TraitCooldown
@onready var trait_icon = $head/Camera3D/CanvasLayer/TraitAvailable
@onready var parry_icon = $head/Camera3D/CanvasLayer/ParrySheild
@onready var grapple_stamina_bar: ProgressBar = $head/Camera3D/CanvasLayer/GrappleStaminaBar
@onready var round_timer: RichTextLabel = $head/Camera3D/CanvasLayer/RoundTimer


func _enter_tree():
	set_multiplayer_authority(name.to_int())


func _ready():
	nametag.text = Global.LocalPlayerName
	
	cam.current = is_multiplayer_authority()
	$"TempPlayerModel".visible = !is_multiplayer_authority()
	firstperson_models.visible = is_multiplayer_authority()
	#arm_anims.play("HoldingItem")
	nametag.visible = !is_multiplayer_authority()
	$head/Camera3D/CanvasLayer.visible = is_multiplayer_authority()
	
	
	#print(Input.mouse_mode)
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#print(Input.mouse_mode)
	if is_multiplayer_authority(): 
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		animation_player.play("Idle")
		hit_bar.add_exception(self)
		grapple_cast.add_exception(self)
		Global.LocalPlayerId = self.name.to_int()
		hand.switch_weapon(0)

func _input(event):
	## mouse stuff ##
	if is_multiplayer_authority():
		if event is InputEventMouseMotion and Input.mouse_mode == 2 and is_multiplayer_authority():
			rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
			head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
			head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
			model_head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
			model_head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
	
		

func _physics_process(delta):
	if is_multiplayer_authority():
		
		score_label.text = "Score: " + str(score)
		
		if Input.is_action_just_pressed("SwitchLeft"):
			hand.switch_weapon(-1)
		elif Input.is_action_just_pressed("SwitchRight"):
			hand.switch_weapon(1)
		
		if can_attack:
			attack_icon.visible = hit_bar.is_colliding()
		else:
			attack_icon.visible = false
		
		parry_icon.visible = is_parying
		ability_icon.visible = can_ability
		if Global.HasTraitOn == true and !Global.equiped_things.has("Grapple"):
			trait_icon.visible = can_trait
		else:
			trait_icon.visible = false
		grapple_stamina_bar.visible = grapple_stam < 150
		
		health_bar.value = health
		overhealth_bar.value = health - 100
		grapple_stamina_bar.value = grapple_stam
		
		health = clamp(health, 0, 125)
		speed = clamp(speed, 0, 24 - slowness)
		
		if Global.RoundTime > 0:
			if Global.RoundTime%60 <= 9:
				@warning_ignore("integer_division")
				round_timer.text = "[wave]"+str(Global.RoundTime/60)+":0"+str(Global.RoundTime%60)
			else:
				@warning_ignore("integer_division")
				round_timer.text = "[wave]"+str(Global.RoundTime/60)+":"+str(Global.RoundTime%60)
		else:
			round_timer.text = "[wave]:P"
		
		# Add the gravity.
		if not is_on_floor():
			velocity.y += gravity * delta * grav_multi
			friction = 0.01
		else:
			friction = 0.1
			can_regen_stam = true
		
		if grapple_stam < 150 and can_regen_stam:
				grapple_stam += 0.5
		
		if is_dashing == false and is_on_floor():
			can_dash = true
		elif is_dashing and is_on_floor() and can_wavedash == false:
			can_wavedash = true
			wave_dash_timer.start()
		if can_wavedash == false and is_on_floor():
			speed = default_speed
		
		# Handle jump.
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
			if can_dash == false and can_wavedash == true:
				dash_timer.stop()
				speed *= 1.25
				dash_timer.paused = true
				can_dash = true
				is_dashing = false
		
		if Input.is_action_just_pressed("dash") and can_dash and health > 0:
			if Input.is_action_pressed("backward"):
				dash(-dash_power/2)
			else:
				dash(dash_power)
		
		# Get the input direction and handle the movement/deceleration.
		# As good practice, you should replace UI actions with custom gameplay actions.
		var direction : Vector3
		var input_dir : Vector2
		
		if health > 0:
			input_dir = Input.get_vector("left", "right", "forward", "backward")
			direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		
		#handling some animations
		if direction and is_on_floor() and !is_dashing:
			animation_player.play("Run")
		elif is_dashing or health <= 0:
			animation_player.play("Dash")
		else:
			animation_player.play("Idle")
		
		#if Input.is_action_just_pressed("Hit") and can_attack:
			#hit()
			#fpm_anims.stop()
			#fpm_anims.play("hit")
		if Input.is_action_just_pressed("Ability") and can_ability:
			ability()
		
		## Actually Moving Stuff ## 
		if is_on_floor():
			velocity.x = lerp(velocity.x, direction.x * speed, friction)
			velocity.z = lerp(velocity.z, direction.z * speed, friction)
		elif !is_on_floor():
			velocity.x = lerp(velocity.x, direction.x * speed * 1.25, friction)
			velocity.z = lerp(velocity.z, direction.z * speed * 1.25, friction)
		
		cam.fov = lerp(cam.fov, Global.default_FOV + (speed-6), friction)
#		firstperson_models.position.y = lerp(firstperson_models.position.y, )
		
		move_and_slide()
		
		if Input.is_key_pressed(KEY_ESCAPE) and has_esc_been_pressed == false:
			if Input.mouse_mode == 2:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			elif Input.mouse_mode == 0:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			has_esc_been_pressed = true
		elif !Input.is_key_pressed(KEY_ESCAPE) and has_esc_been_pressed == true:
			has_esc_been_pressed = false
		
		## just here for leaving a multiplayer instance ##
		if Input.is_action_just_pressed("quit"):
			$"../".exit_game(name.to_int())
			get_tree().quit()
		
		if Input.is_action_just_pressed("Hit") and can_attack and !is_parying:
			
			hit()
			fpm_anims.stop()
			fpm_anims.play("hit")
			
		
		if hand.current_weapon != 0:
			var held_weapon = hand.weapons[hand.current_weapon]
			
			if !is_on_floor() and velocity.y < 0 and held_weapon == "Sword":
				attack_damage = hand.weapon_stats[held_weapon]["Damage"] * -velocity.y / 2
			else:
				attack_damage = hand.weapon_stats[held_weapon]["Damage"]
		
		
		if Input.is_action_just_pressed("Traits") and can_trait:
			if Global.equiped_things.has("Grapple") and grapple_cast.is_colliding() and grapple_stam > 0:
				#print("spider man, spidr man, dos whuteva a spidr kan")
				if grapple_cast.get_collider(0) is CharacterBody3D:
					hooked_player = grapple_cast.get_collider(0)
				grapple_point = grapple_cast.get_collision_point(0)
				can_regen_stam = false
				
				line_renderer_3d.visible = true
			elif Global.equiped_things.has("Parry"):
				#print("hey, look at thi- AAAAAAGGGHHHHHHHHH")
				is_parying = true
				can_trait = false
				trait_cooldown.start(10)
				parry_timer.start(0.75)
		
		
		if grapple_point:
			
			if hooked_player:
				grapple_point = hooked_player.global_position
			
			line_renderer_3d.points[0] = $"head/GrappleLineFPM Marker".global_position
			line_renderer_3d.points[1] = grapple_point
			velocity += global_position.direction_to(grapple_point)
			
			grapple_stam -= 1
			
			if global_position.distance_to(grapple_point) < 2 or !Input.is_action_pressed("Traits") or health <= 0 or grapple_stam <= 0:
				grapple_point = Vector3()
				line_renderer_3d.visible = false
				hooked_player = null
		


func _on_dash_timer_timeout():
	is_dashing = false



func dash(dash_speed : int, additive = true):
	var dash_velocity = Vector3()
	dash_velocity = Vector3(0,0,-dash_speed).rotated(Vector3(1, 0, 0), head.rotation.x)
	dash_velocity = dash_velocity.rotated(Vector3(0, 1, 0), rotation.y)
	if additive == false:
		velocity = dash_velocity
	else:
		velocity += dash_velocity
	
	cam.fov += float(dash_speed)/4
	dash_timer.paused = false
	is_dashing = true
	can_dash = false
	dash_timer.start()

func hit(lifesteal = false, extra_damage = 0):
	#print("Trying to hit :]")
	#arm_animtree.set("parameters/Hitting/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	arm_anims.pause()
	arm_anims.play("Hit")
	
	## Actual Attack Code ##
	if hit_bar.is_colliding() and hit_connected == false and hit_bar.get_collider(0) is CharacterBody3D:
		#hit_sfx.pitch_scale = randf_range(0.8, 1)
		#hit_sfx.play()
		
		hit_connected = true
		$"../".send_signal(hit_bar.get_collider(0).name, "take_damage", attack_damage + extra_damage, self.name)
		
		if lifesteal == true:
			self.health += 25
		
		can_attack = false
		#hit_bar.enabled = true
		attack_length.start()
		attack_cooldown.start(attack_speed)

func ability():
	var weapon_in_use = hand.get_weapon(hand.current_weapon)
	if  weapon_in_use != null:
		if weapon_in_use.has_method("ability"):
			weapon_in_use.ability()
			ability_cooldown.start()
			can_ability = false
		fpm_anims.play("ability")

func take_damage(damage_amount, attacker):
	hit_sfx.pitch_scale = randf_range(0.8, 1)
	hit_sfx.play()
	
	if !is_parying:
		health -= damage_amount
	elif is_parying:
		if attacker:
			$"../".send_signal(attacker, "take_damage", damage_amount, self.name)
			is_parying = false
		else:
			can_trait = true
			velocity.y = JUMP_VELOCITY*4
			health -= 10
		
		speed = 100
	#print(health)
	if health <= 0 and !is_dead:
		is_dead = true
		if is_multiplayer_authority() and attacker != null and is_in_round: 
			$"../".rpc("add_point", attacker, 1)
		death_sfx.play()
		respawn_timer.start()

func _on_arm_animator_animation_finished(anim_name):
	if anim_name == "Hit" and  hand.current_weapon != 0:
		arm_anims.play("HoldingItem")
	else:
		arm_anims.stop()

func _on_attack_length_timeout():
	hit_connected = false

func load_weapon_stats(WeaponId):
	if hand.current_weapon != 0:
		hit_bar.target_position = Vector3(0, 0, -hand.weapon_stats[hand.weapons[WeaponId]]["Range"])
		attack_damage = hand.weapon_stats[hand.weapons[WeaponId]]["Damage"]
		attack_speed = hand.weapon_stats[hand.weapons[WeaponId]]["AttSpeed"]
		hit_bar.shape.size.x = hand.weapon_stats[hand.weapons[WeaponId]]["HitboxSize"]
		hit_bar.shape.size.y = hand.weapon_stats[hand.weapons[WeaponId]]["HitboxSize"]
		grav_multi = hand.weapon_stats[hand.weapons[WeaponId]]["GravMulti"]
		slowness = hand.weapon_stats[hand.weapons[WeaponId]]["Slowness"]
	elif hand.current_weapon == 0:
		hit_bar.target_position = Vector3(0, 0, 0)
		attack_damage = 0
		attack_speed = 0
		grav_multi = 1
		slowness = 0
	
	if is_multiplayer_authority():
		arm_anims.play("Hit")
	
	if is_multiplayer_authority():
		firstperson_models.switch_hand_model(WeaponId)


func _on_attack_cooldown_timeout():
	can_attack = true


func _on_respawn_timer_timeout():
	position = Vector3(0, 2, 0)
	health = 100
	is_dead = false


func _on_wave_dash_timer_timeout():
	can_wavedash = false
	#is_dashing = false


func _on_fpm_anims_animation_finished(anim_name):
	if anim_name == "hit":
		fpm_anims.play("RESET")


func _on_ability_cooldown_timeout():
	can_ability = true

func reset_position(going_to_round):
	grapple_point = Vector3()
	line_renderer_3d.visible = false
	hooked_player = null
	position = Vector3(0, 2, 0)
	health = 100
	if going_to_round == false:
		is_in_round = false
	if going_to_round == true:
		is_in_round = true
		score = 0

func add_point(Amount):
	score += Amount


func _on_parry_timer_timeout():
	is_parying = false


func _on_trait_cooldown_timeout():
	can_trait = true
