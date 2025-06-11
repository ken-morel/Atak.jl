module Store

using JLD2
using Dates

export store, namespace, document, Store, Namespace, Document

abstract type AbstractStoreNode end
abstract type AbstractStoreContainer <: AbstractStoreNode end

include("document.jl")
include("namespace.jl")

const Store = Namespace;

end
