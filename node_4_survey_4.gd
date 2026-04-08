extends Area2D

# 👇 必须加@export，才能在Inspector里看到可配置参数
@export var node_id: int = 1          
@export var unlock_condition: int = 0 
@export var node_name: String = "勘测选址"
@export var node_desc: String = "土楼建造第一步，勘测风水、选址定基"
@export var target_scene: String = "res://scenes/scene_1.tscn"

@onready var node_sprite: Sprite2D = $NodeSprite  # 你没做图标，这个可以留着，不影响
@onready var node_label: Label = $NodeLabel
@onready var glow_effect: Sprite2D = $GlowEffect

var is_unlocked: bool = false
var is_completed: bool = false

func _ready() -> void:
	# 连接点击信号
	input_event.connect(_on_input_event)
	# 检查解锁状态
	check_unlock_state()
	# 更新节点样式
	update_node_style()

# 检查节点是否解锁
func check_unlock_state() -> void:
	var completed_nodes = Global.save_data.get("completed_nodes", [])
	if unlock_condition == 0 or unlock_condition in completed_nodes:
		is_unlocked = true
	if node_id in completed_nodes:
		is_completed = true

# 更新节点样式（解锁/锁定/完成）
func update_node_style() -> void:
	# 你没做图标，这里可以留空，不影响功能
	pass

# 节点点击事件
func _on_input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if not is_unlocked:
			Global.show_toast("请先完成前置建造流程，再解锁此节点")
			return
		# 调用全局单例显示面板，用单例获取，不用绝对路径！
		Global.show_node_panel(node_name, node_desc, target_scene)
		# 标记为已完成
		if not is_completed:
			Global.save_data["completed_nodes"] = Global.save_data.get("completed_nodes", []) + [node_id]
			is_completed = true
			update_node_style()
			# 解锁下一个节点
			var next_node = get_parent().get_node_or_null("Node" + str(node_id+1))
			if next_node:
				next_node.check_unlock_state()
				next_node.update_node_style()
