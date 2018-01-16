# This script shows how one might generate a daylight plot
# for a custom time series time using the Quantity type found
# in my TidalFluxQuantities package
using TidalFluxQuantities, ADCPDataProcessing, PIEMetData, TidalFluxExampleData, DaylightPlots, TidalFluxPlots, Plots

pyplot()

# This stuff is all just loading and processing some
# example tidal data

setADCPdatadir!(Pkg.dir("TidalFluxExampleData","data","adcp"))
setmetdatadir!(Pkg.dir("TidalFluxExampleData","data","met"))

creek = Creek{:sweeney}()
deps = parse_deps(creek)
adata = load_data.(deps)

cs = parse_cs(creek)
csd = load_data(cs)
M = ADCPDataProcessing.depth_mask(adata[1])
H = atmoscorrect(adata[1])

# Here we define tlims. We use the argument `x...` to catch
# any additional arguments that might be passed to `daylight`,
# such as the depth masks that we use in ADCPDataProcessing
# to get rid of invalid data

DaylightPlots.tlims(q::Quantity,x...) = DaylightPlots.tlims(TidalFluxQuantities.times(q),quantity(q))

# Here we make our plot. `H::Stage` and `M::Mask` have
# recipes defined in TidalFluxPlots for plotting. Along
# with our definition of `tlims` above, this allows us
# to make daylight plots with our quantities.

daylight(H,M,loc=Point(42.35,-71.05),tz=tz"America/New_York",color=:black,leg=false,grid=false)

savefig("tides.png")
