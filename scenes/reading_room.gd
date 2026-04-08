extends Control

@onready var anim = $AnimationPlayer
@onready var video = $BackgroundVideo
@onready var skip_btn = $UI/SkipButton

var current_step = 0

func _ready() -> void:
	# 初始状态：只看视频，隐藏其他UI
	$UI/DialogueBox.hide()
	$BookLayers.modulate.a = 0.0
	skip_btn.show()

	# 连接视频播放结束信号
	video.finished.connect(_on_video_finished)

func _on_skip_button_pressed() -> void:
	if current_step == 0:
		video.stop()
		_on_video_finished()

func _on_video_finished() -> void:
	skip_btn.hide()
	current_step = 1
	$UI/DialogueBox.show()
	$BookLayers.modulate.a = 1.0
	advance_story()

func _input(event) -> void:
	# 只有视频播完以后，点击鼠标左键才进入下一步
	if current_step > 0 and event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		advance_story()

func advance_story() -> void:
	if anim.is_playing():
		# 如果动画还在播，点击可加速跳过当前动画
		anim.speed_scale = 5.0
		return
	else:
		anim.speed_scale = 1.0

	match current_step:
		1:
			anim.play("show_page_1")
		2:
			anim.play("show_page_2")
		3:
			anim.play("show_page_3")
		4:
			anim.play("final_transition")

	current_step += 1

# 这个函数由 AnimationPlayer 的方法调用轨道在最后调用
func change_scene() -> void:
	get_tree().change_scene_to_file("res://scenes/transition_video.tscn")
