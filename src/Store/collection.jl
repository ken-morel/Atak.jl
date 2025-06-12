const Collection{T} = Document{Vector{T}};

function collection(namespace::Namespace, name::Symbol, ::Type{T}=Any) where T
  Collection{T}(joinpath(namespace.foldername, string(name) * ".jld2"))
end
