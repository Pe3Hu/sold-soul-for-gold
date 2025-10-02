class_name Level
extends Node2D


@export var noise: FastNoiseLite
@export var rnd_seed: int = 19#7
@export_range(-0.6, 0.6, 0.01) var land_cap: float = 0.1
@export_range(-0.6, 0.6, 0.01) var rock_cap: float = -0.35
@export_range(1, 10, 1) var jump_cell_distance: int = 10
@export_range(1, 10, 1) var enemy_follow_cell_distance: int:
	set(value_):
		enemy_follow_cell_distance = value_
		enemy_follow_distance = enemy_follow_cell_distance * TILE_SIZE.x

@onready var water_sprite: Sprite2D = $WaterSprite
@onready var ground_tilemap: TileMapLayer = $TileMapLayerGround
@onready var rock_tilemap: TileMapLayer = $TileMapLayerRock
@onready var jump_cell: ColorRect = $JumpCell

const MAP_SIZE = Vector2i(40, 40)
const TILE_SIZE = Vector2(16, 16)
const WATER_SIZE = Vector2(64, 64)

var available_cells: Array[Vector2i]
var occupied_cells: Array[Vector2i]
var exiled_cells: Array[Vector2i]

var enemy_follow_distance: float 


func init_cells():
	enemy_follow_cell_distance = 10
	
	#Сentering TileMap
	#position = -Vector2(MAP_SIZE) / 2 * TILE_SIZE
	noise.seed = rnd_seed #randi()
	
	#Cells generation
	var ground_cells: Array[Vector2i]
	var rock_cells: Array[Vector2i]
	
	for x in MAP_SIZE.x:
		for y in MAP_SIZE.y:
			var noise_value = noise.get_noise_2d(x, y)
			
			if noise_value < rock_cap:
				rock_cells.append(Vector2i(x, y))
				rock_tilemap.set_cell(Vector2(x, y), 0, Vector2(17, 17), 0)
			if noise_value < land_cap:
				ground_cells.append(Vector2i(x, y))
	
	ground_tilemap.set_cells_terrain_connect(ground_cells, 0, 0)
	init_exiled_cells(ground_cells)
	available_cells = ground_cells.filter(func (a): return !rock_cells.has(a))
	available_cells = available_cells.filter(func (a): return !exiled_cells.has(a))
	
	#water shader sprite stretching
	scale_water_spirte()
	
func init_exiled_cells(ground_cells_: Array[Vector2i]) -> void:
	var directions = [
		Vector2i( 0,-1),
		Vector2i( 1, 0),
		Vector2i( 0, 1),
		Vector2i(-1, 0)
	]
	
	var cell_to_clusters = {}
	var all_clusters = []
	
	for cell in ground_cells_:
		var main_cluster = CellClusterResource.new(cell)
		var neighboring_clusters = []
		
		for direction in directions:
			var neighboring_cell = cell + direction
			
			if cell_to_clusters.has(neighboring_cell):
				var neighboring_cluster = cell_to_clusters[neighboring_cell]
				
				if !neighboring_clusters.has(neighboring_cluster):
					neighboring_clusters.append(neighboring_cluster)
		
		if !neighboring_clusters.is_empty():
			main_cluster = neighboring_clusters.pop_back()
			
			while !neighboring_clusters.is_empty():
				var secondary_cluster = neighboring_clusters.pop_back()
				main_cluster.merge_with(cell_to_clusters, secondary_cluster)
				all_clusters.erase(secondary_cluster)
			
			main_cluster.cells.append(cell)
		else:
			all_clusters.append(main_cluster)
		
		cell_to_clusters[cell] = main_cluster
	
	var biggest_cluster = all_clusters.front()
	
	for cluster in all_clusters:
		if biggest_cluster.cells.size() < cluster.cells.size():
			biggest_cluster = cluster
	
	#all_clusters.sort_custom(func(a, b): a.cells.size() < b.cells.size())
	
	for cluster in all_clusters:
		if cluster != biggest_cluster:
			exiled_cells.append_array(cluster.cells)
	
func scale_water_spirte() -> void:
	water_sprite.scale = Vector2(MAP_SIZE) * TILE_SIZE / WATER_SIZE
	
func occupy_cell() -> Variant:
	if available_cells.is_empty(): return null
	
	var cell = available_cells.pick_random()
	available_cells.erase(cell)
	occupied_cells.append(cell)
	return cell
