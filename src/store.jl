export store, namespace, document, collection
export Store, Namespace, Document, Collection
export update!, alter!, set!

abstract type AbstractStoreNode end
abstract type AbstractStoreContainer <: AbstractStoreNode end


"""
    struct Namespace <: AbstractStoreContainer

A store namespace physically represents a directory,
it is a container for other store nodes.
You can create one using [`namespace`](@ref).
"""
struct Namespace <: AbstractStoreContainer
    foldername::String
end
"""
    namespace(namespace::Namespace, name::Symbol)

Create a subnamespace of the specified namespace,
or store. To have a toplevel namespace, use 
a [`Store`](@ref) instead.
This function creates a subdirectory called `name`
in the namespace's directory.
"""
function namespace(namespace::Namespace, name::Symbol)
    return Namespace(joinpath(namespace.foldername, string(name)) |> mkpath)
end

"""
    struct Document{T} <: AbstractStoreNode

A document stores an object of type T,
documents use JDL2 encoding and decoding
for fast read access times, but do
not cache the read data, they just act as
an interface, so avoid multiple read 
and writes to the same file.

See also [`Collection`](@ref).
"""
struct Document{T} <: AbstractStoreNode
    filename::String
end

"""
    document(namespace::Namespace, name::Symbol, value::T, type::Type{T})
    document(nmsp::Namespace, name::Symbol, value::T)

Create a document file storing values of type T with default value `value`.
"""
function document(namespace::Namespace, name::Symbol, ::Type{T}, value) where {T}
    doc = Document{T}(joinpath(namespace.foldername, string(name) * ".jld2"))
    setvalue!(doc, value)
    return doc
end
document(
    namespace::Namespace, name::Symbol, value::T,
) where {T} = document(namespace, name, T, value)

"""
    IonicEfus.getvalue(doc::Document{T})::T

Read the data stored in the document file.
Does not handle errors reading the file,
so it is adviced to wrap them in try-catch blocks.
"""
function IonicEfus.getvalue(doc::Document{T})::T where {T}
    return jldopen(doc.filename, "r") do data
        data["data"]
    end
end

"""
    IonicEfus.setvalue!(doc::Document{T}, value)::T

writes value to the document, uses convert(T) to 
ensure `value` is of the right type.
"""
function IonicEfus.setvalue!(doc::Document{T}, value)::T where {T}
    return jldopen(doc.filename, "w") do data
        data["modified"] = now()
        data["data"] = convert(T, value)
    end
end

"""
    update!(doc::Document{T}, fn::Function)::T
    update!(fn::Function, doc::Document{T})::T

Updates the value stored in the document
using the function, the function receives the
current value and returns the new value, 
the getting and setting are done seperately,
so the function can last as long as desired
without leaving an open file.

This function differes in [`alter!`](@ref)
in that the callback returns a value.

The function returns the new value returned 
by the callback.
"""
function update!(doc::Document{T}, fn::Function)::T where {T}
    return setvalue!(doc, getvalue(doc) |> fn)
end

update!(fn::Function, doc::Document{T}) where {T} = update!(doc, fn)

"""
    alter!(fn!::Function, doc::Document{T})::Any

Modify the value stored in the document
by modifying directly the object, an alter!
call expects the function to modify it's
argument directly, and returns the returned
value by the function.

See also [`update!`](@ref).
"""
function alter!(
        fn!::Function, doc::Document{T}
    ) where {T}
    data = doc |> getvalue
    ret = fn!(data)
    setvalue!(doc, data)
    return ret
end


"""
    const Collection{T} = Document{Vector{T}}

A collection is a document storing
a vector of objects of type T.
"""
const Collection{T} = Document{Vector{T}}

"""
    collection(namespace::Namespace, name::Symbol, ::Type{T}, default = T[])
    collection(namespace::Namespace, name::Symbol, default::Vector{T})

Create a new collection in namespace or store, the collection stores
objects of type t and with an optional default value.
"""
function collection(namespace::Namespace, name::Symbol, ::Type{T}, default = T[]) where {T}
    col = Collection{T}(joinpath(namespace.foldername, string(name) * ".jld2"))
    try
        getvalue(col)
    catch
        setvalue!(col, default)
    end
    return col
end
collection(
    namespace::Namespace, name::Symbol, default::Vector{T},
) where {T} = collection(namespace, name, T, default)

"""
    const Store = Namespace

A store is a top level namespace, inwhich other
nodes can be created, you can create a store
using [`store`](@ref).
"""
const Store = Namespace

"""
    store(path::String)::Store

Create a new store in folder `path`.
The folder and it's parents are
created if they don't exist.
"""
function store(path::String)::Store
    return Store(path |> mkpath)
end
