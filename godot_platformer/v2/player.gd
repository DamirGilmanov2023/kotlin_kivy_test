extends CharacterBody2D
enum{
	MOVE,
	ATTACK,
	ATTACK2,
	ATTACK3,
	BLOCK,
	SLIDE
}

const SPEED = 150.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
#@onready var anim=get_node("AnimatedSprite2D")
@onready var anim=$AnimatedSprite2D
@onready var anim_player=$AnimationPlayer
var health=100
var gold=0
var state=MOVE
var run_speed=1
var combo=false
var attack_cooldown=false
var player_pos
func _physics_process(delta):
	player_pos=self.position
	Global.emit_signal("player_position_update",player_pos)
	match state:
		MOVE:
			move_state()
		ATTACK:
			attack_state()
		ATTACK2:
			attack2_state()
		ATTACK3:
			attack3_state()
		BLOCK:
			block_state()
		SLIDE:
			slide_state()
		
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	if velocity.y>0:
		anim_player.play("fall")
	if health<=0:
		health=0
		anim_player.play("death")
		await  anim_player.animation_finished
		queue_free()
		get_tree().change_scene_to_file("res://menu.tscn")

	move_and_slide()

func move_state():
	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED*run_speed
		if velocity.y==0:
			if run_speed==1:
				anim_player.play("walk")
			else:
				anim_player.play("run")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if velocity.y==0:
			anim_player.play("idle")
	if direction==-1:
		anim.flip_h=true
	elif direction==1:
		anim.flip_h=false
	if Input.is_action_pressed("run"):
		run_speed=2
	else:
		run_speed=1
	if Input.is_action_pressed("block"):
		if velocity.x==0:
			state=BLOCK
		else:
			state=SLIDE
	if Input.is_action_just_pressed("attack") and attack_cooldown==false:
		state=ATTACK
func block_state():
	velocity.x=0
	anim_player.play("block")
	if Input.is_action_just_released("block"):
		state=MOVE
func slide_state():
	anim_player.play("slide")
	await anim_player.animation_finished
	state=MOVE
func attack_state():
	if Input.is_action_just_pressed("attack") and combo==true:
		state=ATTACK2
	velocity.x=0
	anim_player.play("attack")
	await anim_player.animation_finished
	attack_freez()
	state=MOVE
func combo1():
	combo=true
	await anim_player.animation_finished
	combo=false
func attack2_state():
	if Input.is_action_just_pressed("attack") and combo==true:
		state=ATTACK3
	anim_player.play("attack2")
	await anim_player.animation_finished
	state=MOVE
func attack3_state():
	anim_player.play("attack3")
	await anim_player.animation_finished
	state=MOVE
func attack_freez():
	attack_cooldown=true
	await get_tree().create_timer(0.5).timeout
	attack_cooldown=false