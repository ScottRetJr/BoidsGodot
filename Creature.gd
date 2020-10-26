extends KinematicBody2D

var rot: float = 0.0
var minRot: float = 0.0
var maxRot: float = 359.0
var velocity = Vector2(0, -1)

var speed: int = 150
var turnSpeed: float = 2.0
var fastTurnSpeed: float = 3.0

var flockMates = []

###############################################################################
#The _ready() function randomizes the random seed with randomize(), then sets 
#the creatures rotation_degrees to a random value between 0.0 and 359.9.
func _ready():
	randomize()
	rot = rand_range(0.0, 359.9)
	self.rotation_degrees = rot

#The _physics_process(delta) function is ran every frame, with the delta 
#argument being equal to the time (in seconds) between the current frame and the
#last. The velocity assignments are keeping the creatures moving forward at a 
#constant speed. The three methods called are explained below.
func _physics_process(delta):
	velocity = Vector2(0, -speed).rotated(rotation)
	velocity = move_and_slide(velocity)
	
	findFlockCenter()
	avoidObstacles()
	findFlockAvgHeading()

################################################################################
#Seperation method. If the left raycast detects an object, turn right. The 
#opposite is defined by the second if statement. The if/else statement is 
#basically performing the same action, but includes a third central raycast. If 
#the third raycast is triggered, turn faster.
func avoidObstacles():
	if $RayCast2D1.is_colliding():
		self.rotation_degrees += turnSpeed
	if $RayCast2D3.is_colliding():
		self.rotation_degrees -= turnSpeed
		
	if $RayCast2D2.is_colliding():
		self.rotation_degrees += fastTurnSpeed 
	elif $RayCast2D2.is_colliding() && $RayCast2D1.is_colliding():
		self.rotation_degrees += fastTurnSpeed
	elif $RayCast2D2.is_colliding() && $RayCast2D3.is_colliding():
		self.rotation_degrees -= fastTurnSpeed

#Alignment method. Calculates the average global rotation of all creatures
#within a 300 pixel radius (set in the editor). Then, compare this value to 
#the rotation_degrees of the specific creature, and turn until matching.
func findFlockAvgHeading(): 
	var avgRot = 0
	
	for boid in flockMates:
		avgRot += boid.rotation_degrees
	
	if flockMates.size() != 0:
		avgRot = avgRot / flockMates.size()
	
	if self.rotation_degrees > avgRot:
		self.rotation_degrees -= turnSpeed
	elif self.rotation_degrees < avgRot:
		self.rotation_degrees += turnSpeed	

#Cohesion method. Similar to the above method, but calculates the average 
#position of all creatures within 300 pixels. The creatures then attempt to
#steer themselves towards. I beleive this method needs revision.
func findFlockCenter(): 
	var avgPos = Vector2()
	for boid in flockMates:
		avgPos += boid.position
	if flockMates.size() != 0:
		avgPos = avgPos / flockMates.size()
	
	if self.position.x >= avgPos.x && self.position.y >= avgPos.y:
		self.rotation_degrees -= turnSpeed
	elif self.position.x >= avgPos.x && self.position.y < avgPos.y:
		self.rotation_degrees -= turnSpeed
	elif self.position.x < avgPos.x && self.position.y >= avgPos.y:
		self.rotation_degrees += turnSpeed
	elif self.position.x < avgPos.x && self.position.y < avgPos.y:
		self.rotation_degrees += turnSpeed


###############################################################################
#The following function simply adds any creature that enters a 300 pixel radius
#to an array called flockMates. The second function removes them from the array
#when they leave the radius.
func _on_FlockDectection_body_entered(body):
	flockMates.append(body)


func _on_FlockDectection_body_exited(body):
	flockMates.remove(flockMates.bsearch(body))
