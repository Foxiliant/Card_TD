# block.gd
extends RefCounted
class_name Block

var data: CardData
var position: Vector2i # Левый нижний угол в клетках (col, row)
var rotation: float = 0.0 # 0 или 90 градусов
var damage_taken: float = 0.0
var is_core: bool = false

# Вычисленный размер с учетом поворота
var current_footprint: Vector2i:
	get:
		if rotation == 0:
			return data.footprint
		else:
			return Vector2i(data.footprint.y, data.footprint.x)

func _init(_data: CardData, _pos: Vector2i, _is_core: bool = false):
	data = _data
	position = _pos
	is_core = _is_core

func get_occupied_cells() -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	var fp = current_footprint
	for x in range(fp.x):
		for y in range(fp.y):
			cells.append(position + Vector2i(x, y))
	return cells
