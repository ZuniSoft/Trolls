extends CanvasLayer

var coins = 0

func _ready():
	$Coins.text = String(coins)

func _on_coin_collected():
	coins = coins + 1
	_ready()
	if coins == 6:
		get_tree().change_scene("res://Scenes/Win.tscn")
