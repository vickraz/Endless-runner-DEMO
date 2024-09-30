extends Node2D


export var level: int = 1
export var number_of_parts: int = 1

var path: String = "res://Scenes/Groundparts/Level" + str(level) + "_"

onready var edge: Position2D = get_node("Start level " + str(level) + "/Edge")

onready var player: Player = get_parent().get_node("Player")

func _ready() -> void:
	randomize()

func _process(delta: float) -> void:
	if player.global_position.x > edge.global_position.x - 600:
		_spawn_ground()


func _spawn_ground() -> void:
	var r = randi() % number_of_parts
	var ground = load(path + str(r) + ".tscn")
	var g = ground.instance()
	g.global_position = Vector2(edge.global_position.x + rand_range(150, 250), 0)
	add_child(g)
	edge = g.get_node("Edge")
	


