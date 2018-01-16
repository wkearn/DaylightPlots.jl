function _process_daylight(ts,p,tz)
    dts = Date(ts[1])-Day(1):Date(ts[end])+Day(1)
    rise = sunrise.(dts,p,tz)
    set = sunset.(dts,p,tz)
    rs = DateTime.(collect(Base.Iterators.flatten(zip(rise,set))))
    
    zs = zeros(length(rs))
    for i in eachindex(zs)
        zs[i] = isodd(i)?1.0:0.0
    end
    rs,zs
end

function tlims(t,x)
    ts = extrema(t)
    a,b = extrema(x)
    ts,a,b
end

@userplot Daylight

@recipe function f(dl::Daylight;loc=Point(0.0,0.0),tz=tz"UTC")
    x = dl.args
    
    ts,a,b = tlims(x...)
    
    rs,zs = _process_daylight(ts,loc,tz)

    xlims := Dates.value.(ts)
    ylims := (a,b)
    
    @series begin
        seriestype:= [:steppost :steppre]
        linecolor := :black
        linealpha := 0.0     
        fillcolor := [:yellow :grey]
        fillalpha := 0.3
        fillrange := a
        
        rs, (b-a)*[zs zs]+a
    end

    @series begin
        x
    end
end
