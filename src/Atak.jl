module Atak
using Efus
using Efus: EObservable
export getcurrentpage

include("application.jl")
include("router.jl")

include("Store/Store.jl")


end
