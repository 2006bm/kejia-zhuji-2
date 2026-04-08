extends Control

const FERRET_IDLE = preload("res://image/ip形象/小雕1.png")
const FERRET_POINT = preload("res://image/小貂指向.png")
const SCROLL_SCENE = "res://juanzhou_map.tscn"

@onready var joint_explain = $JointExplain
@onready var joint_click = $JointClick
@onready var joint_lock = $JointLock
@onready var wood_frame = $WoodFrame
@onready var wood_glow = $WoodGlow
@onready var ferret = $Ferret
@onready var next_button = $NextButton
@onready var name_label = $DialoguePanel/NameLabel
@onready var dialogue_text = $DialoguePanel/DialogueText
@onready var click_sfx = $ClickSfx
@onready var anim = $AnimationPlayer

var step := 0

func _ready() -> void:
	if not next_button.pressed.is_connected(_on_next_button_pressed):
		next_button.pressed.connect(_on_next_button_pressed)

	ferret.texture = FERRET_IDLE

	joint_explain.hide()
	joint_click.hide()
	joint_lock.hide()
	wood_frame.hide()

	wood_glow.show()
	wood_glow.modulate = Color(1.0, 0.93, 0.75, 0.0)

	name_label.text = "小貂"
	dialogue_text.text = "看这里。这个凸出来的叫“榫”，这个凹进去的叫“卯”。"

func _on_next_button_pressed() -> void:
	step += 1

	match step:
		1:
			show_explain_step()
		2:
			show_click_step()
		3:
			show_lock_step()
		4:
			show_frame_step()
		5:
			show_finish_step()
		6:
			go_to_scroll_scene()

func show_explain_step() -> void:
	ferret.texture = FERRET_POINT

	joint_explain.show()
	joint_click.hide()
	joint_lock.hide()
	wood_frame.hide()
	wood_glow.modulate.a = 0.0

	name_label.text = "小貂"
	dialogue_text.text = "你看，这个凸出来的叫“榫”，这个凹进去的叫“卯”。"

func show_click_step() -> void:
	ferret.texture = FERRET_POINT

	joint_explain.hide()
	joint_click.show()
	joint_lock.hide()
	wood_frame.hide()
	wood_glow.modulate.a = 0.0

	if click_sfx.stream:
		click_sfx.play()

	name_label.text = "小貂"
	dialogue_text.text = "只要结构对上，插进去就会“咔哒”一声咬合。"

func show_lock_step() -> void:
	ferret.texture = FERRET_IDLE

	joint_explain.hide()
	joint_click.hide()
	joint_lock.show()
	wood_frame.hide()
	wood_glow.modulate.a = 0.0

	name_label.text = "主角"
	dialogue_text.text = "不用钉子就可以？这样真的牢固吗？"

func show_frame_step() -> void:
	ferret.texture = FERRET_IDLE

	joint_explain.hide()
	joint_click.hide()
	joint_lock.hide()
	wood_frame.show()

	name_label.text = "小貂"
	dialogue_text.text = "完全不需要。墙只是壳，而木架才是骨头。"

	play_warm_glow()

func show_finish_step() -> void:
	ferret.texture = FERRET_IDLE

	name_label.text = "小貂"
	dialogue_text.text = "想要继续学客家建筑的精髓，就快去找阿木伯师傅吧。"

func play_warm_glow() -> void:
	wood_glow.show()
	wood_glow.modulate = Color(1.0, 0.93, 0.75, 0.0)

	var tw := create_tween()
	tw.tween_property(wood_glow, "modulate:a", 0.65, 0.8)
	tw.tween_interval(0.3)
	tw.tween_property(wood_glow, "modulate:a", 0.35, 0.6)

func go_to_scroll_scene() -> void:
	get_tree().change_scene_to_file(SCROLL_SCENE)
