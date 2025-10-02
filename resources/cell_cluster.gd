class_name CellClusterResource
extends Resource


var cells: Array[Vector2i]


func _init(start_cell_: Vector2i) -> void:
	cells.append(start_cell_)
	
func merge_with(cell_to_clusters_: Dictionary, cluster_: CellClusterResource) -> void:
	cells.append_array(cluster_.cells)
	
	for cell in cluster_.cells:
		cell_to_clusters_[cell] = self
		
	#var new_cells = cluster_.cells.filter(func(a): return !cells.has(a))
	#cells.append_array(new_cells)
	#
	#for cell in new_cells:
		#cell_to_clusters_[cell] = self
