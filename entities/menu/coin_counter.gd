class_name CoinCounter
extends MarginContainer


const SHINE_TIME = 1.0


@export var menu: Menu
@export var current_value: int = 0:
	set(value_):
		current_value = value_
		update_label()
@export var max_value: int = 0:
	set(value_):
		max_value = value_
		update_label()


func update_label() -> void:
	%CoinLabel.text = str(current_value) + "/" + str(max_value)
	
	if menu.world.is_map_generated and current_value == max_value:
		menu.coins_collected.emit()
		%AudioWin.play()
