extends Node2D


onready var container := $Container
var BLOCK_SCENE := preload("res://block.tscn")
var block_texture_index := 3 setget set_block_texture_index # 选择的 block 的纹理样式，由 tileset 提供

# Called when the node enters the scene tree for the first time.
func _ready():
	var _block = $Container/Layer0/block
	_connect_signal(_block)
	CordManager.add_block(_block, Vector3.ZERO)
	

func set_block_texture_index(idx: int):
	block_texture_index = idx
	pass
	
# 连接信号
func _connect_signal(_block):
	_block.connect("add_block", self, "_add_block")
	_block.connect("delete_block", self, "_delete_block")
	_block.connect("mouse_entered", self, "_mouse_entered")
	_block.connect("mouse_exited", self, "_mouse_exited")


# block 是点击的方块，shape_idx 是点击的面
# 0-up 1-left 2-right
func _add_block(block: Node2D, shape_idx: int) -> Node2D:
	print('click block id: %s' % block)
	print('shape_idx: %s' % shape_idx)

	# add a block instance to tree
	var instance = _gen_block_instance(block, shape_idx)
	# disable the Area2D
	_disable_other(instance.vpos, true)
	_disable_self(instance, true)
	
	return instance


# 生成方块实例
func _gen_block_instance(block: Node2D, shape_idx: int) -> Node2D:
	var pos := block.position      # 在这个viewport中的真实坐标
	# 规定左手系
	var vpos = CordManager.block_vpos(block, shape_idx)
	return _instance_block(pos, block_texture_index, vpos)


func _disable(vpos: Vector3, disabled, shape_idx):
	if CordManager.dict.has(vpos):
		CordManager.dict[vpos].disable_shape(shape_idx, disabled)


func _disable_other(vpos: Vector3, disabled: bool):
	var _block_left = vpos + Vector3(-1, 0, 0)
	var _block_right = vpos + Vector3(0, -1, 0)
	var _block_below = vpos + Vector3(0, 0, -1)
	
	var lz = [_block_left, _block_right, _block_below]
	var lz_idx = [2, 1, 0]
	
	for i in range(0, lz.size()):
		if CordManager.dict.has(lz[i]):
			print(CordManager.dict[lz[i]])
			_disable(lz[i], disabled, lz_idx[i])
			# CordManager.dict[lz[i]].disable_shape(lz_idx[i], disabled)
			

func _disable_self(block: Node2D, disabled: bool):
	var vpos = block.vpos
	var _block_right = vpos + Vector3(1, 0, 0)
	var _block_left = vpos + Vector3(0, 1, 0)
	var _block_up = vpos + Vector3(0, 0, 1)
	
	var lz = [_block_left, _block_right, _block_up]
	var lz_idx = [1, 2, 0]
	
	var cnt = 0
	
	for i in range(0, lz.size()):
		if CordManager.dict.has(lz[i]):
			cnt += 1
			_disable(vpos, disabled, lz_idx[i])
			
	if cnt > 0: print("_disable_self %s" % cnt)


func _instance_block(pos: Vector2, _block_texture_index, vpos: Vector3):
	var instance := BLOCK_SCENE.instance()
	
	# init props
	pos = CordManager.vpos2pos(vpos)
	instance.position = pos
	instance.vpos = vpos
	instance.destroy_enable = true
	instance.change_sprite_texture(_block_texture_index)
	
	CordManager.add_block(instance, vpos)
	
	# signal connect
	_connect_signal(instance)
	
	# find suitable parent and add
	var layer_index = container.get_child_count() - 1
	while vpos.z > layer_index:
		var ysort := YSort.new()
		container.add_child(ysort)
		ysort.position = container.get_child(layer_index).position + Vector2(0, 0)
		layer_index += 1
	
	# container.add_child(instance)
	var parent = container.get_child(vpos.z)
	parent.add_child(instance)
	
	return instance


func _delete_block(block: Node2D):
	block.queue_free()
	# 有效化信号接收区域
	_disable_other(block.vpos, false)
	CordManager.delete_block(block, block.vpos)


var velocity := Vector2.ZERO
var speed := 200

func _input(event):
	if event.is_action_pressed("change_up"):
		block_texture_index -= 1
		if block_texture_index < 0: block_texture_index = 0
		$sample.change_sprite_texture(block_texture_index)		
	if event.is_action_pressed("change_down"):
		block_texture_index += 1
		if block_texture_index >= 618: block_texture_index = 0
		$sample.change_sprite_texture(block_texture_index)
	if event is InputEventKey:
		if event.is_action_pressed("up"):
			velocity += Vector2(0, -1)
		if event.is_action_pressed("down"):
			velocity += Vector2(0, 1)
		if event.is_action_pressed("left"):
			velocity += Vector2(-1, 0)
		if event.is_action_pressed("right"):
			velocity += Vector2(1, 0)
			
		if event.is_action_released("up"):
			velocity += Vector2(0, 1)
		if event.is_action_released("down"):
			velocity += Vector2(0, -1)
		if event.is_action_released("left"):
			velocity += Vector2(1, 0)
		if event.is_action_released("right"):
			velocity += Vector2(-1, 0)


func _process(delta):
	$Camera2D.offset += velocity.normalized() * delta * speed


# 鼠标离开的位置
func _mouse_exited(block: Node2D, shape_idx):
	print('exit %s %s' % [block.vpos, shape_idx])	
	# var vpos: Vector3 =  CordManager.block_vpos(block, shape_idx)
	# if CordManager.dict.has(vpos):
	# 	var instance = CordManager.dict[vpos]
	#	# 如果是虚拟方块那么就删除并且移除出场景树和数据结构
	#	# 不是的话就删除，移除出场景树，数据结构中不用删除
	#	if instance.virtual:
	#		_delete_block(instance)
	#	else:
	#		for x in CordManager.virtual_block.values():
	#			x.queue_free()
	#		CordManager.virtual_block.clear()
	for x in CordManager.virtual_block.values():
		if CordManager.dict[x.vpos] == x:
			CordManager.dict.erase(x.vpos)
		x.queue_free()
	CordManager.virtual_block.clear()


func _mouse_entered(block: Node2D, shape_idx):
	print('enter %s %s' % [block.vpos, shape_idx])
	var instance = _gen_block_instance(block, shape_idx)
	instance.set_virtual(true)
	for i in range(3):
		instance.disable_shape(i, true)
	CordManager.virtual_block[[block.vpos, shape_idx]] = instance
