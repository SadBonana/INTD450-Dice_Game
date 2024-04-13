extends AudioStreamPlayer

func _on_music_finished():
	$BattleMusic.play()
