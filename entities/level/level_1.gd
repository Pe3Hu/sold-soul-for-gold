class_name Level
extends Node2D


@export var world: World
@export var camera_bounce_collision_shape: CollisionShape2D
@export var noise: FastNoiseLite
@export_range(-0.6, 0.6, 0.01) var land_cap: float = 0.1
@export_range(-0.6, 0.6, 0.01) var rock_cap: float = -0.35
@export_range(0.1, 0.9, 0.01) var available_cap: float = 0.3
@export_range(1, 10, 1) var jump_cell_distance: int = 3
@export_range(1, 10, 1) var enemy_follow_coord_distance: int:
	set(value_):
		enemy_follow_coord_distance = value_
		enemy_follow_distance = enemy_follow_coord_distance * TILE_SIZE.x
@export_range(1, 10, 1) var spawn_exclusion_zone: int = 5
@export_range(1, 5, 1) var rock_cage_size: int = 2
@export var custom_seed: int = 0#7 21 160229687

@onready var water_sprite: Sprite2D = $WaterSprite
@onready var grass_tilemap: TileMapLayer = $TileMapLayerGrass
@onready var rock_tilemap: TileMapLayer = $TileMapLayerRock
@onready var jump_cell: ColorRect = $JumpCell

const MAP_SIZE = Vector2i(30, 30)
const TILE_SIZE = Vector2(16, 16)
const WATER_SIZE = Vector2(64, 64)

const LINEAR_DIRECTIONS = [
	Vector2i( 0,-1),
	Vector2i( 1, 0),
	Vector2i( 0, 1),
	Vector2i(-1, 0)
	]
const DIAGONAL_DIRECTIONS = [
	Vector2i( 1,-1),
	Vector2i( 1, 1),
	Vector2i(-1, 1),
	Vector2i(-1,-1)
]

var available_coords: Array[Vector2i]
var occupied_coords: Array[Vector2i]
var exiled_coords: Array[Vector2i]
var cage_coords: Array[Vector2i]

var enemy_follow_distance: float 


func _ready() -> void:
	enemy_follow_coord_distance = 10
	
func reset() -> void:
	rock_tilemap.clear()
	grass_tilemap.clear()
	
	available_coords.clear()
	occupied_coords.clear()
	exiled_coords.clear()
	cage_coords.clear()
	
func init_cells():
	reset()
	
	#Сentering TileMap
	if world.is_random_seed and !world.is_loading:
		noise.seed = randi()
	else:
		if world.is_loading:
			custom_seed = SaveManager.save_file_data.seed_index
		
		noise.seed = custom_seed
	
	#Cells generation
	var grass_coords: Array[Vector2i]
	var rock_coords: Array[Vector2i]
	
	for x in MAP_SIZE.x:
		for y in MAP_SIZE.y:
			var noise_value = noise.get_noise_2d(x, y)
			var coord = Vector2i(x, y)
			
			if noise_value < rock_cap:
				rock_coords.append(coord)
				set_coord_as_rock(coord)
			if noise_value < land_cap:
				grass_coords.append(coord)
	
	grass_tilemap.set_cells_terrain_connect(grass_coords, 0, 0)
	init_exiled_coords(grass_coords)
	available_coords = grass_coords.filter(func (a): return !rock_coords.has(a))
	available_coords = available_coords.filter(func (a): return !exiled_coords.has(a))
	
	var available_space_percent = float(available_coords.size()) / MAP_SIZE.x / MAP_SIZE.y
	
	if available_space_percent > available_cap:
		#water shader sprite stretching
		scale_water_spirte()
		
		#set camera limits
		resize_camera_collision_shape()
	else:
		init_cells()
	
	if world.is_loading:
		load_cage_cells()
	
func set_coord_as_rock(coord_: Vector2i) -> void:
	rock_tilemap.set_cell(coord_, 0, Vector2(17, 17), 0)

func init_exiled_coords(grass_coords_: Array[Vector2i]) -> void:
	var coord_to_clusters = {}
	var all_clusters = []
	
	for coord in grass_coords_:
		var main_cluster = CoordClusterResource.new(coord)
		var adjacent_clusters = []
		
		for direction in LINEAR_DIRECTIONS:
			var adjacent_coord = coord + direction
			
			if coord_to_clusters.has(adjacent_coord):
				var adjacent_cluster = coord_to_clusters[adjacent_coord]
				
				if !adjacent_clusters.has(adjacent_cluster):
					adjacent_clusters.append(adjacent_cluster)
		
		if !adjacent_clusters.is_empty():
			main_cluster = adjacent_clusters.pop_back()
			
			while !adjacent_clusters.is_empty():
				var secondary_cluster = adjacent_clusters.pop_back()
				main_cluster.merge_with(coord_to_clusters, secondary_cluster)
				all_clusters.erase(secondary_cluster)
			
			main_cluster.coords.append(coord)
		else:
			all_clusters.append(main_cluster)
		
		coord_to_clusters[coord] = main_cluster
	
	var biggest_cluster = all_clusters.front()
	
	for cluster in all_clusters:
		if biggest_cluster.coords.size() < cluster.coords.size():
			biggest_cluster = cluster
	
	for cluster in all_clusters:
		if cluster != biggest_cluster:
			exiled_coords.append_array(cluster.coords)
	
func scale_water_spirte() -> void:
	water_sprite.scale = Vector2(MAP_SIZE) * TILE_SIZE / WATER_SIZE
	
func resize_camera_collision_shape() -> void:
	camera_bounce_collision_shape.shape.size = Vector2(MAP_SIZE) * TILE_SIZE 
	var camera_area = camera_bounce_collision_shape.get_parent()
	camera_area.position = Vector2(MAP_SIZE) * TILE_SIZE / 2
	
func occupy_cell() -> Variant:
	if available_coords.is_empty(): return null
	
	var cell = available_coords.pick_random()
	available_coords.erase(cell)
	occupied_coords.append(cell)
	return cell
	
func apply_exclusion_zone(coord_: Vector2i) -> void:
	available_coords = available_coords.filter(func (a): return coord_.distance_to(a) > spawn_exclusion_zone)
	
func surround_coord_with_rocks(coord_: Variant) -> void:
	if coord_ == null: return
	
	cage_coords.append(coord_)
	coord_ = Vector2i(coord_)
	var current_coord_ring = [coord_]
	var visited_coords = [coord_]
	var directions = []
	directions.append_array(LINEAR_DIRECTIONS)
	directions.append_array(DIAGONAL_DIRECTIONS)
	
	for _i in rock_cage_size:
		var last_coord_ring = current_coord_ring.duplicate()
		current_coord_ring.clear()
		
		for coord in last_coord_ring:
			for direction in directions:
				var adjacent_coord = coord + direction
				
				if !visited_coords.has(adjacent_coord) and !current_coord_ring.has(adjacent_coord):
					current_coord_ring.append(adjacent_coord)
		
		visited_coords.append_array(current_coord_ring)
	
	current_coord_ring = current_coord_ring.filter(func (a): return inside_map_check(a))
	
	for coord in current_coord_ring:
		set_coord_as_rock(coord)
	
	available_coords = available_coords.filter(func (a): return !visited_coords.has(a))
	
func inside_map_check(coord_: Vector2i) -> bool:
	if coord_.x < 0 or coord_.x > TILE_SIZE.x * 2 - 1 or coord_.y < 0 or coord_.y > TILE_SIZE.y  * 2  - 1: return false
	
	var tile_id = grass_tilemap.get_cell_tile_data(coord_)
	if tile_id == null: return false
	
	var flag = tile_id.get_custom_data("walkable")
	return flag
	
func load_cage_cells() -> void:
	for coord in SaveManager.save_file_data.cage_coords:
		surround_coord_with_rocks(coord)
