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
    heap::TaskHeap = TaskHeap()
    const lock::ReentrantLock = ReentrantLock()
    const work_signal::Threads.Condition = Threads.Condition()
    workers::Vector{Task} = []
    num_workers::Int = Threads.nthreads()
    is_running::Bool = false
end

"""
    schedule!(s::Scheduler, task::AbstractPriorityTask)

Schedule the task.

See also [`Scheduler`](@ref), [`Priority`](@ref).
"""
function schedule!(s::Scheduler, task::AbstractPriorityTask)
    @lock s.lock begin
        if !contains(s.heap, task)
            push!(s.heap, task)
        end
    end
    @lock s.work_signal Threads.notify(s.work_signal)
    return
end
schedule!(fn::Function, s::Scheduler, p::Priority = Normal) = schedule!(s, SimpleTask(fn, p))


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
    end
    @lock s.work_signal Threads.notify(s.work_signal; all = true)

    foreach(wait, s.workers)
    empty!(s.workers)
    return
end

function worker_loop(s::Scheduler)
    try
        while true # Loop until we are told to stop
            # The while loop and wait() must be inside the same lock block.
            while @lock s.lock isempty(s.heap) && s.is_running
                @lock s.work_signal Threads.wait(s.work_signal)
            end
            task = @lock s.lock begin
                # If we woke up but are no longer running, exit the outer loop.
                if !s.is_running
                    return
                end

                # We are guaranteed to have a task here if we are running.
                pop!(s.heap)
            end

            # The callback is correctly called outside the lock.
            try
                run(task)
            catch e
                Base.printstyled(stderr, "Error in scheduled task:\n"; color = :red, bold = true)
                Base.showerror(stderr, e, catch_backtrace())
                println(stderr)
            end
        end
    catch e
        Base.printstyled(stderr, "Error in sheduler worker:\n"; color = :red, bold = true)
        Base.showerror(stderr, e, catch_backtrace())
        println(stderr)
    end
    return
end
