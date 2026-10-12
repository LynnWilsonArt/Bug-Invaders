extends CanvasLayer

@onready var score_label: Label = $Score
@onready var lives_label: Label = $Lives
@onready var wave_label: Label = $Wave
@onready var game_over_label: Label = $GameOver
@onready var win_label: Label = $Win
@onready var start_button: Button = $Start

var score: int = 0
var lives: int = 3
var wave: int = 1
var game_state: String = "start"  # start, playing, game_over, win

func _ready() -> void:
	update_score()
	update_lives()
	update_wave()
	game_over_label.visible = false
	win_label.visible = false
	start_button.visible = true
	start_button.grab_focus()

func _on_start_button_pressed() -> void:
	var gm: Node2D = get_tree().root.get_node("Main")
	if gm and gm.has_method("start_game"):
		if game_state == "start":
			gm.start_game()
		elif game_state == "game_over" or game_state == "win":
			gm.restart_game()
		start_button.visible = false
		game_state = "playing"

func lose_life() -> void:
	lives -= 1
	update_lives()
	if lives <= 0:
		game_state = "game_over"
		game_over_label.visible = true
		

func update_score() -> void:
	score_label.text = "Score: %d" % score

func update_lives() -> void:
	lives_label.text = "Lives: %d" % lives

func update_wave() -> void:
	wave_label.text = "Wave: %d" % wave
