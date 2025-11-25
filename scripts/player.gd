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

var health = 100
var attack_damage = 0
var attack_speed = 0
var can_attack = true
var hit_connected = false

@onready var head = $head
@onready var cam = $head/Camera3D
@onready var model_head = $TempPlayerModel/Blobert/UpperBody/Head
@onready var animation_player = $TempPlayerModel/AnimationPlayer
@onready var dash_timer = $Timers/DashAnimTimer
@onready var arm_anims = $TempPlayerModel/ArmAnimator
@onready var hand = $TempPlayerModel/Blobert/UpperBody/RightArm/GripSpot
@onready var nametag = $Nametag
@onready var arm_animtree = $TempPlayerModel/AnimationTree
@onready var hit_bar = $head/HitBar
@onready var attack_length = $Timers/AttackLength
@onready var attack_cooldown = $Timers/AttackCooldown
@onready var respawn_timer = $Timers/RespawnTimer
@onready var health_bar = $head/Camera3D/CanvasLayer/MarginContainer/HealthBar
@onready var firstperson_models = $head/FirstpersonModels
@onready var wave_dash_timer = $Timers/WaveDashTimer
@onready var fpm_anims = $"head/FPM Anims"
@onready var ability_cooldown = $Timers/AbilityCooldown
@onready var hit_sfx = $SoundFX/hit_sfx
@onready var death_sfx = $SoundFX/death_sfx
@onready var attack_icon = $head/Camera3D/CanvasLayer/CanAttack
@onready var ability_icon = $head/Camera3D/CanvasLayer/AbilityAvailable


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
	
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	#print(Input.mouse_mode)
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#print(Input.mouse_mode)
	if is_multiplayer_authority(): 
		animation_player.play("Idle")
		hit_bar.add_exception(self)

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
		
		if Input.is_action_just_pressed("SwitchLeft"):
			hand.switch_weapon(-1)
		elif Input.is_action_just_pressed("SwitchRight"):
			hand.switch_weapon(1)
		
		if can_attack:
			attack_icon.visible = hit_bar.is_colliding()
		else:
			attack_icon.visible = false
		
		ability_icon.visible = can_ability
		
		health_bar.value = health
		
		speed = clamp(speed, 0, 24)
		
		# Add the gravity.
		if not is_on_floor():
			velocity.y += gravity * delta
			friction = 0.01
		else:
			friction = 0.1 
		
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
		#else:
		#	velocity.x = lerp(velocity.x, 0.0, friction)
		#	velocity.z = lerp(velocity.z, 0.0, friction)
		
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
		
		if Input.is_action_just_pressed("Hit") and can_attack:
			
			hit()
			fpm_anims.stop()
			fpm_anims.play("hit")
			
		
		if hand.current_weapon != 0:
			var held_weapon = hand.weapons[hand.current_weapon]
			
			if !is_on_floor() and velocity.y < 0 and held_weapon == "Sword":
				attack_damage = hand.weapon_stats[held_weapon]["Damage"] * -velocity.y / 2
			else:
				attack_damage = hand.weapon_stats[held_weapon]["Damage"]
		
		
		


func _on_dash_timer_timeout():
	is_dashing = false



func dash(dash_speed : int):
	var dash_velocity = Vector3()
	dash_velocity = Vector3(0,0,-dash_speed).rotated(Vector3(1, 0, 0), head.rotation.x)
	dash_velocity = dash_velocity.rotated(Vector3(0, 1, 0), rotation.y)
	velocity = dash_velocity
	
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
		$"../".send_signal(hit_bar.get_collider(0).name, "take_damage", attack_damage + extra_damage)
		
		if lifesteal == true:
			self.health += 50
		
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

func take_damage(damage_amount):
	hit_sfx.pitch_scale = randf_range(0.8, 1)
	hit_sfx.play()
	
	health -= damage_amount
	#print(health)
	if health <= 0:
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
	elif hand.current_weapon == 0:
		hit_bar.target_position = Vector3(0, 0, 0)
		attack_damage = 0
		attack_speed = 0
	
	if is_multiplayer_authority():
		arm_anims.play("Hit")
	
	if is_multiplayer_authority():
		firstperson_models.switch_hand_model(WeaponId)


func _on_attack_cooldown_timeout():
	can_attack = true


func _on_respawn_timer_timeout():
	position = Vector3(0, 1, 0)
	health = 100


func _on_wave_dash_timer_timeout():
	can_wavedash = false
	#is_dashing = false


func _on_fpm_anims_animation_finished(anim_name):
	if anim_name == "hit":
		fpm_anims.play("RESET")


func _on_ability_cooldown_timeout():
	can_ability = true
