extends Area2D






func _on_BlueGem_body_entered(body: Node) -> void:
	if body is Player:
		body.pickup("BlueGem")
		queue_free()
