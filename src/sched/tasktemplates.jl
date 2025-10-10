struct ReactantUpdate
    created::UInt
    priority::Priority
    reactant::Reactant
    fn::Function
    ReactantUpdate(fn::Function, r::Reactant, p::Priority) = new(time_ns(), p, r, fn)
end

getpriority(t::ReactantUpdate) = t.priority
gettime(t::ReactantUpdate) = t.created

issametask(a::ReactantUpdate, b::ReactantUpdate) = a.reactant == b.reactant

struct CallbackCall
    created::UInt
    priority::Priority
    callback::Function
    fn::Function
    CallbackCall(fn::Function, cb::Function, p::Priority) = new(time_ns(), p, cb, fn)
end

getpriority(t::CallbackCall) = t.priority
gettime(t::CallbackCall) = t.created

issametask(a::CallbackCall, b::CallbackCall) = a.callback == b.callback

"""
    issametask(::AbstractPriorityTask, ::AbstractPriorityTask) = false

Default issametask definition.
"""
issametask(::AbstractPriorityTask, ::AbstractPriorityTask) = false
