extends Node2D

@onready var door_panel = $DoorPanel
@onready var video_player = $VideoPlayer
@onready var courtyard_bg = $CourtyardBackground
@onready var dialogue_box = $CanvasLayer/Control

var dialogue_step = 0

func _ready():
	# 初始状态
	door_panel.show()
	video_player.hide()
	courtyard_bg.hide()
	dialogue_box.show()
	
	# 设置第一段对话
	update_ui_text("主角", "外面像堡垒，里面……这么热闹？")
	
	# 连接“继续”按钮信号 (假设你已经按照之前的方法连接了 pressed 信号)
	# 如果没有，记得在编辑器里连上这个函数
	
func _on_next_button_pressed():
	if dialogue_step == 0:
		# 第一段对话结束
		update_ui_text("小貂", "这里最多住过三百多人。全是亲戚。")
		dialogue_step += 1
	elif dialogue_step == 1:
		# 点击后，隐藏对话框，播放视频
		dialogue_box.hide()
		play_video_sequence()
		dialogue_step += 1

func play_video_sequence():
	door_panel.hide()
	video_player.show()
	video_player.play()
	# 等待视频播放结束
	await video_player.finished
	
	# 视频结束后显示第二段
	on_video_finished()

func on_video_finished():
	video_player.hide()
	courtyard_bg.show() # 显示天井背景
	dialogue_box.show()
	update_ui_text("主角", "三百人住一个圆圈里？")
	
	# 下一步点击将触发最后一段对话
	dialogue_step += 1
	# 注意：这里的逻辑要衔接到你的 final_dialogue()
	
# --- UI更新函数 ---
# 把它放在脚本的最下面，这样脚本就能“认出”这个函数了
func update_ui_text(speaker_name, content):
	# 根据你场景树的结构，寻找节点
	var name_label = dialogue_box.get_node("DialoguePanel/NameLabel")
	var text_label = dialogue_box.get_node("DialoguePanel/DialogueText")
	var mink_sprite = dialogue_box.get_node("Mink")
	var protagonist_sprite = dialogue_box.get_node("Protagonist")
	
	# 更新文字
	if name_label: name_label.text = speaker_name
	if text_label: text_label.text = content
	
	# 控制立绘显示
	if mink_sprite and protagonist_sprite:
		if speaker_name == "主角":
			protagonist_sprite.show()
			mink_sprite.hide()
		elif speaker_name == "小貂":
			protagonist_sprite.hide()
			mink_sprite.show()
	
