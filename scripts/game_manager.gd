extends Node2D

@export var alien_scene: PackedScene
@export var bullet_scene: PackedScene
@export var player_scene: PackedScene

@onready var hud: CanvasLayer = $HUD
@onready var player: Node2D = $Player
@onready var alien_grid: Node2D = $AlienGrid
@onready var shield_grid: Node2D = $ShieldGrid
@onready var ufo: Node2D = $UFO

var aliens_remaining: int = 0
var wave: int = 1
var game_active: bool = false
var score: int = 0
var lives: int = 3
var alien_direction: int = 1
var alien_speed: float = 150.0
var alien_drop_distance: float = 20.0
var alien_move_timer: float = 0.0
var alien_move_interval: float = 0.5
var ufo_active: bool = false
var ufo_timer: float = 0.0
var ufo_direction: int = 1
const UFO_SPAWN_INTERVAL: float = 20.0
const UFO_SPEED: float = 150.0
const UFO_SCORE: int = 100
const ALIEN_SHOOT_CHANCE: float = 0.002

func _ready() -> void:
	add_to_group("game_manager")
	player.position = Vector2(get_viewport_rect().size.x / 2, get_viewport_rect().size.y - 80)
	hud.game_state = "start"
	#hud.start.visible = true
	hud.game_over_label.visible = false
	hud.win_label.visible = false
	if not alien_scene:
		push_error("alien_scene is not assigned in the inspector!")
	if not bullet_scene:
		push_error("bullet_scene is not assigned in the inspector!")

func spawn_aliens() -> void:
	if not alien_scene:
		push_error("Cannot spawn aliens: alien_scene is null!")
		return
	for child in alien_grid.get_children():
		child.queue_free()
	
	aliens_remaining = 0
	var columns: int = 10
	var rows: int = 4
	var start_x: float = 80.0
	var start_y: float = 60.0
	
	for row in range(rows):
		for col in range(columns):
			var alien: CharacterBody2D = alien_scene.instantiate()
			alien.position = Vector2(start_x + col * 55, start_y + row * 50)
			alien.add_to_group("alien")
			alien.alien_wave = wave
			alien.alien_speed = alien_speed
			alien_grid.add_child(alien)
			aliens_remaining += 1

func spawn_shields() -> void:
	for child in shield_grid.get_children():
		child.queue_free()
	
	var shield_positions: Array[Vector2] = [
		Vector2(200, 450),
		Vector2(450, 450),
		Vector2(700, 450),
		Vector2(950, 450),
	]
	
	for pos in shield_positions:
		var shield: Area2D = Area2D.new()
		shield.position = pos
		shield.add_to_group("shield")
		
		var visual: ColorRect = ColorRect.new()
		visual.size = Vector2(40, 30)
		visual.color = Color(0.2, 1.0, 0.2, 0.8)
		shield.add_child(visual)
		
		var collision: CollisionShape2D = CollisionShape2D.new()
		var shape: RectangleShape2D = RectangleShape2D.new()
		shape.size = Vector2(38, 28)
		collision.shape = shape
		shield.add_child(collision)
		
		shield_grid.add_child(shield)

func start_game() -> void:
	if game_active:
		return
	game_active = true
	score = 0
	lives = 3
	wave = 1
	alien_speed = 150.0
	alien_direction = 1
	alien_move_interval = 0.5
	ufo_active = false
	ufo_timer = 0.0
	ufo_direction = 1
	hud.game_state = "playing"
	hud.score = score
	hud.lives = lives
	hud.update_score()
	hud.update_lives()
	hud.update_wave()
	hud.game_over_label.visible = false
	hud.win_label.visible = false
	hud.start_button.visible = false
	
	# Reset player visibility
	player.visible = true
	player.position = Vector2(get_viewport_rect().size.x / 2, get_viewport_rect().size.y - 80)
	spawn_aliens()
	spawn_shields()
	ufo.visible = false

func restart_game() -> void:
	# Clear state without unnecessary toggle
	for child in alien_grid.get_children():
		child.queue_free()
	for child in shield_grid.get_children():
		child.queue_free()
	aliens_remaining = 0
	ufo_active = false
	ufo.visible = false
	player.visible = true
	start_game()

func on_alien_killed(points: int) -> void:
	if not game_active:
		return
	aliens_remaining -= 1
	add_score(points)
	# Check wave progression only when an alien is actually killed
	if aliens_remaining <= 0:
		wave += 1
		alien_speed += 20
		alien_move_interval = max(0.05, alien_move_interval * 0.8)
		hud.wave = wave
		hud.update_wave()
		spawn_aliens()
		spawn_shields()
		alien_move_timer = 0.0

func add_score(points: int) -> void:
	if not game_active:
		return
	score += points
	hud.score = score
	hud.update_score()
	if score >= 300:
		game_win()

func lose_life() -> void:
	if not game_active:
		return
	lives -= 1
	hud.lives = lives
	hud.update_lives()
	if lives <= 0:
		game_over()

func game_over() -> void:
	game_active = false
	hud.game_state = "game_over"
	hud.game_over_label.visible = true
	# Hide player on game over
	player.visible = false
	hud.start_button.visible = true
	
	
	

func game_win() -> void:
	game_active = false
	hud.game_state = "win"
	hud.win_label.visible = true

func on_ufo_hit() -> void:
	if not game_active:
		return
	add_score(UFO_SCORE)
	ufo_active = false
	ufo.visible = false

func _process(delta: float) -> void:
	if not game_active:
		return
	
	# Check if aliens need to drop down
	var need_drop: bool = false
	for alien in alien_grid.get_children():
		if alien is CharacterBody2D:
			if alien_direction > 0 and alien.position.x > get_viewport_rect().size.x - 40:
				need_drop = true
			elif alien_direction < 0 and alien.position.x < 40:
				need_drop = true
	
	if need_drop:
		alien_direction *= -1
		for alien in alien_grid.get_children():
			if alien is CharacterBody2D:
				alien.position.y += alien_drop_distance
		alien_move_interval = max(0.05, alien_move_interval * 0.9)
	
	# Move aliens at intervals
	alien_move_timer += delta
	if alien_move_timer >= alien_move_interval:
		alien_move_timer = 0.0
		for alien in alien_grid.get_children():
			if alien is CharacterBody2D:
				alien.position.x += alien_direction * alien_speed * delta
		
		# Check edge bounds after move and reverse if needed
		for alien in alien_grid.get_children():
			if alien is CharacterBody2D:
				if alien_direction > 0 and alien.position.x > get_viewport_rect().size.x - 40:
					alien_move_timer = alien_move_interval
				elif alien_direction < 0 and alien.position.x < 40:
					alien_move_timer = alien_move_interval
	
	# Alien shooting - random chance per move interval
	for alien in alien_grid.get_children():
		if alien is CharacterBody2D and randf() < ALIEN_SHOOT_CHANCE:
			alien.shoot()
	
	# Check if aliens reached the player
	for alien in alien_grid.get_children():
		if alien is CharacterBody2D and alien.position.y > get_viewport_rect().size.y - 100:
			game_over()
			return
	
	# UFO logic
	ufo_timer += delta
	if not ufo_active and ufo_timer >= UFO_SPAWN_INTERVAL:
		ufo_active = true
		ufo_timer = 0.0
		ufo.visible = true
		ufo.position = Vector2(-60, 30)
		ufo_direction = 1
	
	if ufo_active and ufo.visible:
		ufo.position.x += UFO_SPEED * delta * ufo_direction
		if ufo.position.x > get_viewport_rect().size.x + 60:
			ufo.visible = false
			ufo_active = false
