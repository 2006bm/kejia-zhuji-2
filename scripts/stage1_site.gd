extends Control

@onready var main_character = $CharacterLayer/MainCharacter
@onready var xiao_diao = $CharacterLayer/XiaoDiao

@onready var dialogue_panel = $UI/DialoguePanel
@onready var name_label = $UI/DialoguePanel/NameLabel
@onready var content_label = $UI/DialoguePanel/ContentLabel
@onready var next_button = $UI/DialoguePanel/NextButton

@onready var choice_panel = $UI/ChoicePanel
@onready var choice1 = $UI/ChoicePanel/Choice1
@onready var choice2 = $UI/ChoicePanel/Choice2
@onready var choice3 = $UI/ChoicePanel/Choice3

@onready var back_button = $UI/BackButton

var base_xiao_diao_pos: Vector2

# 当前阶段：
# "intro"      开场对白
# "wrong"      选错后的提示
# "success"    选对后的连续剧情
# "finished"   准备返回卷轴
var phase: String = "intro"

var intro_index: int = 0
var wrong_choice_id: int = 0
var success_index: int = 0

var intro_dialogues = [
	{"name": "主角", "text": "这里就是要建楼的地方吗？"},
	{"name": "小貂", "text": "对，建楼第一件事就是选地方。"},
	{"name": "小貂", "text": "你自己看看，好好选哦。"}
]

var success_dialogues = [
	{"name": "小貂", "text": "这里背山面水，地势也高，看起来你很有天赋呢。"},
	{"name": "阿木伯", "text": "地基是楼的命，要先垫石，再一层一层夯。"},
	{"name": "小貂", "text": "地基很稳固。有句话听过吗？所谓“基础不牢，地动山摇”。你已经成功了第一步！"},
	{"name": "小貂", "text": "走走走，我们继续！"}
]

func _ready():
	base_xiao_diao_pos = xiao_diao.position

	dialogue_panel.show()
	choice_panel.hide()

	next_button.text = "下一句"
	choice1.text = "低洼地"
	choice2.text = "山顶"
	choice3.text = "山坡"
	back_button.text = "返回卷轴"

	if not next_button.pressed.is_connected(_on_next_button_pressed):
		next_button.pressed.connect(_on_next_button_pressed)
	if not choice1.pressed.is_connected(_on_choice1_pressed):
		choice1.pressed.connect(_on_choice1_pressed)
	if not choice2.pressed.is_connected(_on_choice2_pressed):
		choice2.pressed.connect(_on_choice2_pressed)
	if not choice3.pressed.is_connected(_on_choice3_pressed):
		choice3.pressed.connect(_on_choice3_pressed)
	if not back_button.pressed.is_connected(_on_back_button_pressed):
		back_button.pressed.connect(_on_back_button_pressed)

	_show_intro_dialogue()

func _process(_delta):
	var t = Time.get_ticks_msec() / 1000.0
	xiao_diao.position = base_xiao_diao_pos + Vector2(0, sin(t * 2.5) * 6.0)

func _show_intro_dialogue():
	if intro_index < intro_dialogues.size():
		var d = intro_dialogues[intro_index]
		name_label.text = d["name"]
		content_label.text = d["text"]
		dialogue_panel.show()
		choice_panel.hide()
		next_button.text = "下一句"
	else:
		_show_choices()

func _show_choices():
	phase = "choice"
	dialogue_panel.hide()
	choice_panel.show()

func _show_wrong_dialogue(choice_id: int):
	phase = "wrong"
	wrong_choice_id = choice_id
	dialogue_panel.show()
	choice_panel.hide()

	name_label.text = "小貂"
	if choice_id == 1:
		content_label.text = "这里雨一来就积水，真不是个好选择。"
	else:
		content_label.text = "风太大，住着难受，不是明智之举啊。"

	next_button.text = "再选一次"

func _show_success_dialogue():
	phase = "success"

	if success_index < success_dialogues.size():
		var d = success_dialogues[success_index]
		dialogue_panel.show()
		choice_panel.hide()
		name_label.text = d["name"]
		content_label.text = d["text"]
		next_button.text = "下一句"
	else:
		phase = "finished"
		GlobalState.unlocked_stage = max(GlobalState.unlocked_stage, 2)
		_return_to_map()

func _on_next_button_pressed():
	match phase:
		"intro":
			intro_index += 1
			_show_intro_dialogue()

		"wrong":
			_show_choices()

		"success":
			success_index += 1
			_show_success_dialogue()

		"finished":
			_return_to_map()

func _on_choice1_pressed():
	_show_wrong_dialogue(1)

func _on_choice2_pressed():
	_show_wrong_dialogue(2)

func _on_choice3_pressed():
	success_index = 0
	_show_success_dialogue()

func _on_back_button_pressed():
	_return_to_map()

func _return_to_map():
	get_tree().change_scene_to_file("res://juanzhou_map.tscn")
