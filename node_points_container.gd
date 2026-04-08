extends Control

func _ready():
	# 只加这一行！让鼠标穿透 UI，不挡点击！
	mouse_filter = MOUSE_FILTER_IGNORE
