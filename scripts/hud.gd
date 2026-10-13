extends CanvasLayer

# ============================================
# HUD - Heads-Up Display controller
# Manages UI labels, score/lives/wave updates, and game state transitions.
# ============================================

# --- On-ready UI node references ---
@onready var score_label: Label = $Score
@onready var lives_label: Label = $Lives
@onready var wave_label: Label = $Wave
@onready var game_over_label: Label = $GameOver
@onready var win_label: Label = $Win
@onready var start_button: Button = $Start

# --- Game state variables ---
var score: int = 0
var lives: int = 3
var wave: int = 1
var game_state: String = "start"  # start, playing, game_over, win

# ============================================
# _ready() - Initialize HUD state and visibility
# ============================================
func _ready() -> void:
	update_score()
	update_lives()
	update_wave()
	game_over_label.visible = false
	win_label.visible = false
	start_button.visible = true
	start_button.grab_focus()

# ============================================
# _on_start_button_pressed() - Handle start/restart button clicks
# ============================================
func _on_start_button_pressed() -> void:
	var gm: Node2D = get_tree().root.get_node("Main")
	if gm and gm.has_method("start_game"):
		if game_state == "start":
			gm.start_game()
		elif game_state == "game_over" or game_state == "win":
			gm.restart_game()
		start_button.visible = false
		game_state = "playing"

# ============================================
# lose_life() - Decrement lives and check for game over
# ============================================
func lose_life() -> void:
	lives -= 1
	update_lives()
	if lives <= 0:
		game_state = "game_over"
		game_over_label.visible = true

# ============================================
# update_score() - Refresh score label text
# ============================================
func update_score() -> void:
	score_label.text = "Score: %d" % score

# ============================================
# update_lives() - Refresh lives label text
# ============================================
func update_lives() -> void:
	lives_label.text = "Lives: %d" % lives

# ============================================
# update_wave() - Refresh wave label text
# ============================================
func update_wave() -> void:
	wave_label.text = "Wave: %d" % wave
