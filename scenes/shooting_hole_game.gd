extends Node2D

var bandit_scene = preload("res://scenes//Bandit.tscn")

@onready var anim = $AnimationPlayer
@onready var spawn_timer = $SpawnTimer
@onready var game_timer = $GameTimer
@onready var crosshair = $Crosshair
@onready var wall_far = $ExteriorWall
@onready var hole_close = $HoleCloseup
@onready var inside_view = $InsideView
@onready var dialogue_box = $CanvasLayer/Control
@onready var next_button = $CanvasLayer/Control/DialoguePanel/NextButton
var is_game_active = false
var dialogue_step = 0

func _ready():
	# 【修改点 1】: 游戏一开始，强制显示系统鼠标，隐藏我们的准星
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	crosshair.hide()
	#next_button.pressed.connect(_on_next_button_pressed)
	# 初始化背景和对话
	wall_far.show()
	hole_close.hide()
	inside_view.hide()
	dialogue_box.show()
	play_dialogue_step()

func _process(delta):
	# 只有当准星可见时，才让它跟随鼠标
	if crosshair.visible:
		crosshair.global_position = get_global_mouse_position()

# --- 对话与游戏流程 ---

func play_dialogue_step():
	if dialogue_step == 0:
		wall_far.show()
		hole_close.hide()
		inside_view.hide()
		hole_close.modulate.a = 0 # 确保它是透明的
		update_ui_text("主角", "这些密密麻麻的小孔是干嘛的？")
		
	elif dialogue_step == 1:
		wall_far.hide()
		inside_view.hide()
		hole_close.show()
		hole_close.modulate.a = 1.0 # 强制恢复不透明
		update_ui_text("小貂", "射击孔。刚才学过夯土吧？\n这墙底厚顶薄，不光稳，还能防土匪。")
		
	elif dialogue_step == 2:
		dialogue_box.hide()
		inside_view.show()
		start_game_transition()

# --- 修改 start_game_transition 函数 ---
func start_game_transition():
	anim.play("zoom_in") 
	# 等待动画播放完毕
	await anim.animation_finished
	
	# 【核心修改】：动画播完后，不直接 start_minigame，而是显示对话
	show_dialogue_after_animation()

# --- 新增：显示竹林视角的对话 ---
func show_dialogue_after_animation():
	dialogue_box.show()
	# 把 dialogue_step 设置为 2，这是我们需要的新对话阶段
	dialogue_step = 2 
	update_ui_text("主角", "视野好广，外面看得一清二楚。")

# --- 修改你的 _on_next_button_pressed 函数 ---
func _on_next_button_pressed():
	print("继续按钮被点击，当前阶段:", dialogue_step)
	
	if dialogue_step == 0:
		dialogue_step += 1
		play_dialogue_step()
	elif dialogue_step == 1:
		dialogue_step += 1
		play_dialogue_step()
	elif dialogue_step == 2:
		# 主角说完话，现在轮到小貂说话
		dialogue_step += 1
		update_ui_text("小貂", "这是整座楼的眼睛。试试？守住这里。")
		dialogue_box.hide()
		start_minigame() # 这里才真正开始刷怪
	elif dialogue_step == 3:
		# 此时已经是胜利总结的话了，再次点击就是跳转场景
		print("准备跳转到场景六！")
		
		# 替换为你下一个场景的正确路径
		get_tree().change_scene_to_file("res://scenes/tulou_interior.tscn")

func start_minigame():
	# 【新增这一行！】确保竹林背景是显示的
	inside_view.show()
	# 动画结束时，InsideView.modulate.a 应该已经是 1.0 了，这里再 show() 一次是双重保险

	# 【修改点 2】: 小游戏正式开始，才隐藏系统鼠标，显示准星
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	crosshair.show()

	is_game_active = true
	spawn_timer.start()
	game_timer.start()
	print("小游戏开始！")


func _on_spawn_timer_timeout():
	if not is_game_active: return
	var new_bandit = bandit_scene.instantiate()
	var random_x = randf_range(150, 600) 
	var random_y = randf_range(60, 350)
	new_bandit.position = Vector2(random_x, random_y)
	add_child(new_bandit)

func _on_game_timer_timeout():
	is_game_active = false
	spawn_timer.stop() 
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	crosshair.hide()
	
	print("游戏结束，进入胜利对话！")
	
	# 设置状态为 3，代表胜利对话阶段
	dialogue_step = 3 
	
	# 显示对话框和胜利的话
	dialogue_box.show()
	update_ui_text("小貂", "守住了。当年这里的人，每天就这么守着全家人的命。")

# --- UI更新函数 ---
func update_ui_text(speaker_name, content):
	dialogue_box.get_node("DialoguePanel/NameLabel").text = speaker_name
	dialogue_box.get_node("DialoguePanel/DialogueText").text = content
	var mink_sprite = dialogue_box.get_node("Mink")
	var protagonist_sprite = dialogue_box.get_node("Protagonist")
	
	if speaker_name == "主角":
		protagonist_sprite.show()
		mink_sprite.hide()
	elif speaker_name == "小貂":
		protagonist_sprite.hide()
		mink_sprite.show()
