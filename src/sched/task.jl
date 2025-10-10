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
    BackgroundTask = 5
end

Base.isless(a::AbstractPriorityTask, b::AbstractPriorityTask) =
    (getpriority(a) < getpriority(b)) || (getpriority(a) < getpriority(b)  && gettime(a) < gettime(b))
