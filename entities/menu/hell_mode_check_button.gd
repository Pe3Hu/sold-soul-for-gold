extends CheckButton


@export var tooltip: Tooltip


func _ready() -> void:
	mouse_entered.connect(on_mouse_entered)
	mouse_exited.connect(on_mouse_exit)
	
func on_mouse_entered() -> void:
	tooltip.toggle(true)
	
func on_mouse_exit() -> void:
	tooltip.toggle(false)
