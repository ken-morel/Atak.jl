struct Document{T} <: AbstractStoreNode
  filename::String
end

function Base.get(doc::Document{T})::Union{T,Nothing} where T
  !ispath(doc.filename) && return nothing
  try
    jldopen(doc.filename, "r") do file
      Base.convert(Union{T,Nothing}, file["data"])
    end
  catch e
    @warn "error reading data from document $e"
    nothing
  end
end

function set!(doc::Document{T}, value::Union{T,Nothing})::Union{T,Nothing} where T
  jldopen(doc.filename, "w") do file
    file["modified"] = now()
    file["data"] = value
  end
end

function update!(fn::Function, doc::Document{T})::Union{T,Nothing} where T
  set!(doc, doc |> get |> fn)
end

function edit!(
  fn!::Function, doc::Document{T}, default::Union{T,Nothing}=nothing
)::Union{T,Nothing} where T
  data = doc |> get
  if isnothing(data)
    data = default
  end
  ret = fn!(data)
  set!(doc, data)
  ret
end


function document(namespace::Namespace, name::Symbol, ::Type{T}=Any) where T
  Document{T}(joinpath(namespace.foldername, string(name) * ".jld2"))
end


