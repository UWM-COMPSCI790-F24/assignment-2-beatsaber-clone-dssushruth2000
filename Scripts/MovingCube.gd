extends Node3D

@export var speed = 5.0  # Speed at which the cube moves
@export var color = Color.BLUE  # Default color for the cube
@export var small_block_scene: PackedScene = preload("res://Scenes/SmallBlock.tscn")
@export var number_of_pieces = 5  
@export var explosion_force = 100.0  # Force applied to the small blocks


func _ready():
    var mesh_instance = $MeshInstance3D
    
    # Randomly set color to blue or red
    var is_RED = randi() % 2 == 0
    color = Color.RED if is_RED else Color.BLUE
    
    
    if mesh_instance.material_override:
        mesh_instance.material_override.albedo_color = color
    else:
        var new_material = StandardMaterial3D.new()
        new_material.albedo_color = color
        mesh_instance.material_override = new_material

        
func _process(delta):
    global_position.z += speed * delta

    if global_position.z >= 0:
        queue_free()  # Destroy cube when it passes the player
 


func split_cube(laser_color: Color):
    if laser_color == color:
        print("Cube hit by laser sword of matching color, destroying...")

        
        play_destroy_sound()

        decompose()

        queue_free()  # Destroy the original cube after decomposing
        
    else:
        print("Cube color does not match laser color, not destroying.")



func play_destroy_sound():
    var main_node = get_tree().root.get_node("Main")
    if main_node:
        var destroy_sound_player = main_node.get_node("DestroySoundPlayer")
        if destroy_sound_player:
            if destroy_sound_player.stream:
                destroy_sound_player.play()  # Play sound effect
            else:
                print("Destroy sound player found but no stream assigned!")
        else:
            print("Destroy sound player not found in Main!")
    else:
        print("Main node not found!")



func decompose():
    print("Decomposing cube into smaller blocks...")

    
    var small_block_parent = Node3D.new()
    get_tree().root.add_child(small_block_parent)  

    for i in range(number_of_pieces):
        var small_block = small_block_scene.instantiate()
        if small_block:
            print("Instantiated small block: ", i)
            small_block_parent.add_child(small_block)  

            
            small_block.global_transform = global_transform
            small_block.global_position += Vector3(randf_range(-0.5, 0.5), randf_range(-0.5, 0.5), randf_range(-0.5, 0.5))


            
            var small_block_mesh = small_block.get_node("MeshInstance3D")
            if small_block_mesh:
                if small_block_mesh.material_override:
                    small_block_mesh.material_override.albedo_color = color
                else:
                    var new_material = StandardMaterial3D.new()
                    new_material.albedo_color = color
                    small_block_mesh.material_override = new_material

            # Apply a random explosion force to each small block
            var random_direction = Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1)).normalized()
            var force = random_direction * explosion_force

            if small_block.has_method("apply_impulse"):
                small_block.apply_impulse(Vector3.ZERO, force)
        else:
            print("Failed to instantiate small block!")



    var timer = Timer.new()
    timer.wait_time = 2.0  # Duration before the small blocks disappear
    timer.one_shot = true
    timer.connect("timeout", Callable(self, "_on_timer_timeout"))
    add_child(timer)
    timer.start()


func _on_timer_timeout():
    for child in get_children():
        if child.name.begins_with("SmallBlock"):  
            child.queue_free()
