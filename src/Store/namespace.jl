struct Namespace <: AbstractStoreContainer
    foldername::String
end
function namespace(namespace::Namespace, name::Symbol)
    return Namespace(joinpath(namespace.foldername, string(name)) |> mkpath)
end
