extends Node2D

##########################
#Author: Scott Retford Jr
#Last Revision: 10/19/2020
##########################

#Preloading the creatures for instantiation
const CREATURE = preload("res://Creature.tscn")

#Number of creatures to spawn
var spawnNum: int = 60

#Border values, to eliminate magic numbers
var minCoord: int = 0
var maxXCoord: int = 800
var maxYCoord: int = 600

#Timer value between deleting the creatures and restarting the app
var timerValue: float = 1.5

###############################################################################
#_ready() functions are called once when the scene is loaded
func _ready():
	#randomize() generates a random seed with which all random functions are 
	#rooted. Without randomize(), any random numbers generated will be the same 
	#each time the program is run.
	randomize()
	
	#Instatiating creatures based on the above variable.
	for i in spawnNum:
		var bird = CREATURE.instance()
		$Creatures.add_child(bird)
		bird.position = Vector2(rand_range(minCoord, maxXCoord), 
								rand_range(minCoord, maxYCoord))


###############################################################################
#The functions below are signals connected to nodes I've placed in the scene
#via the GUI editor built into Godot. The borders are 2D areas that notice when
#a collidable body (the creature) enters and transports it to the opposite side
#to keep the creatures on screen. Note: the y-axis is reversed from a typical
#Cartesian coordinate system, as is typical in programming.

func _on_RightBorder_body_entered(body):
	body.position.x = maxXCoord


func _on_LeftBorder_body_entered(body):
	body.position.x = minCoord


func _on_TopBorder_body_entered(body):
	body.position.y = maxYCoord


func _on_BottomBorder_body_entered(body):
	body.position.y = minCoord

#This final function deletes all creatures from the screen when pressed. It then
#waits for however many seconds are specified in the timerValue variable at the 
#top of the script.
func _on_Button_pressed():
	for boid in $Creatures.get_children():
		boid.free()
	yield(get_tree().create_timer(timerValue), "timeout")
	get_tree().change_scene("res://Main.tscn")
