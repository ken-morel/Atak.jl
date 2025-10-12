# Defaults
getpriority(t::AbstractPriorityTask) = t.priority
gettime(t::AbstractPriorityTask) = t.created
run(t::AbstractPriorityTask) = t.fn()
issametask(::AbstractPriorityTask, ::AbstractPriorityTask) = false


# ReactantUpdate
struct ReactantUpdate <: AbstractPriorityTask
    created::UInt
    priority::Priority
    reactant::AbstractReactive
    fn::Function
    ReactantUpdate(fn::Function, r::AbstractReactive, p::Priority) = new(time_ns(), p, r, fn)
end

issametask(a::ReactantUpdate, b::ReactantUpdate) = a.reactant == b.reactant


# CallbackCall
struct CallbackCall <: AbstractPriorityTask
    created::UInt
    priority::Priority
    callback::Function
    fn::Function
    CallbackCall(fn::Function, cb::Function, p::Priority) = new(time_ns(), p, cb, fn)
end

issametask(a::CallbackCall, b::CallbackCall) = a.callback == b.callback

# Component update

struct ComponentUpdate <: AbstractPriorityTask
    created::UInt
    priority::Priority
    comp::Component
    fn::Function
    ComponentUpdate(fn::Function, c::Component, p::Priority) = new(time_ns(), p, c, fn)
    ComponentUpdate(c::Component, p::Priority) = new(time_ns(), p, c, () -> IonicEfus.update!(c))
end


# Simple task
struct SimpleTask <: AbstractPriorityTask
    created::UInt
    priority::Priority
    fn::Function
    SimpleTask(fn::Function, p::Priority) = new(time_ns(), p, fn)
end


issametask(a::SimpleTask, b::SimpleTask) = a.fn == b.fn
