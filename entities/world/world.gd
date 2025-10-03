class_name World 
extends Node


@onready var enemy_scene = load("res://entities/unit/enemy/enemy.tscn")
@onready var coin_scene = load("res://entities/coin/coin.tscn")

@onready var level_1: Level = $Level1
@onready var enemies: Node2D = $Enemies
@onready var coins: Node2D = $Coins
@onready var player: Player = $Player
@onready var phantom_camera: PhantomCamera2D = $PhantomCamera2D

@export var menu: Menu

@export_range(1, 20, 1) var rand_coin_counter: int = 1
@export_range(1, 10, 1) var golden_enemy_counter: int = 3
@export_range(1, 20, 1) var silver_enemy_counter: int = 3
@export_range(2, 20, 1) var total_enemy_counter: int = 6:
	set(value_):
		total_enemy_counter = value_
		recalc_enemy_counters()

@export var player_speed: float = 160
@export var enemy_speed: float = 120

@export var is_enemy_guarding_coin: bool = false:
	set(value_):
		is_enemy_guarding_coin = value_
		
		menu.coin_counter.max_value = rand_coin_counter
		
		if is_enemy_guarding_coin:
			menu.coin_counter.max_value += total_enemy_counter
@export var is_pause: bool = true
@export var is_map_generated: bool = false
@export var is_win: bool = false


func _ready() -> void:
	level_1.init_cells()
	
func reset() -> void:
	is_pause = false
	is_map_generated = true
	is_win = false
	level_1.init_cells()
	init_player_start_position()
	init_enemies()
	init_coins()
	
func init_player_start_position() -> void:
	var cell = level_1.occupy_cell()
	var local_position = level_1.ground_tilemap.map_to_local(cell)
	player.position = level_1.ground_tilemap.to_global(local_position)
	player.visible = true
	level_1.apply_exclusion_zone(cell)
	
func recalc_enemy_counters() -> void:
	var options = ["silver", "silver", "golden"]
	golden_enemy_counter = 1
	silver_enemy_counter = 1
	
	for _i in total_enemy_counter - 2:
		var enemy_type = options.pick_random()
		var enemy_counter = get(enemy_type + "_enemy_counter")
		set(enemy_type + "_enemy_counter", enemy_counter + 1)
	
	#print([silver_enemy_counter, golden_enemy_counter])
	
func init_enemies() -> void:
	while enemies.get_child_count() > 0:
		var child = enemies.get_child(0)
		enemies.remove_child(child)
		child.queue_free()
	
	var type = "golden"
	
	for _i in golden_enemy_counter:
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
	while coins.get_child_count() > 0:
		var child = coins.get_child(0)
		coins.remove_child(child)
		child.queue_free()
	
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
	coin.world = self
	coin.position = position_
	coins.add_child(coin)
	
func _input(event) -> void:
	if event is InputEventKey:
		if event.is_pressed():
			match event.keycode:
				KEY_ESCAPE:
					if is_pause:
						if is_map_generated:
							menu.continue_gameplay()
					else:
						menu.set_on_pause()
