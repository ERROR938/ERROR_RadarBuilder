function GetRadarView(entity)
    local heading = GetEntityHeading(entity) + 90.0
    local headingRad = math.rad(heading)
    return vector3(math.cos(headingRad), math.sin(headingRad), 0.0)
end

function RotToDirection(rot)
    local z = math.rad(rot.z)
    local x = math.rad(rot.x)
    local num = math.abs(math.cos(x))
    return vector3(-math.sin(z) * num, math.cos(z) * num, math.sin(x))
end


function RaycastFromPoint(point, rotation, distance)
    local direction = RotToDirection(rotation)
    local destination = vector3(point.x + direction.x * distance, point.y + direction.y * distance, point.z + direction.z * distance)
    
    local rayHandle = StartShapeTestRay(point.x, point.y, point.z, destination.x, destination.y, destination.z, 10, -1, 0)
    local _, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(rayHandle)
    
    return hit, endCoords, surfaceNormal, entityHit
end