extends Node

const save_path = "res://saves/save_file.tres"

var save_file_data: SaveDataResource = SaveDataResource.new()


func _save(data_: SaveDataResource):
	ResourceSaver.save(data_, save_path)
	
func _load():
	if FileAccess.file_exists(save_path):
		save_file_data = ResourceLoader.load(save_path).duplicate(true)
