extends Control

@onready var name_label = $DialoguePanel/NameLabel
@onready var dialogue_text = $DialoguePanel/DialogueText

var dialogues = [
	{"speaker": "小貂", "text": "醒了？"},
	{"speaker": "主角", "text": "……这里是哪里？"},
	{"speaker": "小貂", "text": "你不是这里的人吧。"},
	{"speaker": "小貂", "text": "来都来了，要不要试试——自己建一座土楼？"}
]

var dialogue_index = 0

func _ready() -> void:
	show_dialogue()

func show_dialogue() -> void:
	name_label.text = dialogues[dialogue_index]["speaker"]
	dialogue_text.text = dialogues[dialogue_index]["text"]

func _on_next_button_pressed() -> void:
	dialogue_index += 1

	if dialogue_index < dialogues.size():
		show_dialogue()
	else:
		get_tree().change_scene_to_file("res://juanzhou_map.tscn")
		print("准备跳转卷轴页")
