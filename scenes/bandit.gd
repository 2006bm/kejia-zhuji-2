extends Area2D

func _ready():
	# 1. 把所有土匪节点放到一个数组里
	var bandit_nodes = [$Bandit_1, $Bandit_2, $Bandit_3, $Bandit_4, $Bandit_5]
	
	# 2. 默认先把所有土匪都隐藏起来
	for node in bandit_nodes:
		node.hide()
		
	# 3. 随机选一个显示出来
	var random_index = randi() % bandit_nodes.size()
	bandit_nodes[random_index].show()

var is_dead = false
func _on_input_event(viewport, event, shape_idx):
	if is_dead: return 
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		is_dead = true
		var tween = create_tween()
		tween.tween_property(self, "modulate:a", 0.0, 0.2)
		await tween.finished
		queue_free()
