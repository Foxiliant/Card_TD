# card_effect.gd
extends Resource
class_name CardEffect

enum Trigger {
	PASSIVE_CAPACITY, # Постоянный бонус к грузоподъёмности
	ON_DESTROY       # Срабатывает при разрушении блока
}

enum TargetMode {
	BELOW,      # На блоки под текущим
	NEIGHBORS,   # На соседние блоки (включая диагонали или только стороны - уточняется в логике)
	SELF         # На самого себя
}

@export var trigger: Trigger
@export var target_mode: TargetMode
@export var amount: float = 0.0
