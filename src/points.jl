export Point

struct Point
    latitude
    longitude
end

latitude(p::Point) = p.latitude
longitude(p::Point) = p.longitude
