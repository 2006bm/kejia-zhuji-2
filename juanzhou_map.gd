extends Control

@onready var node1 = $NodePoints/Node1
@onready var node2 = $NodePoints/Node2
@onready var node3 = $NodePoints/Node3
@onready var node4 = $NodePoints/Node4
@onready var node5 = $NodePoints/Node5

func _ready():
	print("当前解锁进度：", GlobalState.unlocked_stage)

	node1.pressed.connect(_on_node1_pressed)
	node2.pressed.connect(_on_node2_pressed)
	node3.pressed.connect(_on_node3_pressed)
	node4.pressed.connect(_on_node4_pressed)
	node5.pressed.connect(_on_node5_pressed)

	update_node_state()

func _on_node1_pressed():
	if GlobalState.unlocked_stage < 1:
		return
	get_tree().change_scene_to_file("res://scenes/stage1_site.tscn")

func _on_node2_pressed():
	if GlobalState.unlocked_stage < 2:
		return
	print("Node2 已解锁，但 stage2_material.tscn 还没接上")

func _on_node3_pressed():
	if GlobalState.unlocked_stage < 3:
		return
	print("Node3 已解锁，但 stage3_wall.tscn 还没接上")

func _on_node4_pressed():
	if GlobalState.unlocked_stage < 4:
		return
	print("Node4 已解锁，但 stage4_joinery.tscn 还没接上")

func _on_node5_pressed():
	if GlobalState.unlocked_stage < 5:
		return
	print("Node5 已解锁，但 stage5_finish.tscn 还没接上")

func update_node_state():
	_set_enabled(node1, GlobalState.unlocked_stage >= 1)
	_set_enabled(node2, GlobalState.unlocked_stage >= 2)
	_set_enabled(node3, GlobalState.unlocked_stage >= 3)
	_set_enabled(node4, GlobalState.unlocked_stage >= 4)
	_set_enabled(node5, GlobalState.unlocked_stage >= 5)

func _set_enabled(button: Button, enabled: bool):
	button.disabled = !enabled
