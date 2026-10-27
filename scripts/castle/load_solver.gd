# load_solver.gd
extends RefCounted
class_name LoadSolver

# Данные о состоянии блока после расчета
class BlockState:
	var block: Block
	var load_from_above: float = 0.0
	var effective_capacity: float = 0.0
	var overload: float = 0.0
	var effective_max_hp: float = 0.0
	var current_hp: float = 0.0
	
	func _init(_block: Block):
		block = _block

func solve(grid: CastleGrid) -> Dictionary:
	# Словарь: Block -> BlockState
	var states: Dictionary = {}
	for b in grid.blocks:
		states[b] = BlockState.new(b)
	
	# 1. Сортировка блоков сверху вниз (по верхней границе)
	# Чем выше верхняя граница (row + height), тем раньше считаем.
	var sorted_blocks = grid.blocks.duplicate()
	sorted_blocks.sort_custom(func(a, b): 
		return (a.position.y + a.current_footprint.y) > (b.position.y + b.current_footprint.y)
	)
	
	# 2. Расчет нагрузок
	for b in sorted_blocks:
		var state = states[b]
		
		# Расчет эффективной грузоподъёмности (включая бонусы от эффектов блоков СВЕРХУ)
		# Примечание: Согласно спецификации, бонусы могут быть от CardEffect. 
		# Пока реализуем базовую capacity.
		state.effective_capacity = b.data.capacity
		
		# Добавляем бонусы PASSIVE_CAPACITY от блоков, которые стоят на этом блоке
		for other in grid.blocks:
			if other == b: continue
			# Проверяем, если other стоит на b и имеет эффект PASSIVE_CAPACITY
			if is_block_on_top(other, b):
				for effect in other.data.effects:
					if effect.trigger == CardEffect.Trigger.PASSIVE_CAPACITY and effect.target_mode == CardEffect.TargetMode.BELOW:
						state.effective_capacity += effect.amount
		
		# Рассчитываем перегруз и HP
		var overload_factor = 1.0 # По умолчанию из game_config (в идеале брать из конфига)
		state.overload = max(0.0, state.load_from_above - state.effective_capacity)
		state.effective_max_hp = max(0.0, b.data.max_hp - state.overload * overload_factor)
		state.current_hp = state.effective_max_hp - b.damage_taken
		
		# Передаем вес вниз
		var total_weight_to_pass = b.data.weight + state.load_from_above
		var supports = find_supports(b, grid)
		
		if supports.size() > 0:
			var total_overlap = 0
			for s in supports:
				total_overlap += calculate_overlap(b, s)
				
			for s in supports:
				var overlap = calculate_overlap(b, s)
				var share = (overlap / total_overlap) * total_weight_to_pass
				states[s].load_from_above += share
				
	return states

# Вспомогательные функции
func is_block_on_top(top: Block, bottom: Block) -> bool:
	# Блок top стоит на bottom, если их клетки пересекаются в ряду (top.y) и (bottom.y + bottom.h)
	var top_bottom_cells = []
	for x in range(top.current_footprint.x):
		top_bottom_cells.append(top.position + Vector2i(x, 0))
		
	for cell in top_bottom_cells:
		if bottom.is_cell_occupied(cell): # Это упрощение, ниже реализовано точнее через overlap
			pass
	
	# Точная проверка: есть ли общие клетки в ряду основания верхнего и крыши нижнего
	var overlap = calculate_overlap_at_level(top, bottom)
	return overlap > 0

func calculate_overlap_at_level(top: Block, bottom: Block) -> int:
	# Считаем сколько клеток основания top (row = top.y) совпадают с клетками крыши bottom (row = bottom.y + bottom.h - 1)
	if top.position.y != bottom.position.y + bottom.current_footprint.y:
		return 0
		
	var overlap = 0
	var start_x = max(top.position.x, bottom.position.x)
	var end_x = min(top.position.x + top.current_footprint.x, bottom.position.x + bottom.current_footprint.x)
	
	if start_x < end_x:
		overlap = end_x - start_x
	return overlap

func find_supports(b: Block, grid: CastleGrid) -> Array[Block]:
	var supports: Array[Block] = []
	# Проверяем все блоки в сетке
	for s in grid.blocks:
		if s == b: continue
		if calculate_overlap_at_level(b, s) > 0:
			supports.append(s)
	return supports

func calculate_overlap(b: Block, s: Block) -> int:
	return calculate_overlap_at_level(b, s)
