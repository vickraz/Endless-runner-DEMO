extends KinematicBody2D


const MIN_GRAVITY = 1000
const NORM_GRAVITY = 2000
const MAX_GRAVITY = 4000
const JUMP_STRENGTH = 800
const MAX_SPEED = 500
const MAX_ACC = 400
const MAX_Y_VEL = 1000

enum {RUN, AIR, DEAD}

var velocity: Vector2 = Vector2.ZERO
var gravity: int = NORM_GRAVITY
var distance: float = 0.0
var state: int = RUN


func _physics_process(delta: float) -> void:
	match state:
		RUN: 
			_run_state(delta)
		AIR:
			_air_state(delta)
		DEAD: 
			_dead_state()

################# GENERAL HELP FUNCTIONS ############################
func _move_player(delta: float) -> void:
	velocity.x = move_toward(velocity.x, MAX_SPEED, MAX_ACC * delta)
	velocity = move_and_slide(velocity, Vector2.UP)
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, MAX_Y_VEL)
	


################## STATE FUNCTIONS ####################################

func _run_state(delta: float) -> void:
	pass

func _air_state(delta: float) -> void:
	pass

func _dead_state() -> void:
	pass


################## ENTER STATE FUNCTIONS ##############################
func _enter_run_state() -> void:
	state = RUN

func _enter_air_state(jumping: bool) -> void:
	state = AIR
	if jumping:
		velocity.y = -JUMP_STRENGTH

func enter_dead_state() -> void:
	state = DEAD


	"""
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = -JUMP_STRENGTH
		gravity = MIN_GRAVITY
	elif Input.is_action_just_released("Jump"):
		gravity = NORM_GRAVITY
	
	if Input.is_action_pressed("Down") and not is_on_floor():
		gravity = MAX_GRAVITY
	
	_move_player(delta)
"""
