extends Node2D


# block 标识了接收事件的方块本身的引用，shape_idx 标识了方块的哪个面接收到了事件
signal add_block(block, shape_idx)
signal delete_block(block)
signal mouse_entered(block, shape_idx)
signal mouse_exited(block, shape_idx)

onready var up = $up/CollisionPolygon2D
onready var left = $left/CollisionPolygon2D2
onready var right = $right/CollisionPolygon2D3

var destroy_enable := false # 初始方块默认无法摧毁
var vpos := Vector3.ZERO
var dict := {}

var _shape_idx:int = -1
var virtual := false setget set_virtual


func set_virtual(is_true: bool):
	virtual = is_true
	$Sprite.modulate.a = 0.5
	
func _ready():
	dict = {0: up, 1: left, 2: right}


func _on_Area2D_input_event(viewport, event: InputEvent, shape_idx):
	if (event is InputEventMouseButton && event.pressed):
		# 只处理第一个接收到事件的节点
		if CordManager.current_input_event_id == event.get_instance_id():
			return
		CordManager.current_input_event_id = event.get_instance_id()
		match event.button_index:
			1:
				print(event)
				print(event.get_instance_id())
				self.emit_signal("add_block", self, shape_idx)
				get_tree().set_input_as_handled()
			2:
				if destroy_enable:
					self.emit_signal("delete_block", self)
					get_tree().set_input_as_handled()


func change_sprite_texture(index: int):
	$Sprite.set_frame(index)


func disable_shape(_shape_idx: int, _disabled: bool):
	var x = dict[_shape_idx]
	dict[_shape_idx].set_disabled(_disabled)
	# for x in $Area2D.get_children():
	#	 print(x.disabled)
	


func _on_up_input_event(viewport, event, shape_idx):
	_on_Area2D_input_event(viewport, event, 0)


func _on_left_input_event(viewport, event, shape_idx):
	_on_Area2D_input_event(viewport, event, 1)


func _on_right_input_event(viewport, event, shape_idx):
	_on_Area2D_input_event(viewport, event, 2)


func _on_up_mouse_entered():
	self.emit_signal("mouse_entered", self, 0)


func _on_up_mouse_exited():
	self.emit_signal("mouse_exited", self, 0)


func _on_left_mouse_entered():
	self.emit_signal("mouse_entered", self, 1)


func _on_left_mouse_exited():
	self.emit_signal("mouse_exited", self, 1)


func _on_right_mouse_entered():
	self.emit_signal("mouse_entered", self, 2)


func _on_right_mouse_exited():
	self.emit_signal("mouse_exited", self, 2)
