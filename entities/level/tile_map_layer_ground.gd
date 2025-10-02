extends TileMapLayer


@export var rock_layer: TileMapLayer


func _use_tile_data_runtime_update(coords_: Vector2i) -> bool:
	if coords_ in rock_layer.get_used_cells_by_id(0):
		return true
	
	return false
	
func _tile_data_runtime_update(_coords: Vector2i, tile_data: TileData) -> void:
	tile_data.set_navigation_polygon(0, null)
