ts = DateTime(2018,01,13):Minute(1):DateTime(2018,01,14)
x = randn(length(ts))

daylight(ts,x,loc=Point(42.35,-71.05),tz=tz"EST")
