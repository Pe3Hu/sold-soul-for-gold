class_name camera
extends Camera2D


@export var player: Player


func _ready() -> void:
	zoom += Vector2.ONE * 0.7
