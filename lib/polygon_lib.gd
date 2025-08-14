class_name PolygonLib extends Node
## A static method for generating regular polygons.


## Return the vertices of a regular polygon with [param sides] sides and radius 
## of [param radius]. Optionally offset the generated polygon by [param offset].
static func regular_polygon_vertices(sides:int, radius:float, offset:=Vector2()) -> PackedVector2Array:
	var vertices = PackedVector2Array()
	if sides > 2:
		for side in range(sides):
			var x = (sin(float(side) / sides * 2 * PI) * radius) + offset.x
			var y = (cos(float(side) / sides * 2 * PI) * radius) + offset.y
			vertices.append(Vector2(x, y))
	return vertices
