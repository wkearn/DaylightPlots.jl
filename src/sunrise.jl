export sunrise, sunset

include("points.jl")

# The built-in deg2rad, rad2deg functions do
# weird things when z is very large
deg2radDP(z) = z * pi/180
rad2degDP(z) = z * 180/pi

isdaylight(dt::DateTime,p::Point,tz::TimeZone) = DateTime(sunrise(Date(dt),p,tz)) <= dt < DateTime(sunset(Date(dt),p,tz))

sunrise(d::Date,p::Point,tz::TimeZone) = calcSunriseSet(true,d,latitude(p),longitude(p),tz)
sunset(d::Date,p::Point,tz::TimeZone) = calcSunriseSet(false,d,latitude(p),longitude(p),tz)    

function calcSunriseSet(rise,d::Date,latitude,longitude,tz)
    calcSunriseSet(rise,datetime2julian(DateTime(d)),latitude,longitude,tz)
end

function calcSunriseSet(rise,JD,latitude,longitude,tz)
    timeUTC = calcSunriseSetUTC(rise,JD,latitude,longitude)
    newtimeUTC = calcSunriseSetUTC(rise,JD+timeUTC/1440.0,latitude,longitude)
    dt = ZonedDateTime(julian2datetime(JD+newtimeUTC/1440.0),tz"UTC")
    astimezone(dt,tz)
end


function calcSunriseSetUTC(rise,JD,latitude,longitude)
    t = calcTimeJulianCent(JD)
    eqTime = calcEquationOfTime(t)
    solarDec = calcSunDeclination(t)
    hourAngle = calcHourAngleSunrise(latitude,solarDec)
    if !rise
        hourAngle *= -1
    end
    delta = longitude + rad2degDP(hourAngle)
    720  - (4.0 * delta) - eqTime
end

calcTimeJulianCent(jd) = (jd - 2451545.0)/36525.0

function calcEquationOfTime(t)
  epsilon = calcObliquityCorrection(t)
  l0 = calcGeomMeanLongSun(t)
  e = calcEccentricityEarthOrbit(t)
  m = calcGeomMeanAnomalySun(t)

  y = tan(deg2radDP(epsilon)/2.0);
  y *= y;

  sin2l0 = sin(2.0 * deg2radDP(l0))
  sinm   = sin(deg2radDP(m))
  cos2l0 = cos(2.0 * deg2radDP(l0))
  sin4l0 = sin(4.0 * deg2radDP(l0))
  sin2m  = sin(2.0 * deg2radDP(m))

  Etime = y * sin2l0 - 2.0 * e * sinm + 4.0 * e * y * sinm * cos2l0 - 0.5 * y * y * sin4l0 - 1.25 * e * e * sin2m
  rad2degDP(Etime)*4.0
end

function calcSunDeclination(t)
  e = calcObliquityCorrection(t)
  lambda = calcSunApparentLong(t)
    
  sint = sin(deg2radDP(e)) * sin(deg2radDP(lambda))
  rad2degDP(asin(sint))
end

function calcObliquityCorrection(t)
  e0 = calcMeanObliquityOfEcliptic(t)
  omega = 125.04 - 1934.136 * t
  e0 + 0.00256 * cosd(omega)
end

function calcGeomMeanLongSun(t)
  L0 = 280.46646 + t * (36000.76983 + t*(0.0003032))

  while L0 > 360.0
    L0 -= 360.0
  end

  while L0 < 0.0
    L0 += 360.0
  end

  L0	
end

calcEccentricityEarthOrbit(t) = 0.016708634 - t * (0.000042037 + 0.0000001267 * t)

calcGeomMeanAnomalySun(t) = 357.52911 + t * (35999.05029 - 0.0001537 * t)

function calcSunApparentLong(t)
  o = calcSunTrueLong(t)
  omega = 125.04 - 1934.136 * t
  o - 0.00569 - 0.00478 * sind(omega)
end

function calcMeanObliquityOfEcliptic(t)
  seconds = 21.448 - t*(46.8150 + t*(0.00059 - t*(0.001813)))
  23.0 + (26.0 + (seconds/60.0))/60.0
end

function calcSunTrueLong(t)
  l0 = calcGeomMeanLongSun(t)
  c = calcSunEqOfCenter(t)
  l0 + c
end

function calcSunEqOfCenter(t)
  m = calcGeomMeanAnomalySun(t)
  mrad = deg2radDP(m)
  sinm = sin(mrad)
  sin2m = sin(2mrad)
  sin3m = sin(3mrad)
  C = sinm * (1.914602 - t * (0.004817 + 0.000014 * t)) + sin2m * (0.019993 - 0.000101 * t) + sin3m * 0.000289
end

function calcHourAngleSunrise(latitude,dec)
    latRad = deg2radDP(latitude)
    sdRad  = deg2radDP(dec)
    HAarg = (cos(deg2radDP(90.833))/(cos(latRad)*cos(sdRad))-tan(latRad) * tan(sdRad))
    HA = acos(HAarg)
end
