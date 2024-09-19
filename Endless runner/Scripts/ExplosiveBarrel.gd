extends Area2D


const EXPLOSION_SCENE = preload("res://Scenes/BarrelExplosion.tscn")



func _on_ExplosiveBarrel_body_entered(body: Node) -> void:
	if body is Player:
		body.enter_dead_state()
		var explosion = EXPLOSION_SCENE.instance()
		explosion.global_position = global_position
		get_parent().add_child(explosion)
		queue_free()
