using CSV, DataFrames

DP = DaylightPlots

lat = 42.716667
long = -70.866667
p = Point(lat,long)
tz = tz"EST" # USNO data are given in EST

df = CSV.read(Pkg.dir("DaylightPlots","test","rowley2018.csv"),types=[DateTime,DateTime],dateformat=DateFormat("yyyy-mm-ddTHH:MM"))

df[:RiseTZ] = ZonedDateTime.(df[:Rise],tz)
df[:SetTZ]  = ZonedDateTime.(df[:Set] ,tz)

ts = Date.(df[:Rise])

sr = [sunrise(t,p,tz) for t in ts]
ss = [sunset(t,p,tz) for t in ts]

@testset "Sunrise/Sunset calculation" begin
    @test all(x->x<Minute(1),abs.(df[:RiseTZ]-sr))
    @test all(x->x<Minute(1),abs.(df[:SetTZ] -ss))
end
