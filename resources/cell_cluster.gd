class_name CoordClusterResource
extends Resource


var coords: Array[Vector2i]


func _init(start_coord_: Vector2i) -> void:
	coords.append(start_coord_)
	
func merge_with(coord_to_clusters_: Dictionary, cluster_: CoordClusterResource) -> void:
	coords.append_array(cluster_.coords)
	
	for coord in cluster_.coords:
		coord_to_clusters_[coord] = self
