struct Foo
    t::Vector{DateTime}
    x::Vector{Float64}
end

ts = DateTime(2018,01,13):Minute(1):DateTime(2018,01,14)
x = randn(length(ts))

f = Foo(ts,x)

DaylightPlots.tlims(f::Foo) = DaylightPlots.tlims(f.t,f.x)

@recipe f(f::Foo) = (f.t,f.x)

daylight(f)
