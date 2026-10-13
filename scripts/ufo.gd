extends Area2D

# ============================================
# UFO - Bonus target controller
# Moves across the top of the screen, drops bombs periodically, and awards points when destroyed.
# ============================================

# --- Exported configuration ---
@export var bomb_scene: PackedScene
@export var bomb_drop_interval: float = 1.5
@export var speed: float = 200.0

# --- State variables ---
var is_active: bool = true
var drop_timer: float = 0.0
var direction: int = 1

# ============================================
# _ready() - Initialize UFO group and connect collision signal
# ============================================
func _ready() -> void:
	add_to_group("ufo")
	body_entered.connect(_on_body_entered)

# ============================================
# _process() - Move UFO horizontally and drop bombs
# ============================================
func _process(delta: float) -> void:
	if not is_active:
		return
	position.x += speed * direction * delta
	drop_timer += delta
	if drop_timer >= bomb_drop_interval:
		drop_timer = 0.0
		drop_bomb()

# ============================================
# drop_bomb() - Instantiate and spawn an alien bomb from the UFO
# ============================================
func drop_bomb() -> void:
	if not bomb_scene:
		return
	var parent: Node2D = get_parent()
	if not parent:
		return
	var bomb: Area2D = bomb_scene.instantiate()
	bomb.is_player_bullet = false
	parent.add_child(bomb)
	bomb.position = global_position + Vector2(0, 30)

# ============================================
# _on_body_entered() - Handle UFO being hit by player bullets
# ============================================
func _on_body_entered(body: Node2D) -> void:
	if not is_active:
		return
	if body.is_in_group("player_bullet"):
		is_active = false
		visible = false
		modulate = Color(1, 1, 1, 0.5)
		var game_manager: Node2D = get_parent()
		if game_manager and game_manager.has_method("on_ufo_hit"):
			game_manager.on_ufo_hit()
