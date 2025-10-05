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
@export var is_loading: bool = false
@export var is_random_seed: bool = true


func _ready() -> void:
	level_1.init_cells()
	
func reset() -> void:
	is_pause = false
	is_map_generated = true
	is_win = false
	
	if player.animations.is_playing():
		player.animations.stop()
	
	player.animations.stop()
	player.animations.play("RESET")
	
	while coins.get_child_count() > 0:
		var child = coins.get_child(0)
		coins.remove_child(child)
		child.queue_free()
	
	while enemies.get_child_count() > 0:
		var child = enemies.get_child(0)
		enemies.remove_child(child)
		child.queue_free()
	
	level_1.init_cells()
	
	if !is_loading:
		init_player_start_position()
		init_coins()
		init_enemies()
	else:
		load_positions()
	
func init_player_start_position() -> void:
	var cell_coord = level_1.occupy_cell()
	var local_position = level_1.grass_tilemap.map_to_local(cell_coord)
	player.position = level_1.grass_tilemap.to_global(local_position)
	player.visible = true
	level_1.apply_exclusion_zone(cell_coord)
	level_1.surround_coord_with_rocks(cell_coord)
	
func recalc_enemy_counters() -> void:
	var options = ["silver", "silver", "golden"]
	golden_enemy_counter = 1
	silver_enemy_counter = 1
	
	for _i in total_enemy_counter - 2:
		var enemy_type = options.pick_random()
		var enemy_counter = get(enemy_type + "_enemy_counter")
		set(enemy_type + "_enemy_counter", enemy_counter + 1)
	
func init_enemies() -> void:
	var type = "golden"
	
	for _i in golden_enemy_counter:
		add_enemy(type, null)
	
	type = "silver"
	
	for _i in silver_enemy_counter:
		add_enemy(type, null)
	
	#for enemy in enemies.get_children():
	#	print([enemy.get_index(), enemy.position, enemy.global_position, enemy.spawn_position, enemy.target_milestones.front()])
	
func add_enemy(type_: String, loaded_index_: Variant) -> void:
	var enemy = enemy_scene.instantiate()
	enemy.level = level_1
	enemy.type = type_
	
	if loaded_index_ != null:
		enemies.add_child(enemy)
		enemy.spawn_position = SaveManager.save_file_data.enemies_spawn_positions[loaded_index_]
		enemy.position = SaveManager.save_file_data.enemies_current_positions[loaded_index_]
		enemy.current_state = SaveManager.save_file_data.enemies_states[loaded_index_]
		enemy.target_milestones = SaveManager.save_file_data.enemies_milestones_positions[loaded_index_]
		
	else:
		var cell_coord = level_1.occupy_cell()
		
		if cell_coord != null:
			var local_position = level_1.grass_tilemap.map_to_local(cell_coord)
			enemy.spawn_position = level_1.grass_tilemap.to_global(local_position)
			
			if is_enemy_guarding_coin:
				add_coin(enemy.spawn_position)
			
			enemies.add_child(enemy)
		else:
			print("no available cell for enemy")
	
func init_coins() -> void:
	var coord_first_coin = add_rnd_coin()
	level_1.surround_coord_with_rocks(coord_first_coin)
	
	for _i in rand_coin_counter - 1:
		add_rnd_coin()
	
func add_rnd_coin() -> Variant:
	var cell_coord = level_1.occupy_cell()
	
	if cell_coord != null:
		var local_position = level_1.grass_tilemap.map_to_local(cell_coord)
		var spawn_position = level_1.grass_tilemap.to_global(local_position)
		add_coin(spawn_position)
		return cell_coord
	else:
		print("no available cell for random coin")
	
	return null
	
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
				KEY_1:
					save_game()
				KEY_2:
					SaveManager._load()
	
func save_game() -> void:
	var save_data = SaveDataResource.new()
	save_data.seed_index = level_1.noise.seed
	save_data.coins_collected = menu.coin_counter.current_value
	save_data.player_position = player.global_position
	save_data.cage_coords = level_1.cage_coords
	
	for coin in coins.get_children():
		save_data.coin_positions.append(coin.global_position)
	
	for enemy in enemies.get_children():
		save_data.enemies_states.append(enemy.current_state)
		save_data.enemies_types.append(enemy.type)
		save_data.enemies_current_positions.append(enemy.position)
		save_data.enemies_spawn_positions.append(enemy.spawn_position)
		save_data.enemies_milestones_positions.append(enemy.target_milestones)
	
	SaveManager._save(save_data)
	
func load_positions() -> void:
	player.global_position = SaveManager.save_file_data.player_position
	player.visible = true
	level_1.cage_coords = SaveManager.save_file_data.cage_coords
	
	menu.coin_counter.current_value = SaveManager.save_file_data.coins_collected
	
	for coin_position in SaveManager.save_file_data.coin_positions:
		add_coin(coin_position)
	
	for _i in SaveManager.save_file_data.enemies_current_positions.size():
		var type = SaveManager.save_file_data.enemies_types[_i]
		add_enemy(type, _i) 
