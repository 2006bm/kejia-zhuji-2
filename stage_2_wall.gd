extends Control

@onready var background = $Background
@onready var wall = $Wall
@onready var xiaodiao = $XiaoDiao

@onready var hammer_up = $HammerUp
@onready var hammer_down = $HammerDown
@onready var dust_effect = $DustEffect

@onready var material_popup = $MaterialPopup
@onready var popup_title = $MaterialPopup/Title
@onready var popup_content = $MaterialPopup/Content
@onready var close_button = $MaterialPopup/CloseButton

@onready var hit1: TextureButton = $HitPointLayer/Hit1
@onready var hit2: TextureButton = $HitPointLayer/Hit2
@onready var hit3: TextureButton = $HitPointLayer/Hit3

@onready var name_label = $UI/DialogueBox/NameLabel
@onready var dialogue_label = $UI/DialogueBox/DialogueLabel
@onready var next_button = $UI/DialogueBox/NextButton

@onready var progress_label = $UI/ProgressLabel
@onready var finish_button = $UI/FinishButton

@onready var charge_bar: ProgressBar = $UI/ChargeBar
@onready var charge_label: Label = $UI/ChargeLabel

@onready var sfx_player = $SfxPlayer

@export var wall_start_tex: Texture2D
@export var wall_mid_tex: Texture2D
@export var wall_finish_tex: Texture2D

@export var hammer_cursor_tex: Texture2D
@export var hammer_cursor_hotspot: Vector2 = Vector2(24, 24)

@export var map_scene_path: String = "res://scenes/juanzhou_map.tscn"

var intro_lines = [
	{"name":"小貂","text":"你以为土楼的墙只有土？"},
	{"name":"主角","text":"啊？不是吗？"},
	{"name":"小貂","text":"还有砂石，糯米浆，这些都是必不可少的材料啊。","show_popup":true},
	{"name":"主角","text":"糯米？我没听错吧，那是用来干嘛的？"},
	{"name":"小貂","text":"相当于是一种有机粘合剂，能够将土黏结更紧密，大大提高墙的强度和韧性。——这么说了你可能也不太能领会，赶紧亲自试试吧！"}
]

var intro_index := 0
var mode := "intro" # intro / popup / gameplay / finished
var current_layer := 1
var current_hit_index := 0
var total_hits_in_layer := 3

var charging := false
var charge_value := 0.0
var charge_direction := 1.0
var can_click_hit := false
var active_hit: TextureButton = null
var is_hitting := false

var wall_base_pos: Vector2
var bg_base_pos: Vector2
var xiaodiao_base_pos: Vector2
var hammer_up_base_pos: Vector2
var hammer_down_base_pos: Vector2
var dust_base_pos: Vector2

func _ready():
	if wall_start_tex:
		wall.texture = wall_start_tex

	wall_base_pos = wall.position
	bg_base_pos = background.position
	xiaodiao_base_pos = xiaodiao.position
	hammer_up_base_pos = hammer_up.position
	hammer_down_base_pos = hammer_down.position
	dust_base_pos = dust_effect.position

	popup_title.text = "夯土墙结构"
	popup_content.text = "夯土墙由土、砂石、糯米浆等材料夯筑而成。"

	material_popup.hide()
	hammer_down.hide()
	dust_effect.hide()
	finish_button.hide()
	charge_bar.hide()
	charge_label.hide()

	_hide_all_hits()
	progress_label.text = "第 1 层：0 / 3"

	next_button.pressed.connect(_on_next_button_pressed)
	close_button.pressed.connect(_on_close_popup_pressed)
	finish_button.pressed.connect(_on_finish_button_pressed)

	hit1.pressed.connect(func(): _on_hit_point_pressed(hit1))
	hit2.pressed.connect(func(): _on_hit_point_pressed(hit2))
	hit3.pressed.connect(func(): _on_hit_point_pressed(hit3))

	_show_intro_line()


func _process(delta):
	if charging and mode == "gameplay":
		charge_value += charge_direction * delta * 180.0

		if charge_value >= 100.0:
			charge_value = 100.0
			charge_direction = -1.0
		elif charge_value <= 0.0:
			charge_value = 0.0
			charge_direction = 1.0

		charge_bar.value = charge_value


func _input(event):
	if mode != "gameplay":
		return

	if active_hit == null:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and charging:
			return

		if event.pressed and not charging:
			# 必须已经先点中了当前夯击点
			return

		if not event.pressed and charging:
			_finish_charge_and_hit()


func _show_intro_line():
	var line = intro_lines[intro_index]
	name_label.text = line["name"]
	dialogue_label.text = line["text"]

	if line.has("show_popup") and line["show_popup"]:
		mode = "popup"
		material_popup.show()
		hammer_up.hide()
		hammer_down.hide()
		dust_effect.hide()
	else:
		mode = "intro"


func _on_next_button_pressed():
	if mode == "intro":
		if intro_index == intro_lines.size() - 1:
			_start_gameplay()
		else:
			intro_index += 1
			_show_intro_line()

	elif mode == "finished":
		next_button.hide()
		finish_button.show()


func _on_close_popup_pressed():
	material_popup.hide()
	if intro_index == intro_lines.size() - 1:
		_start_gameplay()
	else:
		intro_index += 1
		_show_intro_line()


func _start_gameplay():
	mode = "gameplay"
	name_label.text = "系统"
	dialogue_label.text = "点击墙上的夯击点，按住蓄力，松手夯下。"

	charge_bar.show()
	charge_label.show()
	hammer_up.show()
	hammer_down.hide()
	dust_effect.hide()

	_enable_hammer_cursor()
	_show_current_hit()


func _on_hit_point_pressed(hit: TextureButton):
	if mode != "gameplay":
		return
	if is_hitting:
		return
	if not can_click_hit:
		return
	if hit != active_hit:
		return

	charging = true
	charge_value = 0.0
	charge_direction = 1.0
	charge_bar.value = 0.0
	charge_label.text = "按住蓄力，松手夯下"

	can_click_hit = false


func _finish_charge_and_hit():
	charging = false
	var result := _judge_charge(charge_value)
	await _play_hit_animation(result)
	_mark_hit_finished(result)


func _judge_charge(value: float) -> String:
	if value >= 45.0 and value <= 65.0:
		return "perfect"
	elif value >= 25.0 and value <= 85.0:
		return "good"
	else:
		return "weak"


func _mark_hit_finished(result: String):
	if active_hit:
		active_hit.hide()

	current_hit_index += 1
	progress_label.text = "第 %d 层：%d / 3" % [current_layer, current_hit_index, total_hits_in_layer]

	match result:
		"perfect":
			dialogue_label.text = "这一锤夯得很实。"
		"good":
			dialogue_label.text = "不错，再稳一点。"
		"weak":
			dialogue_label.text = "这一锤有点轻，再来一次。"

	if current_hit_index >= total_hits_in_layer:
		_finish_current_layer()
	else:
		_show_current_hit()


func _finish_current_layer():
	current_hit_index = 0

	if current_layer == 1:
		if wall_mid_tex:
			wall.texture = wall_mid_tex
		name_label.text = "小貂"
		dialogue_label.text = "你看，下面厚，上面薄。这叫收分。"
		current_layer = 2
		progress_label.text = "第 2 层：0 / 3"
		await get_tree().create_timer(1.2).timeout
		_show_current_hit()

	elif current_layer == 2:
		name_label.text = "小貂"
		dialogue_label.text = "继续夯实，上层会更收一点。"
		current_layer = 3
		progress_label.text = "第 3 层：0 / 3"
		await get_tree().create_timer(1.0).timeout
		_show_current_hit()

	else:
		if wall_finish_tex:
			wall.texture = wall_finish_tex
		mode = "finished"
		_hide_all_hits()
		_disable_hammer_cursor()
		name_label.text = "小貂"
		dialogue_label.text = "土墙会呼吸。它白天吸热，晚上放热。这样屋里冬暖夏凉。怎么样，材料的好处大着呢，汇聚着客家几代人的智慧。"
		next_button.show()


func _show_current_hit():
	mode = "gameplay"
	_hide_all_hits()

	var hits := [hit1, hit2, hit3]
	active_hit = hits[current_hit_index]
	active_hit.show()
	can_click_hit = true
	charge_label.text = "点击当前夯击点后，按住蓄力"


func _hide_all_hits():
	hit1.hide()
	hit2.hide()
	hit3.hide()
	active_hit = null
	can_click_hit = false


func _play_hit_animation(result: String) -> void:
	is_hitting = true

	hammer_up.hide()
	hammer_down.show()
	dust_effect.show()

	var push_y := 6.0
	var shake_x := 4.0

	if result == "perfect":
		push_y = 10.0
		shake_x = 8.0
	elif result == "good":
		push_y = 7.0
		shake_x = 5.0
	else:
		push_y = 4.0
		shake_x = 2.0

	wall.position = wall_base_pos + Vector2(0, push_y)
	hammer_down.position = hammer_down_base_pos + Vector2(0, push_y + 2)
	dust_effect.position = dust_base_pos + Vector2(0, 4)

	if sfx_player.stream:
		sfx_player.play()

	var tween := get_tree().create_tween()
	tween.tween_property(background, "position", bg_base_pos + Vector2(shake_x, 0), 0.03)
	tween.tween_property(background, "position", bg_base_pos + Vector2(-shake_x, 0), 0.03)
	tween.tween_property(background, "position", bg_base_pos, 0.04)

	await get_tree().create_timer(0.12).timeout

	wall.position = wall_base_pos
	hammer_down.position = hammer_down_base_pos
	dust_effect.position = dust_base_pos
	background.position = bg_base_pos

	dust_effect.hide()
	hammer_down.hide()
	hammer_up.show()

	is_hitting = false


func _enable_hammer_cursor():
	if hammer_cursor_tex:
		Input.set_custom_mouse_cursor(hammer_cursor_tex, Input.CURSOR_ARROW, hammer_cursor_hotspot)


func _disable_hammer_cursor():
	Input.set_custom_mouse_cursor(null, Input.CURSOR_ARROW)


func _on_finish_button_pressed():
	GlobalState.unlocked_stage = max(GlobalState.unlocked_stage, 4)
	_disable_hammer_cursor()
	get_tree().change_scene_to_file(map_scene_path)
