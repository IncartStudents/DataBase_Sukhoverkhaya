using SQLite
using DataFrames

function FiltBy(db, tag::String, subject::String, creation_date::String)
    
    fullpath = []
    
    record_id = DBInterface.execute(db, 
        "SELECT ID 
        FROM Records 
        WHERE 
            CASE
                WHEN NOT '$tag' = ''
                THEN EXISTS (SELECT *
                            FROM TagsMap 
                            WHERE tag_id = (SELECT ID
                                            FROM Tags 
                                            WHERE tag_name = '$tag')
                            AND record_id = Records.ID)
                ELSE EXISTS (SELECT * FROM Records)
            END
        AND 
            CASE
                WHEN NOT '$subject' = ''
                THEN EXISTS (SELECT *
                            FROM SubjectsMap
                            WHERE subject_id = (SELECT ID
                                               FROM Subjects
                                               WHERE subject_name = '$subject')
                            AND record_id = Records.ID)
                ELSE EXISTS (SELECT * FROM Records)
            END
        AND
            CASE 
                WHEN NOT '$creation_date' = ''
                THEN creation_date = '$creation_date'
                ELSE EXISTS (SELECT * FROM Records)
            END") |> DataFrame;         

    if size(record_id)[1] != 0
        f_id = Vector(Matrix(record_id)[:,1])
        for i in 1:lastindex(f_id)
            f0_id = f_id[i]
            p_id = DBInterface.execute(db, "SELECT path_id FROM PathsMap WHERE record_id = '$f0_id'") |> DataFrame;
            if size(p_id)[1] != 0
                p_id = p_id[1,1]

                p_name = (DBInterface.execute(db, "SELECT path_name FROM Paths WHERE ID = '$p_id'") |> DataFrame)[1,1]
                f_name = (DBInterface.execute(db, "SELECT recordname FROM Records WHERE ID = '$f0_id'") |> DataFrame)[1,1]

                full_path = p_name*"/"*f_name
                push!(fullpath, full_path)
            end
        end
    end

    
    return fullpath
end
#--------------------------------------------------------------------------

# путь к базе
db = SQLite.DB("configs/DBTData.sqlite")

rtag = "хорошая запись"
rsubject = "Катя"
rdate = ""

fullpath = FiltBy(db, rtag, rsubject, rdate)