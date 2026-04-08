extends CollisionShape2D

func _ready():
	# 直接创建圆形碰撞体，半径35（可自行调整大小）
	var circle = CircleShape2D.new()
	circle.radius = 35
	# 给当前CollisionShape2D赋值形状
	shape = circle
	print("✅ 碰撞形状已自动设置，半径35")
