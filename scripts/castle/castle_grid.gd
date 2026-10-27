# castle_grid.gd
extends RefCounted
class_name CastleGrid

const GRID_W = 16
const GRID_H = 10

var blocks: Array[Block] = []

# Проверка: можно ли поставить блок в данную позицию
func can_place_block(data: CardData, pos: Vector2i, rotation: float) -> bool:
	var fp = data.footprint if rotation == 0 else Vector2i(data.footprint.y, data.footprint.x)
	
	# 1. Выход за границы сетки
	if pos.x < 0 or pos.y < 0 or pos.x + fp.x > GRID_W or pos.y + fp.y > GRID_H:
		return false
		
	# 2. Пересечение с другими блоками
	var new_cells = []
	for x in range(fp.x):
		for y in range(fp.y):
			new_cells.append(pos + Vector2i(x, y))
			
	for b in blocks:
		for cell in b.get_occupied_cells():
			if cell in new_cells:
				return false
				
	# 3. Опора: хотя бы одна клетка снизу должна быть землей (row=0) или другим блоком
	var has_support = false
	for x in range(fp.x):
		var cell_below = pos + Vector2i(x, -1)
		if cell_below.y < 0: # Земля
			has_support = true
			break
		if is_cell_occupied(cell_below): # Другой блок
			has_support = true
			break
			
	return has_support

func is_cell_occupied(cell: Vector2i) -> bool:
	for b in blocks:
		if cell in b.get_occupied_cells():
			return true
	return false

func add_block(data: CardData, pos: Vector2i, rotation: float, is_core: bool = false) -> Block:
	var b = Block.new(data, pos, is_core)
	b.rotation = rotation
	blocks.append(b)
	return b

func remove_block(block: Block):
	blocks.erase(block)
