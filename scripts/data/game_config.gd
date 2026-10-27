# game_config.gd
extends RefCounted
class_name GameConfig

# Сетка
const GRID_W = 16
const GRID_H = 10
const CELL_SIZE = 64 # в пикселях

# Баланс нагрузки
const OVERLOAD_HP_FACTOR = 1.0

# Ограничения
const MAX_COLLAPSE_ITERATIONS = 100
