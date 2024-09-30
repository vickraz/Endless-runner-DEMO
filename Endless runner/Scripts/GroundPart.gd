extends Node2D


const BARREL_SCENE = preload("res://Scenes/ExplosiveBarrel.tscn")



var player: Player = null

func _ready() -> void:
	randomize()
	player = get_parent().get_parent().get_node("Player")
	
	for node in get_children():
		if "Barrel" in node.name:
			var r = randi() % 2
			if r == 0:
				var barrel = BARREL_SCENE.instance()
				node.add_child(barrel)


func _process(delta: float) -> void:
	if player:
		if $Edge.global_position.x < player.global_position.x - 500:
			queue_free()
			
