extends Control

@onready var video_player = $VideoPlayer

func _ready() -> void:
	video_player.play()

func _on_video_player_finished() -> void:
	print("视频播放结束，准备进入竹林场景")
	get_tree().change_scene_to_file("res://scenes/bamboo_scene.tscn")
