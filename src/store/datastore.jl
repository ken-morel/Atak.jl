const DataStore = Namespace

function datastore(path::String)
    return DataStore(path |> mkpath)
end
