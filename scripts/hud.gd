extends CanvasLayer

@onready var score_label: Label = $Score
@onready var lives_label: Label = $Lives
@onready var wave_label: Label = $Wave
@onready var game_over_label: Label = $GameOver
@onready var win_label: Label = $Win
@onready var start_label: Label = $Start

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
	start_label.visible = true

func _process(_delta: float) -> void:
	if game_state == "start" and Input.is_action_just_pressed("player_shoot"):
		get_tree().call_group("game_manager", "start_game")
		start_label.visible = false
		game_state = "playing"
	elif (game_state == "game_over" or game_state == "win") and Input.is_action_just_pressed("player_shoot"):
		get_tree().call_group("game_manager", "restart_game")
		game_over_label.visible = false
		win_label.visible = false
		game_state = "playing"

func add_score(points: int) -> void:
	score += points
	update_score()
	if score >= 300:
		win()

func lose_life() -> void:
	lives -= 1
	update_lives()
	if lives <= 0:
		game_over()

func update_score() -> void:
	score_label.text = "Score: %d" % score

func update_lives() -> void:
	lives_label.text = "Lives: %d" % lives

func update_wave() -> void:
	wave_label.text = "Wave: %d" % wave

func game_over() -> void:
	game_state = "game_over"
	game_over_label.visible = true

func win() -> void:
	game_state = "win"
	win_label.visible = true
