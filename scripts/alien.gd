extends CharacterBody2D

# ============================================
# Alien - Individual enemy ship controller
# Handles alien state, screen bounds cleanup, and shooting logic.
# Movement is controlled by GameManager, not this script.
# ============================================

# --- Exported configuration ---
@export var speed: float = 10.0
@export var bullet_scene: PackedScene

# --- On-ready references ---
@onready var screen_size: Vector2 = get_viewport_rect().size

# --- State variables ---
var alive: bool = true
var score_value: int = 10
var alien_wave: int = 1 
var alien_speed: float = 100.0

# ============================================
# _ready() - Add alien to game group
# ============================================
func _ready() -> void:
	add_to_group("alien")

# ============================================
# _physics_process() - Clean up aliens that fall off screen
# ============================================
func _physics_process(_delta: float) -> void:
	if not alive:
		return
	# Remove if off screen (from being dropped too low)
	if position.y > screen_size.y + 32:
		queue_free()

# ============================================
# shoot() - Instantiate and spawn an alien bullet downward
# ============================================
func shoot() -> void:
	if bullet_scene:
		var bullet: Area2D = bullet_scene.instantiate()
		get_parent().add_child(bullet)
		bullet.position = global_position + Vector2(0, 30)
		bullet.is_player_bullet = false
