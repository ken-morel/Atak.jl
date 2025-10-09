# Atak.jl

Welcome to atak!
Atak is a set of tools to help users of
[IonicEfus.jl](https://github.com/ken-morel/IonicEfus.jl)
and other library creators by providing them
some useful tools for creating applicaitons.

## Stores

Stores are jdl2 encoded files and folders
which store objects, or list of objects
of a specific type, they provide typed
interfaces to ensure stability and provide
easy to use methods for using them.
They are well documented enough so
you can easily use them.

```julia
store = Store("/path/to/app/dir/stores")

# Create subnamespaces
userdata = namespace(store, :user)
authdata = namespace(store, :auth)

struct User
  name::String
  password::String
end

# Optional default value. Get's type from User[]
users = collection(authdata, :users, [User("sudo", "   ")])

currentuser = document(userdata, :user, first(getvalue!(users)))

# set the value
setvalue!(currentuser, User("ama", "banana"))

# Replace with a new object
update!(currentuser) do user
  return User(user.name, "new password")
end

# alter the value in place
alter!(users) do users
  push!(users, getvalue(currentuser))
return
end
```

View [./src/store.jl](./src/store.jl) for the specific
implementation.i

## Sheduler

A scheduler, an easy to use tool for managing UI updates,
it stores internal tasks, ordered in order of priority
using a minimal implementation of a BinaryHeap.

```julia
Base.@kwdef mutable struct Scheduler
    heap::BinaryHeap{PriorityTask} = BinaryHeap{PriorityTask}()
    const lock::ReentrantLock = ReentrantLock()
    const work_signal::Threads.Condition = Threads.Condition()
    workers::Vector{Task} = []
    num_workers::Int = Threads.nthreads()
    is_running::Bool = false
end
```

A scheduler has the `schedule!(s::Scheduler, cb::Function, p::Priority = Normal)`
(with the function first variant) which stacks the function which
may be executed by any worker.

The scheduler is started via `start!` and stoped via `stop!`.

view [./src/scheduler.jl](./src/scheduler.jl)
for the specific implementation.
