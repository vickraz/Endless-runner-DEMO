extends KinematicBody2D
class_name Player

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
var distance: float = 0.0
var state: int = RUN
var can_jump: bool = true
var want_to_jump: bool = false
var can_dash: bool = true
var ghost_timer: float = 0.0

onready var coyote_timer: Timer = $CoyoteTimer
onready var dash_timer: Timer = $DashTimer
onready var dash_reload_timer: Timer = $DashReloadTimer
onready var jump_buffer: Timer = $JumpBuffer
onready var anim: AnimationPlayer = $AnimationPlayer



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

################# GENERAL HELP FUNCTIONS ############################
func _move_player(delta: float) -> void:
	velocity.x = move_toward(velocity.x, MAX_SPEED, MAX_ACC * delta)
	velocity = move_and_slide(velocity, Vector2.UP)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, MAX_Y_VEL)
	
func _dash_movement(delta: float) -> void:
	velocity = velocity.move_toward(dash_direction * DASH_SPEED, DASH_ACC * delta)
	velocity = move_and_slide(velocity, Vector2.UP)

func pickup(type: String) -> void:
	print(type)

################## STATE FUNCTIONS ####################################

func _run_state(delta: float) -> void:
	if Input.is_action_just_pressed("Jump"):
		_enter_air_state(true)
		_move_player(delta)
		return
	elif Input.is_action_just_pressed("Dash") and can_dash:
		_enter_dash_state()
		_dash_movement(delta)
		return
	
	_move_player(delta)
	
	if not is_on_floor():
		_enter_air_state(false)

func _air_state(delta: float) -> void:
	if Input.is_action_just_pressed("Jump") and can_jump:
		_enter_air_state(true)
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
			_enter_air_state(true)

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

func _enter_air_state(jumping: bool) -> void:
	state = AIR
	if jumping:
		can_jump = false
		gravity = MIN_GRAVITY
		velocity.y = -JUMP_STRENGTH
		anim.play("Jump")
	else:
		gravity = NORM_GRAVITY
		can_jump = true
		coyote_timer.start()
		anim.play("Fall")

func enter_dead_state() -> void:
	state = DEAD

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
	dash_reload_timer.start()
	if is_on_floor():
		_enter_run_state()
	else:
		_enter_air_state(false)


func _on_DashReloadTimer_timeout() -> void:
	can_dash = true
