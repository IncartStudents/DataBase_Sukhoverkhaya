using SQLite
using DataFrames

function FiltBy(db, tag::String, sig::String, author::String, creation_date::String)
    
    fullpath = []
    
    file_id = DBInterface.execute(db, 
        "SELECT ID 
        FROM Files 
        WHERE 
            CASE
                WHEN NOT '$tag' = ''
                THEN EXISTS (SELECT *
                            FROM TagsMap 
                            WHERE tag_id = (SELECT ID
                                            FROM Tags 
                                            WHERE tag_name = '$tag')
                            AND file_id = Files.ID)
                ELSE EXISTS (SELECT * FROM Files)
            END
        AND 
            CASE
                WHEN NOT '$author' = ''
                THEN EXISTS (SELECT *
                            FROM AuthorsMap
                            WHERE author_id = (SELECT ID
                                               FROM Authors
                                               WHERE author_name = '$author')
                            AND file_id = Files.ID)
                ELSE EXISTS (SELECT * FROM Files)
            END
        AND
            CASE
                WHEN NOT '$sig' = ''
                THEN EXISTS (SELECT *
                            FROM SignalsMap
                            WHERE signal_id = (SELECT ID
                                               FROM Signals
                                               WHERE signal_name = '$sig')
                            AND file_id = Files.ID)
                ELSE EXISTS (SELECT * FROM Files)
            END
        AND
            CASE 
                WHEN NOT '$creation_date' = ''
                THEN creation_date = '$creation_date'
                ELSE EXISTS (SELECT * FROM Files)
            END") |> DataFrame;         

    if size(file_id)[1] != 0
        f_id = Vector(Matrix(file_id)[:,1])
        for i in 1:lastindex(f_id)
            f0_id = f_id[i]
            p_id = DBInterface.execute(db, "SELECT path_id FROM PathsMap WHERE file_id = '$f0_id'") |> DataFrame;
            if size(p_id)[1] != 0
                p_id = p_id[1,1]

                p_name = (DBInterface.execute(db, "SELECT path_name FROM Paths WHERE ID = '$p_id'") |> DataFrame)[1,1]
                f_name = (DBInterface.execute(db, "SELECT filename FROM Files WHERE ID = '$f0_id'") |> DataFrame)[1,1]

                if sig == ""
                    s_id = DBInterface.execute(db, "SELECT signal_id FROM SignalsMap WHERE file_id = '$f0_id'") |> DataFrame;
                    if size(s_id)[1] != 0
                        s_id = Vector(Matrix(s_id)[:,1])
                        for j in 1:lastindex(s_id)
                            s0_id = s_id[j]
                            s_name = (DBInterface.execute(db, "SELECT signal_name FROM Signals WHERE ID = '$s0_id'") |> DataFrame)[1,1]
                            full_path = p_name*"/"*f_name*"/"*s_name
                            push!(fullpath, full_path)
                        end
                    end
                else
                    full_path = p_name*"/"*f_name*"/"*sig
                    push!(fullpath, full_path)
                end
            end
        end
    end

    
    return fullpath
end
#--------------------------------------------------------------------------

# путь к базе
db = SQLite.DB("configs/DBTData_allfiles.sqlite")

rtag = "хорошая запись"
rsig = "reo"
rauthor = ""
rdate = ""

fullpath = FiltBy(db, rtag, rsig, rauthor, rdate)