class_name Player
extends Unit


func _physics_process(delta_: float) -> void:
	update_velocity(delta_)
	move_and_slide()
	update_animation()
	
func update_velocity(delta_: float) -> void:
	#Player movement
	var moveDirection = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = moveDirection * speed
	
	if velocity.length() == 0: return
	
	var target_position = global_position + velocity * delta_ - level.position
	var target_tile_coords = level.ground_tilemap.local_to_map(target_position)
	
	#Check if the target tile is walkable
	var tile_id = level.ground_tilemap.get_cell_tile_data(target_tile_coords)
	var walkable_flag = false
	
	if tile_id != null:
		walkable_flag = tile_id.get_custom_data("walkable")
	
	tile_id = level.rock_tilemap.get_cell_tile_data(target_tile_coords)
	
	if tile_id != null:
		walkable_flag = tile_id.get_custom_data("walkable")
	
	#Stop movement if unwalkable
	if !walkable_flag:
		velocity = Vector2.ZERO
