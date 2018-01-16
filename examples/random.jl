# This script will generate a plot similar to random.png

using DaylightPlots

t = DateTime(2018,01,01):Minute(1):DateTime(2018,01,02)

x = randn(length(t))

daylight(t,x,loc=Point(42.35,-71.05),tz=tz"America/New_York",color=:black,leg=false,grid=false)

