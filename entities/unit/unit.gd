class_name Unit
extends CharacterBody2D


@export var level: Level
@export var sprite_size: Vector2i = Vector2i(16, 16)
@export var speed: float = 160

@onready var sprite: Sprite2D = $Sprite2D
@onready var animations: AnimationPlayer = $AnimationPlayer


func update_animation() -> void:
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
