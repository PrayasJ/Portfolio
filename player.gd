extends KinematicBody

var curr_anim = null
var anims = ['burn_web', 'idle', 'inspect_wall', 'light_fire', 'pickup', 'turn_left', 'turn_right',
	'walk_back', 'walk_forward', 'walk_left', 'walk_right']

var walk_speed = 3
var MOUSE_SENSITIVITY = 0.07
var lookAngle = Vector2()
var lookRange = 60
var gravity = Vector3.DOWN * 2
var velocity = Vector3()
func anim_control(anim):
	#$main/AnimationPlayer.current_animation = anim
	$main/AnimationPlayer.play(anim, 0.15)
	curr_anim = anim

func _ready():
	anim_control('idle')
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	if Input.is_action_just_pressed("view"):
		if $main/Camera/gimbal/Camera.current == true:
			$main/Camera/Camera_Orientation.current = true
		else:
			$main/Camera/gimbal/Camera.current = true
	velocity = Vector3(0, velocity.y, 0)
	var move = Vector2()
	if Input.is_action_pressed("up"):
		move.y += walk_speed
	if Input.is_action_pressed("down"):
		move.y -= walk_speed
	if Input.is_action_pressed("left"):
		move.x += walk_speed
	if Input.is_action_pressed("right"):
		move.x -= walk_speed
	if curr_anim in ['turn_left', 'turn_right']:
		pass
	elif move.x > 0:
		anim_control('walk_left')
	elif move.x < 0:
		anim_control('walk_right')
	else:
		if move.y > 0:
			anim_control('walk_forward')
		elif move.y < 0:
			anim_control('walk_back')
		else:
			anim_control('idle')
	move = move.rotated(-rotation.y)
	velocity += gravity
	velocity.x += move.x
	velocity.z += move.y
	velocity = move_and_slide(velocity, Vector3.UP, true, 2)

func _input(event):
	if event.is_action_pressed('ui_toggleFullscreen'): 
		OS.window_fullscreen = !OS.window_fullscreen
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if event is InputEventMouseMotion:
		var cam1 = $main/Camera/gimbal
		var cam2 = $main/Camera/Camera_Orientation
		var movement = event.relative
		var c1 = abs(lookAngle.x) < lookRange
		var c2 = abs(lookAngle.x) > lookRange and movement.x * lookAngle.x < 0
		var c3 = abs(lookAngle.y) < lookRange
		var c4 = abs(lookAngle.y) > lookRange and movement.y * lookAngle.y < 0
		#if c1 or c2:
		lookAngle.x += 2 * movement.x * MOUSE_SENSITIVITY
		global_rotate(Vector3(0,1,0),-deg2rad(2 * movement.x * MOUSE_SENSITIVITY))
		#else:
			#if lookAngle.x < -lookRange:
			#	anim_control('turn_left')
			#if lookAngle.x > lookRange:
			#	anim_control('turn_right')
			#global_rotate(Vector3(0,1,0),deg2rad(lookAngle.x))
			#lookAngle.x = 0
		if c3 or c4:
			lookAngle.y += movement.y * MOUSE_SENSITIVITY
			cam1.rotate(Vector3(1,0,0),-deg2rad(movement.y * MOUSE_SENSITIVITY))
			cam2.rotate(Vector3(1,0,0),-deg2rad(movement.y * MOUSE_SENSITIVITY))
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_AnimationPlayer_animation_finished(anim_name):
	if curr_anim == 'turn_left':
		rotation_degrees += Vector3(0,90,0)
		anim_control('idle')
	if curr_anim == 'turn_right':
		rotation_degrees += Vector3(0,-90,0)
		anim_control('idle')
