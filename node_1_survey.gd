extends Control

# 👇 导出参数，Inspector直接修改，和你之前的逻辑完全兼容
@export var node_id: int = 1          
@export var unlock_condition: int = 0 
@export var node_name: String = "勘测选址"
@export var node_desc: String = "土楼建造第一步，勘测风水、选址定基"
@export var target_scene: String = "res://scenes/scene_1.tscn"

# 节点状态
var is_unlocked: bool = false
var is_completed: bool = false

func _ready() -> void:
	# 绑定Control专属的点击事件，绝对不会被拦截
	gui_input.connect(_on_gui_input)
	# 检查解锁状态
	check_unlock_state()
	print("✅ 节点", node_id, "初始化完成，解锁状态：", is_unlocked)

# 检查解锁状态（和你之前的逻辑完全一致）
func check_unlock_state() -> void:
	var completed = Global.instance.save_data.get("completed_nodes", [])
	is_unlocked = (unlock_condition == 0) || (unlock_condition in completed)
	is_completed = node_id in completed
	print("📊 节点", node_id, "状态：unlocked=", is_unlocked, "completed=", is_completed)

# 🔥 Control专属点击事件，100%触发，零拦截
func _on_gui_input(event: InputEvent) -> void:
	print("🖱️ 节点", node_id, "被点击了！事件：", event)
	# 只响应鼠标左键按下
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		print("✅ 节点", node_id, "左键点击生效！")
		# 未解锁，提示
		if not is_unlocked:
			Global.instance.show_toast("请先完成前置建造流程，再解锁此节点")
			return
		
		# 已解锁：显示弹窗
		Global.instance.show_node_panel(node_name, node_desc, target_scene)
		
		# 标记为已完成
		if not is_completed:
			var completed = Global.instance.save_data.get("completed_nodes", [])
			completed.append(node_id)
			Global.instance.save_data["completed_nodes"] = completed
			is_completed = true
			print("✅ 节点", node_id, "标记为已完成")
			
			# 解锁下一个节点
			var next_node = get_parent().get_node_or_null("Node" + str(node_id + 1))
			if next_node:
				next_node.check_unlock_state()
				print("🔓 解锁下一个节点：Node", node_id + 1)

# 空函数，避免样式报错
func update_node_style() -> void:
	pass
