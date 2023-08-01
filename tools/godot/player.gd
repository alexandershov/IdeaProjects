# GDScript is a language similar to Python

extends Area2D

signal hit


# @export allows you to edit variable in the Node properties
@export var speed = 400

var screen_size


func _ready():
	# _ready() is called when a node enters the scene tree
	hide()
	screen_size = get_viewport_rect().size
	
	
func _process(delta):
	# _process is called on every frame
	# delta is time elapsed from the previous call of _process
	var velocity = Vector2.ZERO
	if Input.is_action_pressed('move_down'):
		velocity.y += 1
	if Input.is_action_pressed('move_up'):
		velocity.y -= 1
	if Input.is_action_pressed('move_left'):
		velocity.x -= 1
	if Input.is_action_pressed('move_right'):
		velocity.x += 1
		
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		# $x is a shorthand for get_node('x')
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
	position += velocity * delta
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)
	if velocity.x != 0:
		$AnimatedSprite2D.animation = 'walk'
		$AnimatedSprite2D.flip_v = false
		$AnimatedSprite2D.flip_h = velocity.x < 0
	if velocity.y != 0:
		$AnimatedSprite2D.animation = 'up'
		$AnimatedSprite2D.flip_v = velocity.y > 0
		$AnimatedSprite2D.flip_h = false
		

func _on_body_entered(body):
	hide()
	hit.emit()
	$CollisionShape2D.set_deferred('disabled', true)
	

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false
