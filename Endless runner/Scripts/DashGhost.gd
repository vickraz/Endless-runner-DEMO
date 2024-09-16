extends Sprite





func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "Fade":
		queue_free()
