 
extends Node

# 全局存档数据：记录已完成的节点
var save_data: Dictionary = {
	"completed_nodes": [],
	"current_node": 0
}



func _ready():
	# 初始化单例
	pass

# 显示节点详情弹窗
func show_node_panel(title: String, content: String, scene_path: String) -> void:
	# 从场景树根节点获取卷轴场景
	var scroll_root = get_tree().root.get_node_or_null("ScrollRoot")
	if not scroll_root:
		print("❌ 错误：找不到ScrollRoot节点")
		return
	
	var ui_panel = scroll_root.get_node_or_null("UIPanel")
	if not ui_panel:
		print("❌ 错误：找不到UIPanel节点")
		return
	
	# 设置弹窗内容
	ui_panel.get_node("TitleLabel").text = title
	ui_panel.get_node("ContentLabel").text = content
	
	# 绑定进入场景按钮
	var enter_btn = ui_panel.get_node("EnterSceneBtn")
	enter_btn.pressed.disconnect_all()
	enter_btn.pressed.connect(func():
		get_tree().change_scene_to_file(scene_path)
		ui_panel.visible = false
	)
	
	ui_panel.visible = true

# 显示提示Toast
func show_toast(text: String) -> void:
	print("💡 提示：", text)
