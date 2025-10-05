extends Node


var tilemaps: Array[TileMapLayer] = []

const footstep_sounds = {
	"grass": [
		preload("res://assets/sounds/grass 1.wav"),
		preload("res://assets/sounds/grass 2.wav"),
		preload("res://assets/sounds/grass 3.wav"),
	]
}

func play_footstep(position_: Vector2):
	var tile_data = []
	for tilemap in tilemaps:
		var tile_position = tilemap.local_to_map(position_)
		var data = tilemap.get_cell_tile_data(tile_position)
		if data:
			tile_data.push_back(data)
	
	if tile_data.size() > 0:
		var tile_type = tile_data.back().get_custom_data("footstep_sound")
		
		if footstep_sounds.has(tile_type):
			var audio_player = AudioStreamPlayer2D.new()
			audio_player.stream = footstep_sounds[tile_type].pick_random()
			get_tree().root.add_child(audio_player)
			audio_player.global_position = position_
			audio_player.play()
			await audio_player.finished
			audio_player.queue_free()
