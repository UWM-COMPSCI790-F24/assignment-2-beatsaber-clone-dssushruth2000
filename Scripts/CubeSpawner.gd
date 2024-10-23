extends Node3D

@export var spawn_time_range = Vector2(0.5, 2.0)  # Random spawn delay
@export var cube_scene = preload("res://Scenes/MovingCube.tscn")  



func _ready():
    _spawn_cube()

func _spawn_cube() -> void:
    #print("Spawning cube...")
    var cube_instance = cube_scene.instantiate()
    
    
    add_child(cube_instance)
    
    cube_instance.global_position = Vector3(randf_range(-1, 1), randf_range(-1, 1), -10)  
    

    var random_time = randf_range(spawn_time_range.x, spawn_time_range.y)  
    await get_tree().create_timer(random_time).timeout
    _spawn_cube()  # Spawn another cube after the delay
