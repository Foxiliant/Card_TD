# enemy_data.gd
extends Resource
class_name EnemyData

enum AttackMode {
	RAM,       # Таран: идет по прямой, бьет первый блок на пути
	CATAPULT   # Катапульта: бьет случайный доступный блок
}

@export var id: String = ""
@export var max_hp: float = 10.0
@export var speed: float = 50.0
@export var damage: float = 2.0
@export var attack_interval: float = 1.5
@export var attack_mode: AttackMode = AttackMode.RAM
