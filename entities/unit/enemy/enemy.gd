class_name Enemy
extends Unit


@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

@export_enum("gold", "silver") var type:
	set(value_):
		type = value_
		
		$BodySprite.texture = load("res://assets/images/sprites/knight " + type + ".png")
		init_milestones()
@export var overshoot_limit: int = 5
@export var patrol_distance: int = 5
@export var waltz_distance: int = 3

var target_player: Player
var target_milestones: Array[Vector2]

var spawn_position: Vector2:
	set(value_):
		spawn_position = value_
		position = Vector2(spawn_position)
var return_position

enum State{IDLE, FOLLOW, BACK, PATROL, WALTZ}
var current_state: State = State.IDLE:
	set(value_):
		current_state = value_
		
		if current_state == State.IDLE:
			$IdleTimer.start()


#Initial addition of Enemy activity points
func init_milestones() -> void:
	match type:
		"silver":
			var rnd_angle = randf_range(0, PI * 2)
			var patrol_position = Vector2.from_angle(rnd_angle) * patrol_distance * sprite_size.length()
			target_milestones.append(spawn_position + patrol_position)
			target_milestones.append(spawn_position - patrol_position)
			current_state = State.PATROL
		"gold":
			set_next_waltz_position()
	
func _physics_process(_delta: float) -> void:
	update_velocity() 
	move_and_slide()
	
	#Animate movement
	if current_state != State.IDLE:
		update_animation()
	else:
		if animations.is_playing():
			animations.stop()
	
func update_velocity() -> void:
	var current_agent_position = global_position
	
	match current_state:
		#stop movement in case IDLE state
		State.IDLE:
			velocity = Vector2.ZERO
			return
		#Player stalking
		State.FOLLOW:
			var dist_to_return = global_position.distance_to(return_position)
			
			#Return after crossing a exclusion zone
			if dist_to_return > level.enemy_follow_distance:
				target_player = null
				current_state = State.BACK
				return
			
			#Choosing player position for movement
			nav_agent.target_position = target_player.global_position
		State.BACK:
			if return_position == null: return
			
			#Choosing last position for movement
			nav_agent.target_position = return_position
			
			#Short respite when reaching a milestone
			if return_position.distance_to(current_agent_position) < overshoot_limit:
				return_position =  current_agent_position
				current_state = State.IDLE
				
				if type == "silver":
					swap_target_milestones()
				return
		State.PATROL:
			#Choosing next milestone for movement
			nav_agent.target_position = target_milestones.front()
		State.WALTZ:
			#Choosing next milestone for movement
			nav_agent.target_position = target_milestones.front()
	
	var next_path_position = nav_agent.get_next_path_position()
	var new_velocity = current_agent_position.direction_to(next_path_position) * speed
	
	#Status change at the end of movement
	if nav_agent.is_navigation_finished():
		return_position = null
		current_state = State.IDLE
		return
	
	#Applying velocity
	if nav_agent.avoidance_enabled:
		nav_agent.set_velocity(new_velocity)
	else:
		_on_navigation_agent_2d_velocity_computed(new_velocity)
	
#Selecting a random position within a given radius relative to the spawn position
func set_next_waltz_position() -> void:
	target_milestones.clear()
	var direction_to_start = spawn_position - global_position
	
	#Choose a random direction as the first one
	if direction_to_start == Vector2.ZERO:
		direction_to_start = Vector2.from_angle(randf_range(0, 2 * PI))
	
	#Generating next milestone for movement
	var new_angle = -direction_to_start.angle() + randf_range(-0.25, 0.25) * PI
	var next_milestone_offset = randf_range(0.75, 1) * waltz_distance * sprite_size.length()
	
	#Adding next milestone for movement
	var next_milestone = spawn_position + Vector2.from_angle(new_angle) * next_milestone_offset
	target_milestones.append(next_milestone)
	
	#Status change at the end of movement
	current_state = State.WALTZ
	
func set_next_patrol_position() -> void:
	swap_target_milestones()
	
	#Status change at the end of movement
	current_state = State.PATROL
	
#Change in milestone queue
func swap_target_milestones() -> void:
	var next_milestone = target_milestones.pop_front()
	target_milestones.append(next_milestone)
	
func _on_navigation_agent_2d_velocity_computed(safe_velocity_: Vector2) -> void:
	velocity = safe_velocity_
	
#Start chasing the player
func _on_follow_area_body_entered(body: Node2D) -> void:
	if body is Player:
		target_player = body
		return_position = Vector2(global_position)
		current_state = State.FOLLOW
	
#End chasing the player
func _on_follow_area_body_exited(body: Node2D) -> void:
	if body is Player:
		target_player = null
		current_state = State.BACK
	
#Start of next movement
func _on_idle_timer_timeout() -> void:
	match type:
		"gold":
			set_next_waltz_position()
		"silver":
			set_next_patrol_position()
