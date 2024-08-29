extends ParallaxBackground

onready var moving_layer: ParallaxLayer = $ParallaxLayer2

const MOVING_SPEED = 20

func _process(delta: float) -> void:
	moving_layer.motion_offset.x -= MOVING_SPEED * delta



