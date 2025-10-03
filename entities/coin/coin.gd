class_name Coin
extends Area2D


@onready var animations: AnimationPlayer = $AnimationPlayer

var world: World


func _physics_process(_delta: float) -> void:
	update_animation()
	
func update_animation() -> void:
	if !world.is_pause: 
		animations.play("flip")
	else:
		if animations.is_playing():
			animations.stop()
	
func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		collect()
	
func collect() -> void:
	world.menu.coin_counter.current_value += 1
	visible = false
	%AudioCollect.play()
	await %AudioCollect.finished
	queue_free()
	
