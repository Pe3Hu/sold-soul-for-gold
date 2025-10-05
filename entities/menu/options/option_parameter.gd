class_name OptionParameter
extends HBoxContainer


@export var menu: Menu
@export_enum("coin counter", "enemy counter",  "enemy speed", "player speed") var type: String:
	set(value_):
		type = value_
		%TextureRect.texture = load("res://assets/images/ui/icon/" + type + ".png")
@export var current_slider_value: int:
	set(value_):
		current_slider_value = value_
		%HSlider.value = current_slider_value
@export var min_slider_value: int:
	set(value_):
		min_slider_value = value_
		%HSlider.min_value = min_slider_value
@export var max_slider_value: int:
	set(value_):
		max_slider_value = value_
		%HSlider.max_value = max_slider_value


func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exit)
	
func inital_reset() -> void:
	%HSlider.value += 1
	%HSlider.value -= 1
	
	match type:
		"coin counter":
			%Tooltip.text = "Number of coins needed to Win"
		"enemy counter":
			%Tooltip.text = "Number of enemies on the Map"
		"enemy speed":
			%Tooltip.text = "Enemy movement speed"
		"player speed":
			%Tooltip.text = "Player movement speed"
	
func _on_h_slider_value_changed(value_: float) -> void:
	%Value.text = str(int(value_))
	
	match type:
		"coin counter":
			menu.coin_counter.max_value = value_
			
			if menu.world.is_enemy_guarding_coin:
				menu.coin_counter.max_value += menu.enemy_counter_parameter.current_slider_value
			menu.world.rand_coin_counter = value_
		"enemy counter":
			menu.world.total_enemy_counter = value_
		"enemy speed":
			menu.world.enemy_speed = value_
		"player speed":
			menu.world.player_speed = value_

func _on_mouse_entered() -> void:
	%Tooltip.toggle(true)
	
func _on_mouse_exit() -> void:
	%Tooltip.toggle(false)
