module Store

using JLD2
using Dates

export datastore, namespace, document, collection
export DataStore, Namespace, Document, Collection
export update!, edit!, set!, get

abstract type AbstractStoreNode end
abstract type AbstractStoreContainer <: AbstractStoreNode end

include("namespace.jl")

include("document.jl")

include("collection.jl")

include("datastore.jl")



end
