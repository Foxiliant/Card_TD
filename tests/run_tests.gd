# run_tests.gd
extends SceneTree

func _init():
	print("Starting Logic Tests...")
	run_test_1()
	run_test_2()
	run_test_3()
	run_test_4()
	print("All tests finished.")
	quit()

func run_test_1():
	print("\nTest 1: Overload")
	var grid = CastleGrid.new()
	var solver = LoadSolver.new()
	
	var low_card = load_card("low_card")
	var face_card = load_card("face_card")
	
	# low_card на земле (0,0), на ней две face_card
	var b1 = grid.add_block(low_card, Vector2i(0, 0), 0)
	var b2 = grid.add_block(face_card, Vector2i(0, 1), 0)
	var b3 = grid.add_block(face_card, Vector2i(0, 2), 0)
	
	var states = solver.solve(grid)
	var s1 = states[b1]
	
	print("Load on low_card: ", s1.load_from_above) # Ожидаем 6 (3+3)
	print("Overload: ", s1.overload) # Ожидаем 2 (6 - 4)
	print("Eff Max HP: ", s1.effective_max_hp) # Ожидаем 4 (6 - 2*1)
	
	assert(abs(s1.load_from_above - 6.0) < 0.1, "Test 1 Load Fail")
	assert(abs(s1.overload - 2.0) < 0.1, "Test 1 Overload Fail")
	assert(abs(s1.effective_max_hp - 4.0) < 0.1, "Test 1 HP Fail")
	print("Test 1 PASSED")

func run_test_2():
	print("\nTest 2: Recovery")
	var grid = CastleGrid.new()
	var solver = LoadSolver.new()
	
	var low_card = load_card("low_card")
	var face_card = load_card("face_card")
	
	var b1 = grid.add_block(low_card, Vector2i(0, 0), 0)
	var b2 = grid.add_block(face_card, Vector2i(0, 1), 0)
	var b3 = grid.add_block(face_card, Vector2i(0, 2), 0)
	
	# Удаляем среднюю карту
	grid.remove_block(b2)
	
	var states = solver.solve(grid)
	var s1 = states[b1]
	
	print("Load on low_card: ", s1.load_from_above) # Ожидаем 3 (только верхняя)
	print("Overload: ", s1.overload) # Ожидаем 0 (3 < 4)
	print("Eff Max HP: ", s1.effective_max_hp) # Ожидаем 6
	
	assert(abs(s1.load_from_above - 3.0) < 0.1, "Test 2 Load Fail")
	assert(s1.overload == 0, "Test 2 Overload Fail")
	assert(abs(s1.effective_max_hp - 6.0) < 0.1, "Test 2 HP Fail")
	print("Test 2 PASSED")

func run_test_3():
	print("\nTest 3: Weight Distribution")
	var grid = CastleGrid.new()
	var solver = LoadSolver.new()
	
	var plank = load_card("plank") # w=2, weight=2
	var face_card = load_card("face_card") # w=1, weight=3
	var low_card = load_card("low_card") # w=1
	
	# Две опоры
	var s1 = grid.add_block(low_card, Vector2i(0, 0), 0)
	var s2 = grid.add_block(low_card, Vector2i(1, 0), 0)
	# Доска на них (занимает 0,0 и 1,0)
	var b_plank = grid.add_block(plank, Vector2i(0, 1), 0)
	# Карта на доске (центр)
	var b_face = grid.add_block(face_card, Vector2i(0, 2), 0)
	
	var states = solver.solve(grid)
	var st1 = states[s1]
	var st2 = states[s2]
	
	print("Support 1 Load: ", st1.load_from_above) # Ожидаем 2.5
	print("Support 2 Load: ", st2.load_from_above) # Ожидаем 2.5
	
	assert(abs(st1.load_from_above - 2.5) < 0.1, "Test 3 Support 1 Fail")
	assert(abs(st2.load_from_above - 2.5) < 0.1, "Test 3 Support 2 Fail")
	print("Test 3 PASSED")

func run_test_4():
	print("\nTest 4: Capacity Bonus")
	var grid = CastleGrid.new()
	var solver = LoadSolver.new()
	
	var low_card = load_card("low_card") # cap=4
	var buttress = load_card("buttress") # бонус +6
	
	# Сначала создаем эффект
	var bonus = CardEffect.new()
	bonus.trigger = CardEffect.Trigger.PASSIVE_CAPACITY
	bonus.target_mode = CardEffect.TargetMode.BELOW
	bonus.amount = 6.0
	buttress.effects.append(bonus)
	
	var b1 = grid.add_block(low_card, Vector2i(0, 0), 0)
	var b2 = grid.add_block(buttress, Vector2i(0, 1), 0)
	
	var states = solver.solve(grid)
	var s1 = states[b1]
	
	print("Effective Capacity: ", s1.effective_capacity) # Ожидаем 4 + 6 = 10
	assert(abs(s1.effective_capacity - 10.0) < 0.1, "Test 4 Bonus Fail")
	print("Test 4 PASSED")

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
