extends KinematicBody2D


const MIN_GRAVITY = 1000
const NORM_GRAVITY = 2000
const MAX_GRAVITY = 4000
const JUMP_STRENGTH = 800
const MAX_SPEED = 500

var velocity: Vector2 = Vector2.ZERO
var gravity: int = NORM_GRAVITY
var distance: float = 0.0

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = -JUMP_STRENGTH
		gravity = MIN_GRAVITY
	elif Input.is_action_just_released("Jump"):
		gravity = NORM_GRAVITY
	
	velocity = move_and_slide(velocity, Vector2.UP)
	
	velocity.y += gravity * delta
	

