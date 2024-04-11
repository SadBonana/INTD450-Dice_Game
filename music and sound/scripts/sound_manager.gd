extends Node2D

#Music
@onready var battle_music = $music/BattleMusic
@onready var boss_music = $music/BossMusic
@onready var boss_intro = $music/BossIntro

#SFX
@onready var attack_sfx = $SFX/attack
@onready var defend_sfx = $SFX/defend
@onready var poison_sfx = $SFX/poison_effect
@onready var fire_sfx = $SFX/fire_effect
@onready var alt_select_sfx = $SFX/alt_select
@onready var select_sfx = $SFX/select
@onready var autodefense_sfx = $SFX/autodefense
@onready var defend_2 = $SFX/defend2
@onready var select_3 = $SFX/select3
@onready var autodefense_2 = $SFX/autodefense2
@onready var heal = $SFX/heal
@onready var error = $SFX/error
@onready var select_2 = $SFX/select2

@onready var lightning_apply = $SFX/lightning_apply
@onready var fire_apply = $SFX/fire_apply
@onready var poison_apply = $SFX/poison_apply


func fade_out(sound1,sound2):
	for i in range(10):
		sound1.volume_db -= 2
		await get_tree().create_timer(0.5).timeout #delaying so the player can see the effects apply
	sound2.play()
	sound1.stop()


func _on_battle_music_finished():
	battle_music.play()

func _on_boss_music_finished():
	boss_music.play()

func _on_boss_intro_finished():
	boss_music.play()
