# module DeleteFromDB
    using SQLite
    using DataFrames

    using JSONTable

    db = SQLite.DB("configs/DBTData.sqlite")

    name = "WD001020822163737"
    tag = "хорошая запись"
    ancestor = "Проба с ГД"
    DBInterface.execute(db, "DELETE FROM Records WHERE recordname = '$name'")
    DBInterface.execute(db, "DELETE FROM Tags WHERE tag_name = '$tag'")

    ancestor_id = (DBInterface.execute(db, "SELECT ID FROM Tags WHERE tag_name = '$ancestor'") |> DataFrame)[1,1]
    DBInterface.execute(db, "DELETE FROM Tags WHERE tag_name = '$ancestor'")
    DBInterface.execute(db, "DELETE FROM Tags WHERE ID = '$ancestor_id'")

# end

data = DBInterface.execute(db, "SELECT recordname, creation_date FROM Records") |> DataFrame
js = DBInterface.execute(db, "SELECT recordname, creation_date FROM Records") |> Dict

