extends Area2D

var is_player_bullet: bool = true
@export var speed: float = 600.0
@export var damage: int = 1

@onready var game_manager: Node2D = get_tree().root.get_node("Main")

func _ready() -> void:
	add_to_group("player_bullet" if is_player_bullet else "alien_bullet")
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	if is_player_bullet:
		position.y -= speed * delta
		if position.y < -32:
			queue_free()
	else:
		position.y += speed * delta
		if position.y > get_viewport_rect().size.y + 32:
			queue_free()

func _on_body_entered(body: Node2D) -> void:
	if not is_alive():
		return
	
	# Destroy shield segments on contact
	if body.is_in_group("shield"):
		queue_free()
		body.queue_free()
		return
	
	if is_player_bullet and body.is_in_group("alien"):
		queue_free()
		body.alive = false
		body.queue_free()
		if game_manager and game_manager.has_method("add_score"):
			game_manager.add_score(10)
	elif not is_player_bullet and body.is_in_group("player"):
		queue_free()
		if game_manager and game_manager.has_method("lose_life"):
			game_manager.lose_life()
	elif is_player_bullet and body.is_in_group("ufo"):
		queue_free()
		if game_manager and game_manager.has_method("add_score"):
			game_manager.add_score(game_manager.UFO_SCORE)
		game_manager.ufo_active = false
		game_manager.ufo.visible = false

func is_alive() -> bool:
	return is_node_ready() and not is_queued_for_deletion()
