# run_tests.gd
extends SceneTree

var failures = 0

func _init():
	print("Starting Logic Tests...")
	run_test_1()
	run_test_2()
	run_test_3()
	run_test_4()
	print("\n----------------------------")
	print("Tests finished. Failures: ", failures)
	quit(failures)

func run_test_1():
	print("\nTest 1: Overload")
	var grid = CastleGrid.new()
	var solver = LoadSolver.new()
	var low_card = load_card("low_card")
	var face_card = load_card("face_card")
	var b1 = grid.add_block(low_card, Vector2i(0, 0), 0)
	var b2 = grid.add_block(face_card, Vector2i(0, 2), 0)
	var b3 = grid.add_block(face_card, Vector2i(0, 4), 0)
	var states = solver.solve(grid)
	var s1 = states[b1]
	if abs(s1.load_from_above - 6.0) > 0.1 or abs(s1.overload - 2.0) > 0.1 or abs(s1.effective_max_hp - 4.0) > 0.1:
		print("FAIL: Expected Load=6, Overload=2, HP=4. Got L=", s1.load_from_above, " O=", s1.overload, " HP=", s1.effective_max_hp)
		failures += 1
	else:
		print("PASSED")

func run_test_2():
	print("\nTest 2: Recovery")
	var grid = CastleGrid.new()
	var solver = LoadSolver.new()
	var low_card = load_card("low_card")
	var face_card = load_card("face_card")
	var b1 = grid.add_block(low_card, Vector2i(0, 0), 0)
	var b2 = grid.add_block(face_card, Vector2i(0, 2), 0)
	var b3 = grid.add_block(face_card, Vector2i(0, 4), 0)
	grid.remove_block(b2)
	var states = solver.solve(grid)
	var s1 = states[b1]
	if abs(s1.load_from_above - 3.0) > 0.1 or s1.overload != 0 or abs(s1.effective_max_hp - 6.0) > 0.1:
		print("FAIL: Expected Load=3, Overload=0, HP=6. Got L=", s1.load_from_above, " O=", s1.overload, " HP=", s1.effective_max_hp)
		failures += 1
	else:
		print("PASSED")

func run_test_3():
	print("\nTest 3: Weight Distribution")
	var grid = CastleGrid.new()
	var solver = LoadSolver.new()
	var plank = load_card("plank") 
	var face_card = load_card("face_card") 
	var low_card = load_card("low_card") 
	var s1 = grid.add_block(low_card, Vector2i(0, 0), 0)
	var s2 = grid.add_block(low_card, Vector2i(1, 0), 0)
	var b_plank = grid.add_block(plank, Vector2i(0, 1), 0)
	var b_face = grid.add_block(face_card, Vector2i(0, 2), 0)
	var states = solver.solve(grid)
	var st1 = states[s1]
	var st2 = states[s2]
	if abs(st1.load_from_above - 2.5) > 0.1 or abs(st2.load_from_above - 2.5) > 0.1:
		print("FAIL: Expected Load=2.5 for both. Got S1=", st1.load_from_above, " S2=", st2.load_from_above)
		failures += 1
	else:
		print("PASSED")

func run_test_4():
	print("\nTest 4: Capacity Bonus")
	var grid = CastleGrid.new()
	var solver = LoadSolver.new()
	var low_card = load_card("low_card")
	var buttress = load_card("buttress")
	var bonus = CardEffect.new()
	bonus.trigger = CardEffect.Trigger.PASSIVE_CAPACITY
	bonus.target_mode = CardEffect.TargetMode.BELOW
	bonus.amount = 6.0
	buttress.effects.append(bonus)
	var b1 = grid.add_block(low_card, Vector2i(0, 0), 0)
	var b2 = grid.add_block(buttress, Vector2i(0, 2), 0)
	var states = solver.solve(grid)
	var s1 = states[b1]
	if abs(s1.effective_capacity - 10.0) > 0.1:
		print("FAIL: Expected Cap=10. Got ", s1.effective_capacity)
		failures += 1
	else:
		print("PASSED")

func load_card(id: String) -> CardData:
	var cd = CardData.new()
	match id:
		"foundation": cd.footprint = Vector2i(3,1); cd.weight = 4; cd.capacity = 30; cd.max_hp = 6
		"low_card": cd.footprint = Vector2i(1,2); cd.weight = 1; cd.capacity = 4; cd.max_hp = 6
		"face_card": cd.footprint = Vector2i(1,2); cd.weight = 3; cd.capacity = 10; cd.max_hp = 14
		"plank": cd.footprint = Vector2i(2,1); cd.weight = 2; cd.capacity = 6; cd.max_hp = 8
		"buttress": cd.footprint = Vector2i(1,1); cd.weight = 1; cd.capacity = 5; cd.max_hp = 5
		"martyr": cd.footprint = Vector2i(1,1); cd.weight = 1; cd.capacity = 3; cd.max_hp = 4
		"archer": cd.footprint = Vector2i(1,1); cd.weight = 1; cd.capacity = 3; cd.max_hp = 5
	return cd
