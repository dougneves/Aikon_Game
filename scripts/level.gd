extends Node2D

var _next_button = 1
var _next_shape = 0
var _last_colider_id = 0
var _player_se_fudeu = false

func _ready():
	_randomize_next_shape()
	_set_wait_time(5)
	_mark_button()
	
func _process(delta):
	$ProgressBar.min_value = 0
	$ProgressBar.value = $GameTimer.wait_time-$GameTimer.time_left	
	
func _set_wait_time(wait_time):
	$GameTimer.stop()
	$GameTimer.wait_time = wait_time
	$GameTimer.start()
	$ProgressBar.max_value = wait_time	

func _timer_action():
	if(!_player_se_fudeu):
		var cena_instanciada = preload("res://scenes/emote.tscn").instantiate()
		cena_instanciada.position = Vector2(randf_range(94,96)+((_next_button-1)*110), 100)
		cena_instanciada.type = _next_shape
		cena_instanciada.connect("on_clear", _on_emote_clear)
		add_child(cena_instanciada)
	
func _on_emote_clear(emote1: Node2D, emote2: Node2D):
	if(emote1.get_instance_id() != _last_colider_id && emote2.get_instance_id() != _last_colider_id):
		$JoinAudio.play()
		_last_colider_id = emote1.get_instance_id()
		var cena_instanciada = preload("res://scenes/emote.tscn").instantiate()
		var rb1: RigidBody2D = emote1.find_child("RigidBody2D")
		var rb2: RigidBody2D = emote2.find_child("RigidBody2D")
		cena_instanciada.position = (rb1.global_position+rb2.global_position)/2
		cena_instanciada.type = min(9, emote1.type+1)
		cena_instanciada.connect("on_clear", _on_emote_clear)
		emote1.queue_free()
		emote2.queue_free()
		add_child(cena_instanciada)	
	
func _on_button_1_pressed():
	_next_button = 1
	_mark_button()

func _on_button_2_pressed():
	_next_button = 2
	_mark_button()

func _on_button_3_pressed():
	_next_button = 3
	_mark_button()

func _on_button_4_pressed():
	_next_button = 4
	_mark_button()

func _on_button_5_pressed():
	_next_button = 5
	_mark_button()
	
func _mark_button():
	$PlayerActionButtons/Button1.text = "1"
	$PlayerActionButtons/Button2.text = "2"
	$PlayerActionButtons/Button3.text = "3"
	$PlayerActionButtons/Button4.text = "4"
	$PlayerActionButtons/Button5.text = "5"
	
	get_node("PlayerActionButtons/Button"+str(_next_button)).text = "[ "+str(_next_button)+" ]"

func _on_game_timer_timeout():
	_timer_action()
	_randomize_next_shape()

func _randomize_next_shape():
	var chances = randi_range(0,20)
	if (chances < 6):
		_next_shape = 0
	else: if(chances < 11):
		_next_shape = 1
	else: if(chances < 15):
		_next_shape = 2
	else: if(chances < 18):
		_next_shape = 3
	else: if(chances < 20):
		_next_shape = 4
	else:
		_next_shape = 5
	$NextEmote.play(str(_next_shape))
	var size = (_next_shape+3) * 0.1
	$NextEmote.scale = Vector2(size,size)

func _on_h_slider_value_changed(value):
	_set_wait_time($HSlider.value)

func _on_player_end_game_area_body_entered(body: RigidBody2D):
	_player_se_fudeu = true
	if(!$WastedAudio.playing):
		$WastedAudio.play()
	$PlayerWastedImage.z_index = 999
	$PlayerWastedImage.visible = true
