extends CharacterBody2D

# ============================================
# Player - Player ship controller
# Handles horizontal movement, screen clamping, and shooting with cooldown.
# ============================================

# --- Exported configuration ---
@export var speed: float = 400.0
@export var bullet_scene: PackedScene

# --- On-ready references ---
@onready var screen_size: Vector2 = get_viewport_rect().size

# --- State variables ---
var can_shoot: bool = true
const SHOOT_COOLDOWN: float = 0.3

# ============================================
# _ready() - Add player to game group and validate references
# ============================================
func _ready() -> void:
	add_to_group("player")
	if not bullet_scene:
		push_error("bullet_scene is not assigned on the Player node!")

# ============================================
# _physics_process() - Handle horizontal movement and screen clamping
# ============================================
func _physics_process(_delta: float) -> void:
	# Horizontal movement
	var direction: float = 0.0
	if Input.is_action_pressed("player_move_left"):
		direction -= 1.0
	if Input.is_action_pressed("player_move_right"):
		direction += 1.0
	velocity.x = direction * speed
	velocity.y = 0
	move_and_slide()
	
	# Clamp to screen bounds
	position.x = clamp(position.x, 32, screen_size.x - 32)

# ============================================
# _process() - Handle shooting input with cooldown
# ============================================
func _process(_delta: float) -> void:
	# Handle shooting
	if Input.is_action_just_pressed("player_shoot") and can_shoot:
		shoot()
		can_shoot = false
		await get_tree().create_timer(SHOOT_COOLDOWN).timeout
		can_shoot = true

# ============================================
# shoot() - Instantiate and spawn a player bullet upward
# ============================================
func shoot() -> void:
	if not bullet_scene:
		push_error("Cannot shoot: bullet_scene is null!")
		return
	var bullet: Area2D = bullet_scene.instantiate()
	get_parent().add_child(bullet)
	bullet.position = global_position + Vector2(0, -30)
	bullet.is_player_bullet = true
