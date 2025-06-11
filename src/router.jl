abstract type AbstractRouterPage end
abstract type AbstractPageBuilder{T<:AbstractRouterPage} end
const BuilderOrPage{T} = Union{AbstractPageBuilder{T},T}
abstract type AbstractRouter{T<:AbstractRouterPage} end


mutable struct Router{T} <: AbstractRouter{T}
  observable::EObservable
  pagestack::Vector{T}
  home::Union{T,Nothing}
  Router{T}() where T = new{T}(EObservable(), T[], nothing)
  Router{T}(home::Union{T,Nothing}) where T = new{T}(EObservable(), T[], home)
end


function Base.push!(
  r::Router{T}, page::T;
  replace::Bool=false, clear::Bool=false,
)::T where T
  clear && empty!(r)
  replace && length(r.pagestack) > 0 && pop!(r)
  push!(r.pagestack, page)
  println("pagestacked push")
  errormonitor(@async Efus.notify(r))
  page
end

function Base.pop!(r::Router{T})::Union{T,Nothing} where T
  length(r.pagestack) == 0 && return nothing
  poped = pop!(r.pagestack)
  errormonitor(@async Efus.notify(r))
  poped
end
empty!(r::Router) = empty!(r.pagestack)

function getcurrentpage(r::Router{T})::T where T
  current = if isempty(r.pagestack)
    r.home
  else
    last(r.pagestack)
  end
  current
end


@redirectobservablemethods r::Router r.observable
