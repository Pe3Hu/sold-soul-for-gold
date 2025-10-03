class_name Unit
extends CharacterBody2D


@export var level: Level
@export var sprite_size: Vector2i = Vector2i(16, 16)

@onready var animations: AnimationPlayer = $AnimationPlayer

var is_jumping: bool = false


func update_animation() -> void:
	if level.world.is_pause: 
		if animations.is_playing():
			animations.stop()
		
		return
	
	if is_jumping:
		animations.play("jump")
	else:
		if velocity.length() == 0:
			#Disabling animation in case of inactivity
			if animations.is_playing():
				animations.stop()
		else:
			#Determining the direction of movement
			var angle = velocity.angle()
			
			if angle < 0:
				angle += PI * 2
			
			var direction = "Right"
			
			if angle >= PI/4 and angle < PI*3/4: direction = "Down"
			elif angle >= PI*3/4 and angle < PI*5/4: direction = "Left"
			elif angle >= PI*5/4 and angle < PI*7/4: direction = "Up"
			animations.play("walk" + direction)
