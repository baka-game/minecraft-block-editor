extends Node

var dict := {}
var virtual_block := {}

func vpos2pos(vpos: Vector3) -> Vector2:
	return Vector2(
		vpos.dot(Vector3(12, -12, 0)),
		vpos.dot(Vector3(6, 6, -13))
	)


func block_vpos(block: Node2D, shape_idx: int) -> Vector3:
	var vpos:Vector3 = block.vpos  # 虚拟坐标，以一个block为单位
	match shape_idx:
		0: 
			#pos += Vector2(0, -13)
			vpos.z += 1
		1: # left
			# pos += Vector2(-12, 6)
			vpos.y += 1
		2: # right
			# pos += Vector2(12, 6)
			vpos.x += 1
		_: pass
	return vpos

func add_block(block: Node2D, vpos: Vector3):
	dict[vpos] = block


func delete_block(_block: Node2D, vpos: Vector3):
	dict.erase(vpos)


var current_input_event_id = -1

