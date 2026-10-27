# card_data.gd
extends Resource
class_name CardData

@export var id: String = ""
@export var display_name: String = ""
@export var suit: String = "" # Масть
@export var rank: int = 0      # Ранг

@export var footprint: Vector2i = Vector2i(1, 1) # ширина x высота
@export var rotatable: bool = true
@export var weight: float = 1.0
@export var capacity: float = 5.0
@export var max_hp: float = 10.0

@export var effects: Array[CardEffect] = []

# Параметры атаки (0 = блок не атакует)
@export var attack_damage: float = 0.0
@export var attack_interval: float = 0.0
@export var attack_range: int = 0
