extends Node2D

var _next_button = 1
var _next_shape = 0
var _last_colider_id = 0
var _player_se_fudeu = false
var _player_spawn_positions_x = [110,195,280,365,440]
var _player_points = 0
var _chat_se_fudeu = false
var _chat_spawn_positions_x = [820,905,990,1075,1150]
var _chat_points = 0
var _chat_votes = {}
var _user_names = {}

func _ready():
	_randomize_next_shape()
	_mark_button()
	
func _process(delta):
	$ProgressBar.min_value = 0
	$ProgressBar.value = $GameTimer.wait_time-$GameTimer.time_left	
	
func _set_wait_time(wait_time):
	$TimerSlider.editable = true
	$GameTimer.stop()
	$GameTimer.wait_time = wait_time
	$GameTimer.start()
	$ProgressBar.max_value = wait_time
	$TimerLabel.text = "TIMER " + str(wait_time) + "s"
	
func _add_player_points(points):
	_player_points = _player_points+points
	$EuPontos.text = "Eu: " + str(_player_points) + " pontos (+" + str(points) + ")" 

func _add_chat_points(points):
	_chat_points = _chat_points+points
	$VocesPontos.text = "Vocês: " + str(_chat_points) + " pontos (+" + str(points) + ")" 
	
func _get_chat_vote():
	var votes = _chat_votes.values()
	votes = votes.reduce(_reduce_vote,[0,0,0,0,0])
	var max_vote = max(votes[0],votes[1],votes[2],votes[3],votes[4])
	var i = 0
	var votes_list = []
	for v in votes:
		i=i+1
		if v == max_vote:
			votes_list.append(i)
	
	var selected_vote = randi_range(0,votes_list.size()-1)
	return votes_list[selected_vote]

func _timer_action():
	if(!_player_se_fudeu):
		var cena_instanciada = preload("res://scenes/emote.tscn").instantiate()
		cena_instanciada.position = Vector2(_player_spawn_positions_x[(_next_button-1)]+randf_range(0,3), 275)
		cena_instanciada.type = _next_shape
		cena_instanciada.ownerName = "PLAYER"
		cena_instanciada.connect("on_clear", _on_emote_clear)
		_add_player_points(pow(cena_instanciada.type+1,2))
		$AllEmotes.add_child(cena_instanciada)
		
	if(!_chat_se_fudeu):
		var cena_instanciada = preload("res://scenes/emote.tscn").instantiate()
		cena_instanciada.position = Vector2(_chat_spawn_positions_x[(_get_chat_vote()-1)]+randf_range(0,3), 275)
		cena_instanciada.type = _next_shape
		cena_instanciada.ownerName = "CHAT"
		cena_instanciada.connect("on_clear", _on_emote_clear)
		_add_chat_points(pow(cena_instanciada.type+1,2))
		$AllEmotes.add_child(cena_instanciada)
		_chat_votes = {}
		_update_votes()
		$CommandsLabel.text = ""
	
	if(_player_se_fudeu && _chat_se_fudeu):
		_game_ended()
	
func _on_emote_clear(emote1: Node2D, emote2: Node2D):
	if(emote1.get_instance_id() != _last_colider_id && emote2.get_instance_id() != _last_colider_id):
		$JoinAudio.play()
		_last_colider_id = emote1.get_instance_id()
		var cena_instanciada = preload("res://scenes/emote.tscn").instantiate()
		var rb1: RigidBody2D = emote1.find_child("RigidBody2D")
		var rb2: RigidBody2D = emote2.find_child("RigidBody2D")
		cena_instanciada.position = (rb1.global_position+rb2.global_position)/2
		cena_instanciada.type = min(9, emote1.type+1)
		cena_instanciada.ownerName = emote1.ownerName
		cena_instanciada.connect("on_clear", _on_emote_clear)
		emote1.queue_free()
		emote2.queue_free()
		if(cena_instanciada.ownerName == "PLAYER"):
			_add_player_points(pow(cena_instanciada.type+1,2))
		if(cena_instanciada.ownerName == "CHAT"):
			_add_chat_points(pow(cena_instanciada.type+1,2))
		$AllEmotes.add_child(cena_instanciada)	
	
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
	var size = (_next_shape+3) * 0.17
	$NextEmote.scale = Vector2(size,size)

func _on_h_slider_value_changed(value):
	_set_wait_time($TimerSlider.value)

func _on_player_end_game_area_body_entered(body: RigidBody2D):
	_player_se_fudeu = true
	if(!$WastedAudio.playing):
		$WastedAudio.play()
	$PlayerWastedImage.z_index = 999
	$PlayerWastedImage.visible = true
	
func _on_chat_end_game_area_body_entered(body):
	_chat_se_fudeu = true
	if(!$WastedAudio.playing):
		$WastedAudio.play()
	$ChatWastedImage.z_index = 999
	$ChatWastedImage.visible = true

func _on_music_volume_slider_value_changed(value):
	$BackgroundMusic.volume_db = value

func _on_button_toggled(toggled_on):
	if(toggled_on):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
		
func _change_user_name(authorId: String, newName: String):
	print("new name for "+ authorId + " is "+ newName)
	if(newName):
		var name = newName.to_upper()
		var allowed_chars = "ABCÇDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-ÁÉÍÓÚÃÕÂÔ"
		var filtered_string = ""
	
		for char in name:
			print(char)
			if char in allowed_chars:
				filtered_string += char
	
		name = filtered_string.substr(0,16)
	
		_user_names[authorId] = name
		print(_user_names)

func _get_user_name(authorId: String):
	if(_user_names.get(authorId)):
		return _user_names.get(authorId)
	else:
		return authorId.to_upper().substr(0,16).replace(" ","")

func _reduce_vote(acc,vote):
	acc[vote-1] = acc[vote-1] + 1
	return acc
		
func _update_votes():
	var votes = _chat_votes.values()
	votes = votes.reduce(_reduce_vote,[0,0,0,0,0])
	$ChatActionButtons/Button1.text = "!1\n"+str(votes[0])+" votos"
	$ChatActionButtons/Button2.text = "!2\n"+str(votes[1])+" votos"
	$ChatActionButtons/Button3.text = "!3\n"+str(votes[2])+" votos"
	$ChatActionButtons/Button4.text = "!4\n"+str(votes[3])+" votos"
	$ChatActionButtons/Button5.text = "!5\n"+str(votes[4])+" votos"

func _on_yt_live_chat_yt_live_message_read(text: String, authorId: String, timestamp):
	print(text)
	var vote = 0
	if(text.begins_with("!1")):
		vote = 1
	if(text.begins_with("!2")):
		vote = 2
	if(text.begins_with("!3")):
		vote = 3
	if(text.begins_with("!4")):
		vote = 4
	if(text.begins_with("!5")):
		vote = 5
	if(text.begins_with("!name")):
		_change_user_name(authorId, text.get_slice(" ",1))	
	
	if(vote>0 && vote<=5):
		$CommandsLabel.text = _get_user_name(authorId) + " votou " + str(vote)
		_chat_votes[authorId] = vote
		_update_votes()

func _on_button_pressed():
	$HBoxContainer/StartGameButton.disabled = true
	$HBoxContainer/VBoxContainer/ApiKeyEdit.editable = false
	$HBoxContainer/VBoxContainer/LiveIdEdit.editable = false
	$PlayerWastedImage.visible = false
	$ChatWastedImage.visible = false
	_player_se_fudeu = false
	_chat_se_fudeu = false
	_player_points = 0
	_chat_points = 0
	_add_chat_points(0)
	_add_player_points(0)
	for node in $AllEmotes.get_children():
		node.queue_free()
	$YTLiveChat.start_get_message_loop(
		$HBoxContainer/VBoxContainer/ApiKeyEdit.text,
		$HBoxContainer/VBoxContainer/LiveIdEdit.text)
	_set_wait_time($GameTimer.wait_time)
	
func _game_ended():
	$HBoxContainer/StartGameButton.disabled = false
	$HBoxContainer/VBoxContainer/ApiKeyEdit.editable = true
	$HBoxContainer/VBoxContainer/LiveIdEdit.editable = true
	$TimerSlider.editable = false
	$GameTimer.stop()
