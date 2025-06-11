struct Namespace <: AbstractStoreContainer
  foldername::String
end

function document(namespace::Namespace, name::Symbol, ::Type{T}=Any) where T
  Document{T}(joinpath(namespace.foldername, string(name) * ".jld2"))
end

function namespace(namespace::Namespace, name::Symbol)
  Namespace(joinpath(namespace.foldername, string(name)) |> mkpath)
end

function store(path::String)
  Store(path |> mkpath)
end
