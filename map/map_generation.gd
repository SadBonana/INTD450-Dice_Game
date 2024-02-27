extends Node

#https://github.com/VladoCC/Map-Generator-Godot-Tutorial/blob/master/MapGenerator.gd

#func generate will generate a randomized map Slay the Spire style
# takes input: plane_len  - length of the plane
#              point_count - number of nodes for the map
#              path_count - number of paths for the map
func generate(plane_len,point_count, path_count):
	#randomize to ensure the map is different each time
	randomize()
	
	#initializing and populating our points variable
	#this will be used to populate a grid with points randomly
	var points = []
	points.append(Vector2(0,plane_len/2))
	points.append(Vector2(plane_len,plane_len/2))
	
	#center of the grid
	var center = Vector2(plane_len / 2, plane_len / 2)
	
	var loop = true #meaningless id for loop populating grid
	
	#generating points:
	for i in range(point_count):
		while loop == true:
			var point = Vector2(randi() % plane_len, randi() % plane_len)
			
			var dist_from_center = (point - center).length_squared()
			
			#only accepts points from inside a circle (we can also do a square if we want
			var in_circle = dist_from_center <= plane_len * plane_len / 4 
			#not sure where 4 is coming from but I assume radius
			
			if not points.has(point) and in_circle:
				points.append(point)
				loop = false
	
	#now have grid with points populating inside of a circle
	#connecting all points:
	var connected_points = PackedVector2Array(points) #connect all points w/o intersecting edges
	var triangulated = Geometry2D.triangulate_delaunay(connected_points) #triangulate
	
	#finding paths:
	var astar = AStar2D.new()
	for i in range(points.size()):
		astar.add_point(i,points[i]) #putting all points inside our astar object
		
	for j in range(triangulated.size() / 3): #not sure why divide by 3
		var p1 = triangulated[j*3]           #assuming that these are vertices of the triangles
		var p2 = triangulated[j*3 + 1]
		var p3 = triangulated[j*3 + 2]
		
		#connecting the points if they are unconnected
		if not astar.are_points_connected(p1,p2): 
			astar.connect_points(p1,p2)
		if not astar.are_points_connected(p2,p3):
			astar.connect_points(p2,p3)
		if not astar.are_points_connected(p1,p3):
			astar.connect_points(p1,p3)
			
			
	#Generating paths/deleting excess points
	var paths = []
	
	#for i in range(path_count):
	var count = path_count
	var id_path = astar.get_id_path(0,1)
	while count > 0 && id_path.size() != 0:
		id_path = astar.get_id_path(0,1)
		
		paths.append(id_path)
		
		for k in range(randi() % 2 + 1):
			# index between 1 and id_path.size() - 2 (inclusive)
			var index = randi() % (id_path.size() - 2) + 1
			
			var id = id_path[index]
			astar.set_point_disabled(id)
			
	var data = preload("res://map/map_test/MapData.gd").new()
	data.set_paths(paths, points)
	return data
		
			
		
		
	
