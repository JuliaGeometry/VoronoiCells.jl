using VoronoiDelaunay
using VoronoiCells
using Winston

N = 15
x = 1.0 + rand(N)
y = 1.0 + rand(N)
tess1 = DelaunayTessellation2D{IndexablePoint2D}()
pts1 = [IndexablePoint2D(x[n], y[n], n) for n=1:N]
push!(tess1, pts1)


# ----------------------------------------------------------------------
# Plot tesselations

Vx1, Vy1 = getplotxy(VoronoiDelaunay.voronoiedges(tess1))
p1 = plot(Vx1, Vy1)

for p in pts1
	text( getx(p), gety(p), string(getindex(p)) )
end

xlim(1.0, 2.0)
ylim(1.0, 2.0)

#display(p1)
savefig("tess_corner.png")


# ----------------------------------------------------------------------
# Scaled pints

tess2 = DelaunayTessellation2D{IndexablePoint2D}()
pts2 = large2small(pts1)
push!(tess2, pts2)


# ----------------------------------------------------------------------
# Plot scaled tesselation

Vx2, Vy2 = getplotxy(VoronoiDelaunay.voronoiedges(tess2))
p2 = plot(2.0*Vx2-1.5, 2.0*Vy2-1.5, "r")

for p in pts1
	text( getx(p), gety(p), string(getindex(p)) )
end

xlim(1.0, 2.0)
ylim(1.0, 2.0)

#display(p2)
savefig("tess_nocorner.png")


# ----------------------------------------------------------------------
# Both tesselations


#oplot(Vx1, Vy1)

#display(p2)
#savefig("tess_combined.png")

