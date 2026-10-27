# load_solver.gd
extends RefCounted
class_name LoadSolver

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
	var states: Dictionary = {}
	for b in grid.blocks:
		states[b] = BlockState.new(b)
	
	var sorted_blocks = grid.blocks.duplicate()
	sorted_blocks.sort_custom(func(a, b): 
		return (a.position.y + a.current_footprint.y) > (b.position.y + b.current_footprint.y)
	)
	
	for b in sorted_blocks:
		var state = states[b]
		state.effective_capacity = b.data.capacity
		
		for other in grid.blocks:
			if other == b: continue
			if calculate_overlap_at_level(other, b) > 0:
				for effect in other.data.effects:
					if effect.trigger == CardEffect.Trigger.PASSIVE_CAPACITY and effect.target_mode == CardEffect.TargetMode.BELOW:
						state.effective_capacity += effect.amount
		
		var overload_factor = GameConfig.OVERLOAD_HP_FACTOR
		state.overload = max(0.0, state.load_from_above - state.effective_capacity)
		state.effective_max_hp = max(0.0, b.data.max_hp - state.overload * overload_factor)
		state.current_hp = state.effective_max_hp - b.damage_taken
		
		var total_weight_to_pass = b.data.weight + state.load_from_above
		var supports = find_supports(b, grid)
		
		if supports.size() > 0:
			var total_overlap = 0.0
			for s in supports:
				total_overlap += float(calculate_overlap(b, s))
				
			for s in supports:
				var overlap = float(calculate_overlap(b, s))
				var share = (overlap / total_overlap) * total_weight_to_pass
				states[s].load_from_above += share
				
	return states

func calculate_overlap_at_level(top: Block, bottom: Block) -> int:
	if top.position.y != bottom.position.y + bottom.current_footprint.y:
		return 0
	var start_x = max(top.position.x, bottom.position.x)
	var end_x = min(top.position.x + top.current_footprint.x, bottom.position.x + bottom.current_footprint.x)
	return max(0, end_x - start_x)

func find_supports(b: Block, grid: CastleGrid) -> Array[Block]:
	var supports: Array[Block] = []
	for s in grid.blocks:
		if s == b: continue
		if calculate_overlap_at_level(b, s) > 0:
			supports.append(s)
	return supports

func calculate_overlap(b: Block, s: Block) -> int:
	return calculate_overlap_at_level(b, s)
