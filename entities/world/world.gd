class_name World 
extends Node


@onready var enemy_scene = load("res://entities/unit/enemy/enemy.tscn")
@onready var coin_scene = load("res://entities/coin/coin.tscn")

@onready var level_1: Level = $Level1
@onready var enemies: Node2D = $Enemies
@onready var coins: Node2D = $Coins
@onready var player: Player = $Player

@export_range(1, 10, 1) var gold_enemy_counter: int = 3
@export_range(1, 20, 1) var silver_enemy_counter: int = 6
@export_range(3, 20, 1) var rand_coin_counter: int = 2
@export var player_speed_multiplier: float = 1:
	set(value_):
		player.speed /= player_speed_multiplier
		player_speed_multiplier = value_
		player.speed *= player_speed_multiplier

@export var is_enemy_guarding_coin: bool = false


func _ready():
	player_speed_multiplier = 2
	level_1.init_cells()
	init_player_start_position()
	init_enemies()
	init_coins()
	
func init_player_start_position() -> void:
	var cell = level_1.occupy_cell()
	var local_position = level_1.ground_tilemap.map_to_local(cell)
	player.position = level_1.ground_tilemap.to_global(local_position)
	
func init_enemies() -> void:
	var type = "gold"
	
	for _i in gold_enemy_counter:
		add_enemy(type)
	
	type = "silver"
	
	for _i in silver_enemy_counter:
		add_enemy(type)
	
func add_enemy(type_: String) -> void:
	var cell = level_1.occupy_cell()
	
	if cell != null:
		var enemy = enemy_scene.instantiate()
		var local_position = level_1.ground_tilemap.map_to_local(cell)
		enemy.spawn_position = level_1.ground_tilemap.to_global(local_position)
		enemy.type = type_
		enemy.level = level_1
		enemies.add_child(enemy)
	else:
		print("no available cell for enemy")
	
func init_coins() -> void:
	if is_enemy_guarding_coin:
		for enemy in enemies.get_children():
			var spawn_position = enemy.position
			add_coin(spawn_position)
	
	for _i in rand_coin_counter:
		add_rnd_coin()
	
func add_rnd_coin() -> void:
	var cell = level_1.occupy_cell()
	
	if cell != null:
		var local_position = level_1.ground_tilemap.map_to_local(cell)
		var spawn_position = level_1.ground_tilemap.to_global(local_position)
		add_coin(spawn_position)
	else:
		print("no available cell for random coin")
	
func add_coin(position_: Vector2) -> void:
	var coin = coin_scene.instantiate()
	coin.position = position_
	coins.add_child(coin)
	
func _input(event) -> void:
	if event is InputEventKey:
		match event.keycode:
			KEY_ESCAPE:
				get_tree().quit()
	
