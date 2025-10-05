class_name Menu
extends Control

signal coins_collected
signal mission_failed


@onready var coin_counter: CoinCounter = %CoinCounter
@onready var coin_counter_parameter: OptionParameter = %CoinCounterParameter
@onready var enemy_counter_parameter: OptionParameter = %EnemyCounterParameter

@export var world: World

enum State {MAIN,PAUSE,RESTART} 
@export var  current_state: State = State.MAIN:
	set(value_):
		current_state = value_
		
		match current_state:
			State.MAIN:
				%Message.text = "Menu"
			State.PAUSE:
				%Message.text = "Pause"
			State.RESTART:
				if world.is_win:
					%Message.text = "You Win"
				else:
					%Message.text = "You Lose"
		reset_buttons()


func _ready() -> void:
	SaveManager._load()
	update_buttons()
	reset_inital_sliders()
	world.is_pause = true
	
func reset_inital_sliders() -> void:
	for slider in %SlidersVBox.get_children():
		slider.inital_reset()
	
func update_buttons() -> void:
	reset_buttons()
	var visible_buttons = {}
	visible_buttons[State.MAIN] = ["Start"]
	visible_buttons[State.PAUSE] = ["Resume", "Restart",]
	visible_buttons[State.RESTART] = ["Restart"]
	
	for type in visible_buttons[current_state]:
		var path = "%" + type + "Button"#"$Buttons/" + 
		var button = get_node(path)
		button.visible = true
	
	%MainVBoxContainer.set_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_MINSIZE) 
	%ButtonsPanel.size = %MainVBoxContainer.size * 1.25
	%ButtonsPanel.size.y -= %Message.size.y * 0.5
	%ButtonsPanel.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_KEEP_SIZE)
	
func reset_buttons() -> void:
	for button in %ButtonsVBox.get_children():
		button.visible = false
	
	%OptionsButton.visible = true
	%QuitButton.visible = true
	%SaveButton.visible = world.is_map_generated
	%LoadButton.visible = !SaveManager.save_file_data.coin_positions.is_empty()
	
func continue_gameplay() -> void:
	world.phantom_camera.teleport_position()
	world.is_pause = false
	current_state = State.PAUSE
	%ButtonsPanel.visible = false
	#%BackgroundPanel.visible = false
	%CoinCounter.visible = true
	
func start_gameplay() -> void:
	%CongratulationTextureRect.visible = false
	world.reset()
	continue_gameplay()
	
func set_on_pause() -> void:
	world.is_pause = true
	%ButtonsPanel.visible = true
	%CoinCounter.visible = false
	#%BackgroundPanel.visible = true
	update_buttons()
	
func set_on_restart() -> void:
	current_state = State.RESTART
	world.is_pause = true
	world.is_map_generated = false
	%ButtonsPanel.visible = true
	%CoinCounter.visible = false
	#%BackgroundPanel.visible = true
	update_buttons()
	
func _on_exit_options_button_pressed() -> void:
	%OptionsPanel.visible = false
	%ButtonsPanel.visible = true
	
func _on_hell_mode_check_button_pressed() -> void:
	world.is_enemy_guarding_coin = !world.is_enemy_guarding_coin
	
func _on_options_button_pressed() -> void:
	%ButtonsPanel.visible = false
	%OptionsPanel.visible = true
	
func _on_start_button_pressed() -> void:
	start_gameplay()
	
func _on_restart_button_pressed() -> void:
	world.is_loading = false
	coin_counter.current_value = 0
	start_gameplay()
	
func _on_resume_button_pressed() -> void:
	continue_gameplay()
	
func _on_save_button_pressed() -> void:
	world.save_game()
	update_buttons()
	
func _on_load_button_pressed() -> void:
	world.is_loading = true
	SaveManager._load()
	start_gameplay()
	
func _on_quit_button_pressed() -> void:
	get_tree().quit()
	
func _on_coins_collected() -> void:
	world.is_win = true
	%CongratulationTextureRect.visible = true
	%CongratulationTextureRect.material.set_shader_parameter("NOISE_magnitude", Color.from_hsv(60, 60, 100))
	%CongratulationTextureRect.material.set_shader_parameter("NOISE_magnitude", 0)
	set_on_restart()
	
func _on_mission_failed() -> void:
	set_on_restart()
	%CongratulationTextureRect.visible = true
	%CongratulationTextureRect.material.set_shader_parameter("NOISE_magnitude", Color.WHITE)
	%CongratulationTextureRect.material.set_shader_parameter("NOISE_magnitude", 0.7)
