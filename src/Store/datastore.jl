const DataStore = Namespace

function datastore(path::String)
  DataStore(path |> mkpath)
end
