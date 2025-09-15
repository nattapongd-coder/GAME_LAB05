extends CharacterBody3D

@export var speed: float = 14.0
@export var fall_acceleration: float = 75.0  # เปลี่ยนกลับเป็น 75 เพื่อให้มีแรงโน้มถ่วง

@export var jump_impulse: float = 20.0
@export var bounce_impulse: float = 16.0
signal hit


var target_velocity = Vector3.ZERO
 


func _physics_process(delta):
	var direction = Vector3.ZERO

	# การรับ input การเคลื่อนที่
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_back"):
		direction.z += 1
	if Input.is_action_pressed("move_forward"):
		direction.z -= 1

	# หมุนตัวละครตามทิศทางการเคลื่อนที่
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		$pivot.basis = Basis.looking_at(direction)

	# ตั้งค่าความเร็วในแนวราบ
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed

	# Vertical Velocity
	if not is_on_floor(): # If in the air, fall towards the floor
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)
	else:
		target_velocity.y = 0  # รีเซ็ตความเร็วแนวตั้งเมื่ออยู่บนพื้น

	# Jumping.
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		target_velocity.y = jump_impulse

	# ตั้งค่าความเร็วทั้งหมดและเคลื่อนที่
	velocity = target_velocity
	move_and_slide()
	
	# ตรวจสอบการชนหลังจากเคลื่อนที่แล้ว
	for index in range(get_slide_collision_count()):
		var collision = get_slide_collision(index)
		
		if collision.get_collider() == null:
			continue

		if collision.get_collider().is_in_group("Mob"):
			var mob = collision.get_collider()
			# ตรวจสอบว่าเรากำลังชนจากด้านบนหรือไม่
			if Vector3.UP.dot(collision.get_normal()) > 0.1:
				# ถ้าใช่, เรากระโดดเหยียบมันและกระดอน
				mob.squash()
				target_velocity.y = bounce_impulse
				# ป้องกันการเรียกซ้ำ
				break
				
func die():
	emit_signal("hit")
	queue_free()
	
func _on_mob_detecter_body_entered(_body: Node3D) -> void:
	die()
