using SQLite
using DataFrames

function FiltBy(db; kwargs...)

    kwargs = Dict(kwargs)
    if haskey(kwargs, :tag) tag = kwargs[:tag] else tag = "" end
    if haskey(kwargs, :subject) subject = kwargs[:subject] else subject = "" end
    if haskey(kwargs, :creation_date) creation_date = kwargs[:creation_date] else creation_date = "" end
    
    fullpath = []

    if length(kwargs) == 0
        return fullpath
    else
        if tag != "" && typeof(tag) == String
            tag_id = (DBInterface.execute(db, "SELECT ID FROM Tags WHERE tag_name = '$tag'") |> DataFrame)[1,1]
        elseif tag != "" && typeof(tag) == Vector{String}
            if length(tag) == 2
                ancestor = tag[1]
                tag_name = tag[2]
                ancestor_id =  DBInterface.execute(db, "SELECT ID FROM Tags WHERE tag_name = '$ancestor'") |> DataFrame
                if size(ancestor_id)[1] != 0
                    ancestor_id = ancestor_id[1,1]
                    tag_id = DBInterface.execute(db, "SELECT ID FROM Tags WHERE ancestor = '$ancestor_id'
                                                                            AND tag_name = '$tag_name'") |> DataFrame
                    if size(tag_id)[1] != 0
                        tag_id = tag_id[1,1]
                    else
                        return fullpath
                    end
                else
                    return fullpath
                end
            else
                return fullpath
            end
        end
        
        record_id = DBInterface.execute(db,
            "SELECT ID
            FROM Records
            WHERE
                CASE
                    WHEN NOT '$tag' = ''
                    THEN EXISTS (SELECT *
                                FROM TagsMap
                                WHERE tag_id = '$tag_id'
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
    end

    return fullpath
end

struct Node
    ancestor_tag::String
    tag::Vector{String}
end

function RecordTags(db, recordname)
    
    tags = []

    record_id = DBInterface.execute(db, "SELECT ID FROM Records WHERE recordname = '$recordname'") |> DataFrame;
    if size(record_id)[1] == 0
        return tags
    else
        record_id = unique!(Vector(Matrix(record_id)[:,1]))
        if length(record_id) == 1
            record_id = record_id[1,1]
            tags_id = DBInterface.execute(db, "SELECT tag_id FROM TagsMap WHERE record_id == '$record_id' ") |> DataFrame;
        else
            tags_id = DBInterface.execute(db, "SELECT tag_id FROM TagsMap WHERE record_id IN $record_id ") |> DataFrame;
        end

        if size(tags_id)[1] == 0
            return tags
        else
            tags_id = unique!(Vector(Matrix(tags_id)[:,1]))
            tags_id_tuple = Tuple(Int64(x) for x in tags_id)
            parents_id = DBInterface.execute(db, "SELECT ID FROM Tags WHERE ID IN $tags_id_tuple
                                                                        AND ancestor IS NULL") |> DataFrame;
            if size(parents_id)[1] == 0
                return tags
            else
                parents_id = unique!(Vector(Matrix(parents_id)[:,1]))
                for i in parents_id
                    parent_name = DBInterface.execute(db, "SELECT tag_name FROM Tags WHERE ID = $i") |> DataFrame;
                    children_names = DBInterface.execute(db, "SELECT tag_name FROM Tags WHERE ID IN $tags_id_tuple
                                                                                        AND ancestor = $i") |> DataFrame;
                    if size(children_names)[1] == 0
                        push!(tags, Node(parent_name, []))
                    else
                        children_names = unique!(Vector(Matrix(children_names)[:,1]))
                        push!(tags, Node(parent_name[1,1], children_names))
                    end
                end
            end
            # tags_id_tuple = Tuple(Int64(x) for x in tags_id)
            # tags_names = DBInterface.execute(db, "SELECT tag_name FROM Tags WHERE ID IN $tags_id_tuple") |> DataFrame;
        end
    end

    return tags
end

function ShowTags(db, recordname)
    tags = RecordTags(db, recordname)

    for i in tags
        println(i.ancestor_tag)
        if i.tag != []
            for j in i.tag
                println("    ", j)
            end
        end
    end

    return tags
end

#--------------------------------------------------------------------------

# путь к базе
db = SQLite.DB("configs/DBTData.sqlite")

# kwords: tag = ["ancestor_name", "tag_name"] or tag = "", subject = "", creation_date = ""
fullpath = FiltBy(db; tag = ["проба с глубоким дыханием", "плохая запись"], subject = "Лиза")

tags = ShowTags(db, "WD001080722154729");