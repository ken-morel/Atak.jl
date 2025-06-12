const Collection{T} = Document{Vector{T}};

function collection(namespace::Namespace, name::Symbol, ::Type{T}=Any) where T
  Collection{T}(joinpath(namespace.foldername, string(name) * ".jld2"))
end

r"""
function get(doc::Collection{T})::Union{Vector{T},Nothing} where T
  !ispath(doc.filename) && return nothing
  try
    jldopen(doc.filename, "r") do file
      Base.convert(Union{Vector{T},Nothing}, file["data"])
    end
  catch e
    @warn "error reading data from document $e"
    nothing
  end
end

function set!(doc::Collection{T}, value::Union{Vector{T},Nothing})::Union{Vector{T},Nothing} where T
  jldopen(doc.filename, "w") do file
    file["modified"] = now()
    file["data"] = value
  end
end

function update!(fn::Function, doc::Collection{T})::Union{Collection{T},Nothing} where T
  set!(doc, doc |> get |> fn)
end

function edit!(
  fn!::Function, doc::Collection{T}, default::Union{Vector{T},Nothing}=nothing
)::Union{Vector{T},Nothing} where T
  data = doc |> get
  if isnothing(data)
    data = default
  end
  fn!(data)
  set!(doc, data)
end
"""
