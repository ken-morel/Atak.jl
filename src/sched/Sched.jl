module Sched
using Efus

abstract type AbstractPriorityTask end

include("./task.jl")

include("./heap.jl")
include("./tasktemplates.jl")
include("./scheduler.jl")


export Scheduler, schedule!, start!, stop!

end
