extends XRController3D

@export var sword_color = Color.BLUE  # Set the sword color for this script



func _ready() -> void:
    pass 



func _process(delta: float) -> void:
    var start = global_position +  (-global_basis.z * 0.1)
    var end = (-global_basis.z * 5) + start
    
    $"LeftLaserSword".points[0] = start
    $"LeftLaserSword".points[1] = end
    
   
    var raycast = $"LeftLaserSword/LeftSwordRayCast3D"
    raycast.target_position = raycast.to_local(end)
    
    
    if raycast.enabled and is_instance_valid(raycast) and raycast.is_colliding():
        var collider = raycast.get_collider()
        if collider and collider.get_parent() != null: 
            #print("Left sword hit: ", collider.name)
            $"LeftLaserSword".points[1] = raycast.get_collision_point()  # Update sword endpoint to collision point

            # Check if the collider's parent node has the "split_cube" function
            if collider.get_parent().has_method("split_cube"):
                collider.get_parent().call("split_cube", sword_color)  # Passing sword color to the split_cube method
    
