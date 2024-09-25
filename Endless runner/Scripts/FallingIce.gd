extends KinematicBody2D


const GRAVITY = 2000

enum {IDLE, FALL, EXPLODE}

onready var anim: AnimatedSprite = $AnimatedSprite
onready var ray: RayCast2D = $RayCast2D
onready var detectArea: Area2D = $PlayerDetectArea

var velocity: Vector2 = Vector2.ZERO

var state = IDLE

func _physics_process(delta: float) -> void:
	match state:
		IDLE:
			ray.force_raycast_update()
			if ray.is_colliding():
				var collider = ray.get_collider()
				if collider is Player:
					state = FALL
					ray.enabled = false
		FALL:
			velocity.y += GRAVITY * delta
			velocity = move_and_slide(velocity, Vector2.UP)
			if is_on_floor():
				state = EXPLODE
				anim.play("Explode")
				detectArea.monitoring = false
		EXPLODE:
			pass



func _on_PlayerDetectArea_body_entered(body: Node) -> void:
	if body is Player:
		body.enter_dead_state()


func _on_AnimatedSprite_animation_finished() -> void:
	if anim.animation == "Explode":
		queue_free()
