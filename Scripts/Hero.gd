extends KinematicBody2D

var velocity = Vector2(0, 0)
var coins = 0
var is_hit = false
var is_dying = false
var in_ladder_area = false

const WALK_SPEED = 120
const RUN_SPEED = 500
const ATTACK_SPEED = 90
const GRAVITY = 35
const JUMPFORCE = -1100
const HIT_JUMP_VEL = 200 
const CLIMB_VELOCITY = 450

func _physics_process(_delta):
	if not is_hit and not is_dying:
		if not is_on_floor() and velocity.y > 0:
			$AnimatedSprite.play("falling")
		elif not is_on_floor() and velocity.y < 0:
			if Input.is_action_pressed("ui_right"):
				velocity.x = WALK_SPEED
			elif Input.is_action_pressed("ui_left"):
				velocity.x = -WALK_SPEED
			else:
				velocity.x = 0
			$AnimatedSprite.play("jumping") 
		elif Input.is_action_pressed("ui_right") and Input.is_action_pressed("ui_attack"):
			setup_attack()
			velocity.x = ATTACK_SPEED
			$AnimatedSprite.flip_h = false
		elif Input.is_action_pressed("ui_left") and Input.is_action_pressed("ui_attack"):
			setup_attack()
			velocity.x = -ATTACK_SPEED
			$AnimatedSprite.flip_h = true
		elif Input.is_action_pressed("ui_attack"):
			setup_attack()
			velocity.x = 0
		elif Input.is_action_pressed("ui_right") and Input.is_action_pressed("ui_run"):
			$AnimatedSprite.flip_h = false
			velocity.x = RUN_SPEED
			$AnimatedSprite.play("running")
		elif Input.is_action_pressed("ui_left") and Input.is_action_pressed("ui_run"):
			$AnimatedSprite.flip_h = true
			velocity.x = -RUN_SPEED	
			$AnimatedSprite.play("running")
		elif Input.is_action_pressed("ui_right"):
			$AnimatedSprite.flip_h = false
			velocity.x = WALK_SPEED
			$AnimatedSprite.play("walking")
		elif Input.is_action_pressed("ui_left"):
			$AnimatedSprite.flip_h = true
			velocity.x = -WALK_SPEED
			$AnimatedSprite.play("walking")
		elif Input.is_action_pressed("ui_up") and in_ladder_area:
			set_collision_layer_bit(0, true)
			velocity.y = -CLIMB_VELOCITY
			$AnimatedSprite.play("climbing")
		else:
			velocity.x = 0
			$AnimatedSprite.play("idle")
	
	velocity.y = velocity.y + GRAVITY
	
	if Input.is_action_just_pressed("ui_jump") and is_on_floor() and not in_ladder_area:
		velocity.y = JUMPFORCE
		$SoundJump.play()
	
	velocity = move_and_slide(velocity, Vector2.UP)
	
func _on_FallZone_body_entered(_body):
	get_tree().change_scene("res://Scenes/GameOver.tscn")
	
func setup_attack():
	$SoundSword.play()
	$SwordHit/CollisionShape2D.disabled = false
	$AnimatedSprite.play("fighting")	
	
func bounce():
	velocity.y = JUMPFORCE * 0.7
	
func hit(var enemy_pos_x):
	is_hit = true
	set_modulate(Color(1.0, 0.3, 0.3, 0.3))
	velocity.y = JUMPFORCE * 0.5

	if position.x < enemy_pos_x:
		velocity.x = -HIT_JUMP_VEL
	elif position.x > enemy_pos_x:
		velocity.x = HIT_JUMP_VEL

	Input.action_release("ui_left")
	Input.action_release("ui_right")
	
	$SoundBump.play()
	$HitTimer.start()

func _on_HitTimer_timeout():
	set_modulate(Color(1, 1, 1, 1))
	is_hit = false

func dying():
	is_dying = true
	$AnimatedSprite.play("dying")
	$SoundDie.play()
	$DieTimer.start()

func _on_DieTimer_timeout():
	queue_free()
	get_tree().change_scene("res://Scenes/GameOver.tscn")

func _on_Ladder_body_entered(body):
	if body.name == "Hero":
		in_ladder_area = true
		set_collision_layer_bit(0, false)
			
func _on_Ladder_body_exited(body):
	if body.name == "Hero":
		in_ladder_area = false
		set_collision_layer_bit(0, true)

func _on_SwordHit_body_entered(body):
	if body.is_in_group("enemies") and not $SwordHit/CollisionShape2D.disabled:
		body.hit()
		$SwordHit/CollisionShape2D.disabled = true
		print("sword hit")
