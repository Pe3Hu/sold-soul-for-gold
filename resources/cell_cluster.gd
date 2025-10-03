class_name CellClusterResource
extends Resource


var cells: Array[Vector2i]


func _init(start_cell_: Vector2i) -> void:
	cells.append(start_cell_)
	
func merge_with(cell_to_clusters_: Dictionary, cluster_: CellClusterResource) -> void:
	cells.append_array(cluster_.cells)
	
	for cell in cluster_.cells:
		cell_to_clusters_[cell] = self
