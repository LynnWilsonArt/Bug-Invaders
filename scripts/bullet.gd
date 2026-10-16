extends Area2D

# ============================================
# Bullet - Projectile controller
# Handles movement, collision detection, and damage application for both player and alien bullets.
# ============================================

# --- Bullet configuration ---
var is_player_bullet: bool = true
@export var speed: float = 600.0
@export var damage: int = 1

# --- On-ready references ---
@onready var game_manager: Node2D = get_tree().root.get_node("Main")

# ============================================
# _ready() - Initialize bullet group and connect collision signals
# ============================================
func _ready() -> void:
	add_to_group("player_bullet" if is_player_bullet else "alien_bullet")
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

# ============================================
# _physics_process() - Move bullet and destroy when off-screen
# ============================================
func _physics_process(delta: float) -> void:
	if is_player_bullet:
		position.y -= speed * delta
		if position.y < -32:
			queue_free()
	else:
		position.y += speed * delta
		if position.y > get_viewport_rect().size.y + 32:
			queue_free()

# ============================================
# _on_body_entered() - Handle bullet collision with PhysicsBody2D
# ============================================
func _on_body_entered(body: Node2D) -> void:
	if not is_alive():
		return
	
	# Player bullet hits alien
	if is_player_bullet and body.is_in_group("alien"):
		queue_free()
		body.alive = false
		body.queue_free()
		if game_manager and game_manager.has_method("on_alien_killed"):
			game_manager.on_alien_killed(10)
	# Alien bullet hits player
	elif not is_player_bullet and body.is_in_group("player"):
		queue_free()
		if game_manager and game_manager.has_method("lose_life"):
			game_manager.lose_life()
	# Player bullet hits UFO
	elif is_player_bullet and body.is_in_group("ufo"):
		queue_free()
		if game_manager and game_manager.has_method("on_ufo_hit"):
			game_manager.on_ufo_hit()

# ============================================
# _on_area_entered() - Handle bullet collision with Area2D (shields)
# ============================================
func _on_area_entered(area: Area2D) -> void:
	if not is_alive():
		return
	
	# Aliens cannot destroy shields. 
	#Only friendly fire can destroy shield segments on contact
	if not is_player_bullet and area.is_in_group("shield"):
		queue_free()
	else: # Player shoots shield and destroys it.
		if is_player_bullet and area.is_in_group("shield"):
			queue_free()
			area.queue_free()

# ============================================
# is_alive() - Check if bullet is still valid
# ============================================
func is_alive() -> bool:
	return is_node_ready() and not is_queued_for_deletion()
