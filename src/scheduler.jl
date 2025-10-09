export Scheduler, schedule!, start!, stop!, Priority


"""
    @enum Priority begin
        UserInteractive = 1
        High = 2
        Normal = 3
        Low = 4
    end

Represents the priority of a scheduler
task.
"""
@enum Priority begin
    UserInteractive = 1
    High = 2
    Normal = 3
    Low = 4
end

struct PriorityTask
    callback::Function
    priority::Priority
    id::UInt64
end

Base.isless(a::PriorityTask, b::PriorityTask) =
    (a.priority < b.priority) || (a.priority == b.priority && a.id < b.id)

"""
    Base.@kwdef mutable struct Scheduler

Atak.jl task scheduler, built
to help shedule and manage ui updates
and callback calls.

The scheduler stores a heap of tasks ordered by
priority, which it calls as they arrived
in a specified number of asynchronious worker tasks,
defaulting to `Threads.nthreads()`.
"""
Base.@kwdef mutable struct Scheduler
    heap::BinaryHeap{PriorityTask} = BinaryHeap{PriorityTask}()
    const lock::ReentrantLock = ReentrantLock()
    const work_signal::Threads.Condition = Threads.Condition()
    workers::Vector{Task} = []
    num_workers::Int = Threads.nthreads()
    is_running::Bool = false
end

"""
    schedule!(s::Scheduler, cb::Function, p::Priority = Normal)
    schedule!(cb::Function, s::Scheduler, p::Priority = Normal)

Schedule function `cb` with Priority `p` on the scheduler instance.

See also [`Scheduler`](@ref), [`Priority`](@ref).
"""
function schedule!(s::Scheduler, cb::Function, p::Priority = Normal)
    return @lock s.lock begin
        s.heap.counter += 1
        task = PriorityTask(cb, p, s.heap.counter)
        push!(s.heap, task)
        Threads.notify(s.work_signal)
    end
end
schedule!(cb::Function, s::Scheduler, p::Priority = Normal) = schedule!(s, cb, p)

"""
    start!(s::Scheduler)

Start the scheduler tasks on different 
threads.
"""
function start!(s::Scheduler)
    return @lock s.lock begin
        if s.is_running
            return
        end
        s.is_running = true
        for _ in 1:s.num_workers
            task = Threads.@spawn worker_loop(s)
            push!(s.workers, task)
        end
    end
end

"""
    stop!(s::Scheduler)

Stop the scheduler tasks, does not
return until they all stoped.
"""
function stop!(s::Scheduler)
    @lock s.lock begin
        if !s.is_running
            return
        end
        s.is_running = false
        Threads.notify(s.work_signal; all = true)
    end
    foreach(wait, s.workers)
    return empty!(s.workers)
end

function worker_loop(s::Scheduler)
    while @lock s.lock s.is_running
        task = @lock s.lock begin
            while isempty(s.heap) && s.is_running
                Threads.wait(s.work_signal)
            end
            s.is_running ? pop!(s.heap) : nothing
        end

        if !isnothing(task)
            try
                task.callback()
            catch e
                Base.printstyled(stderr, "Error in scheduled task:\n"; color = :red, bold = true)
                Base.showerror(stderr, e, catch_backtrace())
                println(stderr)
            end
        end
    end
    return
end
