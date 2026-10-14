extends Area2D

@export var bomb_scene: PackedScene
@export var bomb_drop_interval: float = 1.5
@export var speed: float = 200.0

var is_active: bool = false
var drop_timer: float = 0.0
var direction: int = 1

func _ready() -> void:
	add_to_group("ufo")
	area_entered.connect(_on_area_entered)

func _process(delta: float) -> void:
	if not is_active:
		return

	position.x += speed * direction * delta

	drop_timer += delta
	if drop_timer >= bomb_drop_interval:
		drop_timer = 0.0
		drop_bomb()

func drop_bomb() -> void:
	if bomb_scene == null:
		return
	var parent: Node = get_parent()
	if parent == null:
		return
	var bomb: Area2D = bomb_scene.instantiate()
	bomb.is_player_bullet = false
	parent.add_child(bomb)
	bomb.global_position = global_position + Vector2(0, 30)

func _on_area_entered(area: Area2D) -> void:
	if not is_active:
		return
	if area.is_in_group("player_bullet"):
		var game_manager: Node = get_parent()
		if game_manager and game_manager.has_method("on_ufo_hit"):
			game_manager.on_ufo_hit()  # manager sets is_active/visible
