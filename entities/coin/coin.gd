class_name Coin
extends Area2D


@onready var animations: AnimationPlayer = $AnimationPlayer
@onready var on_screen: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

var world: World

var is_already_showed: bool = false


func _physics_process(_delta: float) -> void:
	update_animation()
	
func update_animation() -> void:
	if !world.is_pause: 
		animations.play("flip")
	else:
		if animations.is_playing():
			animations.stop()
	
func collect() -> void:
	world.menu.coin_counter.current_value += 1
	visible = false
	%AudioCollect.play()
	await %AudioCollect.finished
	queue_free()
	
func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		collect()
	
func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	if !is_already_showed:
		is_already_showed = true
		$ShineSprite.visible = true
		await get_tree().create_timer(2.0).timeout
		$ShineSprite.visible = false
