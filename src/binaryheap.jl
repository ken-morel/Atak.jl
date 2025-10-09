public BinaryHeap

"""
    mutable struct BinaryHeap{T}

A minimal BinaryHeap implementation
"""
mutable struct BinaryHeap{T}
    nodes::Vector{T}
    counter::UInt64 # Used to assign unique IDs to tasks for FIFO tie-breaking

    BinaryHeap{T}() where {T} = new{T}(Vector{T}(), 0)
end

Base.isempty(h::BinaryHeap) = isempty(h.nodes)
Base.length(h::BinaryHeap) = length(h.nodes)

function Base.push!(h::BinaryHeap{T}, val::T) where {T}
    push!(h.nodes, val)
    return sift_up!(h, length(h.nodes))
end

function Base.pop!(h::BinaryHeap)
    isempty(h) && return nothing
    # Swap the root with the last element
    x = h.nodes[1]
    last = pop!(h.nodes)
    if !isempty(h)
        h.nodes[1] = last
        sift_down!(h, 1)
    end
    return x
end

function sift_up!(h::BinaryHeap, i::Int)
    i == 1 && return
    parent = i >> 1
    while i > 1 && isless(h.nodes[i], h.nodes[parent])
        h.nodes[i], h.nodes[parent] = h.nodes[parent], h.nodes[i]
        i = parent
        parent = i >> 1
    end
    return
end

function sift_down!(h::BinaryHeap, i::Int)
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
