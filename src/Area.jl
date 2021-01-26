"""
	voronoiarea(tess::Tessellation) -> Vector

Compute the area of all Voronoi cells in a tesselation.
"""
function voronoiarea(tess::Tessellation)
	map(polyarea, tess.Cells)
end


"""
	polyarea(p::Vector)

Compute the area of the polygon with vertices `p` using the shoelace formula.  
It is assumed that `p` is sorted.
"""
function polyarea(pts)
	n_pts = length(pts)
	A = getx(pts[1]) * (gety(pts[2]) - gety(pts[n_pts])) + getx(pts[n_pts]) * (gety(pts[1]) - gety(pts[n_pts - 1]))

	for n in 2:n_pts - 1
		A += getx(pts[n])*(gety(pts[n + 1]) - gety(pts[n - 1]))
	end

	return 0.5 * abs(A)
end

