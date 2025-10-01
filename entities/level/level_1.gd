class_name Level
extends Node2D


@export var noise: FastNoiseLite
@export var rnd_seed: int = 8#7
@export_range(-0.6, 0.6, 0.01) var land_cap = 0.1
@export_range(-0.6, 0.6, 0.01) var rock_cap = -0.35

@onready var water_sprite: Sprite2D = %WaterSprite
@onready var ground_tilemap: TileMapLayer = %TileMapLayerGround
@onready var rock_tilemap: TileMapLayer = %TileMapLayerRock

const MAP_SIZE = Vector2(120, 120)
const TILE_SIZE = Vector2(16, 16)
const WATER_SIZE = Vector2(64, 64)


func init_cells():
	#Сentering TileMap
	position = -MAP_SIZE / 2 * TILE_SIZE
	noise.seed = rnd_seed #randi()
	
	#Cells generation
	var ground_cells = []
	var rock_cells = []
	
	for x in MAP_SIZE.x:
		for y in MAP_SIZE.y:
			var noise_value = noise.get_noise_2d(x, y)
			
			if noise_value < rock_cap:
				rock_cells.append(Vector2(x, y))
				rock_tilemap.set_cell(Vector2(x, y), 0, Vector2(17, 17), 0)
			if noise_value < land_cap:
				ground_cells.append(Vector2(x, y))
	
	ground_tilemap.set_cells_terrain_connect(ground_cells, 0, 0)
	
	#water shader sprite stretching
	scale_water_spirte()
	
func scale_water_spirte() -> void:
	water_sprite.scale = MAP_SIZE * TILE_SIZE / WATER_SIZE
