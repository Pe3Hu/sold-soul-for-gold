class_name Coin
extends Area2D


@onready var animations: AnimationPlayer = $AnimationPlayer


func _physics_process(_delta: float) -> void:
	update_animation()
	
func update_animation() -> void:
	animations.play("flip")
