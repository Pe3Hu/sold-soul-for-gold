class_name World 
extends Node


@onready var enemy_scene = load("res://entities/unit/enemy/enemy.tscn")
@onready var level_1: Level = $Level1
@onready var enemies: Node2D = %Enemies
@onready var player: Player = %Player

@export var player_speed_multiplier: float = 1:
	set(value_):
		player.speed /= player_speed_multiplier
		player_speed_multiplier = value_
		player.speed *= player_speed_multiplier


func _ready():
	player_speed_multiplier = 2
	level_1.init_cells()
	init_enemies()
	
func init_enemies() -> void:
	var type = "gold"
	var position = Vector2(200, 100)
	type = "silver"
	position = Vector2(-100, 150)
	add_enemy(type, position)
	add_enemy(type, position)
	add_enemy(type, position)
	add_enemy(type, position)
	add_enemy(type, position)
	add_enemy(type, position)
	add_enemy(type, position)
	add_enemy(type, position)
	add_enemy(type, position)
	
func add_enemy(type_: String, position_: Vector2) -> void:
	var enemy = enemy_scene.instantiate()
	enemy.spawn_position = position_
	enemy.type = type_
	enemies.add_child(enemy)
	
func _input(event) -> void:
	if event is InputEventKey:
		match event.keycode:
			KEY_ESCAPE:
				get_tree().quit()
	
