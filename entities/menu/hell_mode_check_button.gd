extends CheckButton


@export var tooltip: Tooltip


func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exit)
	
func _on_mouse_entered() -> void:
	tooltip.toggle(true)
	
func _on_mouse_exit() -> void:
	tooltip.toggle(false)
