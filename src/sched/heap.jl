mutable struct TaskHeap
    nodes::Vector{AbstractPriorityTask}

    TaskHeap() = new(Vector{AbstractPriorityTask}())
end

Base.isempty(h::TaskHeap) = isempty(h.nodes)
Base.length(h::TaskHeap) = length(h.nodes)
Base.contains(h::TaskHeap, v::AbstractPriorityTask) = in(v, h.nodes)

function Base.push!(h::TaskHeap, val::AbstractPriorityTask)
    for (idx, task) in enumerate(h.nodes)
        if issametask(task, val)
            h.nodes[idx] = val
            sift_up!(h, idx)
            return
        end
    end
    push!(h.nodes, val)
    return sift_up!(h, lastindex(h.nodes))
end

function Base.pop!(h::TaskHeap)
    isempty(h) && return nothing
    # Swap the root with the last element
    x = h.nodes[1]
    last = pop!(h.nodes)
    if !isempty(h)
        h.nodes[1] = last
        sift_down!(h, firstindex(h.nodes))
    end
    return x
end

function sift_up!(h::TaskHeap, i::Int)
    i == 1 && return
    parent = i >> 1
    while i > 1 && isless(h.nodes[i], h.nodes[parent])
        h.nodes[i], h.nodes[parent] = h.nodes[parent], h.nodes[i]
        i = parent
        parent = i >> 1
    end
    return
end

function sift_down!(h::TaskHeap, i::Int)
    n = length(h.nodes)
    while true
        left = i << 1
        right = left + 1
        smallest = i

        if left <= n && isless(h.nodes[left], h.nodes[smallest])
            smallest = left
        end
        if right <= n && isless(h.nodes[right], h.nodes[smallest])
            smallest = right
        end

        if smallest != i
            h.nodes[i], h.nodes[smallest] = h.nodes[smallest], h.nodes[i]
            i = smallest
        else
            break
        end
    end
    return
end
