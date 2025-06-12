struct Namespace <: AbstractStoreContainer
  foldername::String
end
function namespace(namespace::Namespace, name::Symbol)
  Namespace(joinpath(namespace.foldername, string(name)) |> mkpath)
end


