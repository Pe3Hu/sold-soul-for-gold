class_name Tooltip
extends NinePatchRect


const OFFSET: Vector2 = Vector2.ONE * 10

@export var text: String:
	set(value_): 
		text = value_
		
		%Content.text = text

var opacity_tween: Tween = null


func _input(event: InputEvent) -> void:
	if visible and event is InputEventMouseMotion:
		global_position = get_global_mouse_position() + OFFSET
	
func toggle(on_: bool) -> void:
	if on_:
		show()
		modulate.a = 0.0
		tween_opacity(1.0)
	else:
		modulate.a = 1.0
		await tween_opacity(0.0).finished
		hide()
	
	
func tween_opacity(to_: float):
	if opacity_tween: opacity_tween.kill()
	
	opacity_tween = get_tree().create_tween() 
	opacity_tween.tween_property(self, 'modulate:a', to_, 0.3)
	return opacity_tween
	
