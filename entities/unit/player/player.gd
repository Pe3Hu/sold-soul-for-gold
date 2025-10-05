class_name Player
extends Unit


@export var jump_time: float = 0.4
@export var extinction_delay_time: float = 0.2
@export var extinction_invulnerability_delay: float = 0.4

var previous_direction: Vector2
var current_jump_cell:
	set(value_):
		current_jump_cell = value_
		
		level.jump_cell.visible = current_jump_cell != null

var is_extinction: bool = false


func _physics_process(delta_: float) -> void:
	if level.world.is_pause: 
		update_animation()
		return
	
	update_velocity(delta_)
	move_and_slide()
	update_animation()
	
	#await %AudioGrass1.finished
	#await %AudioGrass1.finished
	#await %AudioGrass2.finished
	#var rnd_grass_index = randi_range(1, 2)
	#var audio = get("%AudioGrass" + str(rnd_grass_index))
	#audio.play()
	
func update_velocity(delta_: float) -> void:
	if is_jumping: return
	
	#Player movement
	var move_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = move_direction * level.world.player_speed
	
	if velocity.length() == 0: return
	
	if previous_direction != move_direction:
		current_jump_cell = null
	
	previous_direction != move_direction
	
	var target_position = global_position + velocity * delta_ - level.position
	var target_tile_coords = level.grass_tilemap.local_to_map(target_position)
	
	#Check if the target tile is walkable
	var tile_id = level.grass_tilemap.get_cell_tile_data(target_tile_coords)
	var walkable_flag = false
	
	if tile_id != null:
		walkable_flag = tile_id.get_custom_data("walkable")
	
	tile_id = level.rock_tilemap.get_cell_tile_data(target_tile_coords)
	
	if tile_id != null:
		walkable_flag = tile_id.get_custom_data("walkable")
	
	#Stop movement if unwalkable
	if !walkable_flag:
		velocity = Vector2.ZERO
		set_current_jump_cell(target_tile_coords, move_direction)
	
func set_current_jump_cell(start_coord_: Vector2i, move_direction_: Vector2) -> void:
	for _i in level.jump_cell_distance:
		var next_coord = start_coord_ + Vector2i(move_direction_) * _i
		var tile_id = level.grass_tilemap.get_cell_tile_data(next_coord)
		var jumpable_flag = false
		
		if tile_id != null:
			jumpable_flag = tile_id.get_custom_data("walkable")
		
		if jumpable_flag:
			tile_id = level.rock_tilemap.get_cell_tile_data(next_coord)
			
			if tile_id != null:
				jumpable_flag = tile_id.get_custom_data("walkable")
		
		if jumpable_flag:
			if current_jump_cell != next_coord:
				current_jump_cell = next_coord
				
				var local_position = level.grass_tilemap.map_to_local(current_jump_cell)
				level.jump_cell.position = level.grass_tilemap.to_global(local_position) - level.position - level.jump_cell.size * 0.5
			return
	
func start_jump() -> void:
	if current_jump_cell != null and !is_jumping:
		velocity = Vector2.ZERO
		current_jump_cell = null
		is_jumping = true
		var jump_vector = level.jump_cell.position + level.TILE_SIZE * 0.5
		var tween = get_tree().create_tween()
		tween.tween_property(self, "position", jump_vector, jump_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		%AudioJump.play()
		
		#Pre-landing animation
		await get_tree().create_timer(jump_time - extinction_delay_time).timeout 
		$SmokeSprite.visible = true
		$SmokeAnimationPlayer.play("extinction")
		await $SmokeAnimationPlayer.animation_finished
		$SmokeSprite.visible = false
		is_extinction = true
		await get_tree().create_timer(extinction_invulnerability_delay).timeout 
		is_extinction = false
	
func end_jump() -> void:
	is_jumping = false
	animations.play("RESET")
	
func play_footstep() -> void:
	FootstepSoundManager.play_footstep(global_position)
	
func _input(event) -> void:
	if event is InputEventKey:
		if event.is_action("jump"):
			start_jump()
