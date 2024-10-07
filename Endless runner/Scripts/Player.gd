extends KinematicBody2D
class_name Player

signal dead(distance)

const DASH_GHOST_SCENE = preload("res://Scenes/DashGhost.tscn")

const MIN_GRAVITY = 1000
const NORM_GRAVITY = 2000
const MAX_GRAVITY = 4000
const JUMP_STRENGTH = 800
const MAX_SPEED = 500
const MAX_ACC = 400
const MAX_Y_VEL = 1000
const DASH_SPEED = 900
const DASH_ACC = 4000
const GHOST_WAIT_TIME = 0.05

enum {RUN, AIR, DASH, DEAD}

var velocity: Vector2 = Vector2.ZERO
var dash_direction: Vector2 = Vector2.RIGHT
var gravity: int = NORM_GRAVITY
var distance: int = 0
var state: int = RUN
var can_jump: bool = true
var want_to_jump: bool = false
var can_dash: bool = false
var ghost_timer: float = 0.0

onready var coyote_timer: Timer = $CoyoteTimer
onready var dash_timer: Timer = $DashTimer
onready var jump_buffer: Timer = $JumpBuffer
onready var anim: AnimationPlayer = $AnimationPlayer
onready var downSlopeRay: RayCast2D = $DownSlopeRay
onready var distance_label: Label = $HUD/DistanceLabel

onready var start_x: float = global_position.x

func _physics_process(delta: float) -> void:
	match state:
		RUN: 
			_run_state(delta)
		AIR:
			_air_state(delta)
		DASH:
			_dash_state(delta)
		DEAD: 
			_dead_state()
	
	distance = (global_position.x - start_x) / 20
	distance_label.text = "Distance " + str(distance) + " m"
	if global_position.y > 620:
		enter_dead_state()

################# GENERAL HELP FUNCTIONS ############################
func _move_player(delta: float) -> void:
	if _on_down_slope():
		velocity = velocity.move_toward(Vector2.RIGHT.rotated(PI / 4) * MAX_SPEED * 2.5, 
										NORM_GRAVITY * delta)
	else:
		velocity.x = move_toward(velocity.x, MAX_SPEED, MAX_ACC * delta)
		velocity.y += gravity * delta
		velocity.y = min(velocity.y, MAX_Y_VEL)
		
	velocity = move_and_slide_with_snap(velocity, Vector2.DOWN * 10, Vector2.UP, true, 4, deg2rad(45), true)
	
	
func _dash_movement(delta: float) -> void:
	velocity = velocity.move_toward(dash_direction * DASH_SPEED, DASH_ACC * delta)
	velocity = move_and_slide(velocity, Vector2.UP)

func _on_down_slope() -> bool:
	downSlopeRay.force_raycast_update()
	if downSlopeRay.is_colliding():
		var norm: Vector2 = downSlopeRay.get_collision_normal()
		if is_equal_approx(norm.angle(), - PI / 4):
			return true
	return false

func pickup(type: String) -> void:
	if type == "BlueGem":
		can_dash = true

################## STATE FUNCTIONS ####################################

func _run_state(delta: float) -> void:
	if Input.is_action_just_pressed("Jump"):
		_enter_air_state(true, RUN)
		_move_player(delta)
		return
	elif Input.is_action_just_pressed("Dash") and can_dash:
		_enter_dash_state()
		_dash_movement(delta)
		return
	
	_move_player(delta)
	
	if not is_on_floor():
		_enter_air_state(false, RUN)

func _air_state(delta: float) -> void:
	if Input.is_action_just_pressed("Jump") and can_jump:
		_enter_air_state(true, AIR)
	elif Input.is_action_just_pressed("Jump") and not can_jump:
		jump_buffer.start()
		want_to_jump = true
	elif Input.is_action_just_pressed("Dash") and can_dash:
		_enter_dash_state()
		_dash_movement(delta)
		return
	elif Input.is_action_just_released("Jump"):
		gravity = NORM_GRAVITY
	if Input.is_action_pressed("Down"):
		gravity = MAX_GRAVITY
	elif Input.is_action_just_released("Down"):
		gravity = NORM_GRAVITY
	
	_move_player(delta)
	
	if velocity.y > 0 and anim.current_animation != "Fall":
		anim.play("Fall")
		
	
	if is_on_floor():
		if not want_to_jump:
			_enter_run_state()
		else:
			_enter_air_state(true, AIR)

func _dead_state() -> void:
	pass


func _dash_state(delta: float) -> void:
	dash_direction.y = Input.get_axis("Jump", "Down")
	dash_direction = dash_direction.normalized()
	_dash_movement(delta)
	
	ghost_timer += delta
	if ghost_timer > GHOST_WAIT_TIME:
		ghost_timer = 0.0
		var ghost = DASH_GHOST_SCENE.instance()
		ghost.global_position = global_position
		ghost.frame = $Sprite.frame
		get_parent().add_child(ghost)

################## ENTER STATE FUNCTIONS ##############################
func _enter_run_state() -> void:
	state = RUN
	gravity = NORM_GRAVITY
	anim.play("Run")

func _enter_air_state(jumping: bool, from_state: int) -> void:
	state = AIR
	if jumping:
		can_jump = false
		gravity = MIN_GRAVITY
		velocity.y = -JUMP_STRENGTH
		anim.play("Jump")
	else:
		gravity = NORM_GRAVITY
		if from_state != DASH:
			can_jump = true
			coyote_timer.start()
		anim.play("Fall")

func enter_dead_state() -> void:
	state = DEAD
	$Sprite.hide()
	$BloodParticles.emitting = true
	emit_signal("dead", distance)
	if state == DASH:
		dash_timer.paused = true
		set_physics_process(false)

func _enter_dash_state() -> void:
	if velocity.y > 0:
		velocity.y = 0
	state = DASH
	can_dash = false
	dash_timer.start()
	dash_direction = Vector2.RIGHT

####################### SIGNALS ############################################
func _on_CoyoteTimer_timeout() -> void:
	can_jump = false


func _on_JumpBuffer_timeout() -> void:
	want_to_jump = false


func _on_DashTimer_timeout() -> void:
	if is_on_floor():
		_enter_run_state()
	else:
		_enter_air_state(false, DASH)

