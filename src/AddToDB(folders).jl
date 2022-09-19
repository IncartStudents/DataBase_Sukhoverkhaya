module AddToDatabase

using SQLite
using DataFrames
using Gtk
using Dates

#------------------------------------------------------------------------
# Функции добавления записей в главные таблицы
function AddRecord(db, new_name::String, creation_date::DateTime)
    # добавление нового имени, если такого ещё нет в базе
    DBInterface.execute(db, "INSERT INTO Records (recordname, creation_date) SELECT '$new_name', '$creation_date'
                                WHERE NOT EXISTS (SELECT recordname FROM Records 
                                                                    WHERE recordname = '$new_name')");
end

function AddTag(db, new_tag::String, ancestor::String)
    # добавление нового (материнского) тега, если такого ещё нет в базе
    if ancestor == ""
        DBInterface.execute(db, "INSERT INTO Tags (tag_name) SELECT '$new_tag'
                                    WHERE NOT EXISTS (SELECT tag_name FROM Tags
                                                                       WHERE tag_name = '$new_tag')");

    # добавление нового (дочернего) тега, если такого, в связке с указанным материнским, ещё нет в базе
    else
        # добавление нового (материнского) тега, если такого ещё нет в базе
        DBInterface.execute(db, "INSERT INTO Tags (tag_name) SELECT '$ancestor'
                                    WHERE NOT EXISTS (SELECT tag_name FROM Tags
                                                                    WHERE tag_name = '$ancestor')");


        # поиск айдишника материнского тега
        ancestor_id = DBInterface.execute(db, "SELECT ID FROM Tags WHERE tag_name = '$ancestor'") |> DataFrame;

        if size(ancestor_id)[1] != 0
            ancestor_id = ancestor_id[1,1]
            DBInterface.execute(db, "INSERT INTO Tags (tag_name, ancestor) SELECT '$new_tag', '$ancestor_id'
                                        WHERE NOT EXISTS (SELECT tag_name, ancestor FROM Tags
                                                                            WHERE tag_name = '$new_tag'
                                                                            AND ancestor = '$ancestor_id')");
        end
    end
end

function AddSubject(db, new_subject::String)
    # добавление нового автора, если такого ещё нет в базе
    DBInterface.execute(db, "INSERT INTO Subjects (subject_name) SELECT '$new_subject'
                                WHERE NOT EXISTS (SELECT subject_name FROM Subjects
                                                                    WHERE subject_name = '$new_subject')");
end

function AddPath(db, new_path::String)
    # добавление нового пути, если такого ещё нет в базе
    DBInterface.execute(db, "INSERT INTO Paths (path_name) SELECT '$new_path'
                                WHERE NOT EXISTS (SELECT path_name FROM Paths
                                                                    WHERE path_name = '$new_path')");
end

# Функции добавления записей в связующие таблицы 
function BindTag(db, recordname::String, tag::String, ancestor::String)

    # добавление нового тега, если такого ещё нет в базе
    AddTag(db, tag::String, ancestor::String)

    # поиск айдишника имени
    name_id = DBInterface.execute(db, "SELECT ID FROM Records WHERE recordname = '$recordname'") |> DataFrame
    if size(name_id)[1] != 0 name_id = name_id[1,1] end

    if ancestor != ""
        # поиск айдишника материнского тега
        ancestor_id = DBInterface.execute(db, "SELECT ID FROM Tags WHERE tag_name = '$ancestor'") |> DataFrame
        if size(ancestor_id)[1] != 0 ancestor_id = ancestor_id[1,1] end

        # поиск айдишника дочернего тега
        tag_id = DBInterface.execute(db, "SELECT ID FROM Tags WHERE tag_name = '$tag'
                                                                    AND ancestor = '$ancestor_id'") |> DataFrame
        if size(tag_id)[1] != 0 tag_id = tag_id[1,1] end
    else
        # тег без указания материнского считаем материнским
        ancestor_id = DBInterface.execute(db, "SELECT ID FROM Tags WHERE tag_name = '$tag'") |> DataFrame
        if size(ancestor_id)[1] != 0 ancestor_id = ancestor_id[1,1] end
        tag_id = DataFrame()
    end

    # привязка к материнскому тегу, если такой ещё не было
    if typeof(ancestor_id) != DataFrame 
        DBInterface.execute(db, "INSERT INTO TagsMap (record_id, tag_id) SELECT '$name_id', '$ancestor_id'
                                    WHERE NOT EXISTS (SELECT record_id, tag_id FROM TagsMap
                                                                                WHERE record_id = '$name_id'
                                                                                AND tag_id = '$ancestor_id')");
    end

    # привязка к дочернему тегу, если такой ещё не было
    if typeof(tag_id) != DataFrame
        DBInterface.execute(db, "INSERT INTO TagsMap (record_id, tag_id) SELECT '$name_id', '$tag_id'
                                    WHERE NOT EXISTS (SELECT record_id, tag_id FROM TagsMap
                                                                                WHERE record_id = '$name_id'
                                                                                AND tag_id = '$tag_id')");
    end
                                                                
end

function BindSubject(db, recordname::String, subject::String)

    # добавление нового автора, если такого ещё нет в базе
    AddSubject(db, subject::String)

    # поиск айдишника имени
    name_id = (DBInterface.execute(db, "SELECT ID FROM Records WHERE recordname = '$recordname'") |> DataFrame)
    if size(name_id)[1] != 0 name_id = name_id[1,1] end

    # поиск айдишника автора
    subject_id = (DBInterface.execute(db, "SELECT ID FROM Subjects WHERE subject_name = '$subject'") |> DataFrame)
    if size(subject_id)[1] != 0 subject_id = subject_id[1,1] end

    # привязка к автору, если такой ещё не было
    if typeof(name_id) != DataFrame && typeof(subject_id) != DataFrame
        DBInterface.execute(db, "INSERT INTO SubjectsMap (record_id, subject_id) SELECT '$name_id', '$subject_id'
                                    WHERE NOT EXISTS (SELECT record_id, subject_id FROM SubjectsMap
                                                                                    WHERE record_id = '$name_id'
                                                                                    AND subject_id = '$subject_id')");
    end
end

function BindPath(db, recordname::String, path::String)

    # добавление нового пути, если такого ещё нет в базе
    AddPath(db, path::String)

    # поиск айдишника имени
    name_id = (DBInterface.execute(db, "SELECT ID FROM Records WHERE recordname = '$recordname'") |> DataFrame)
    if size(name_id)[1] != 0 name_id = name_id[1,1] end

    # поиск айдишника пути
    path_id = (DBInterface.execute(db, "SELECT ID FROM Paths WHERE path_name = '$path'") |> DataFrame)
    if size(path_id)[1] != 0 path_id = path_id[1,1] end

    # привязка к пути
    if typeof(name_id) != DataFrame && typeof(path_id) != DataFrame
        DBInterface.execute(db, "INSERT INTO PathsMap (record_id, path_id) SELECT '$name_id', '$path_id'
                                    WHERE NOT EXISTS (SELECT record_id, path_id FROM PathsMap
                                                                                WHERE record_id = '$name_id'
                                                                                AND path_id = '$path_id')");
    end
end
#------------------------------------------------------------------------
function AddToDB(db; kwargs...)

    kwargs = Dict(kwargs)
    if haskey(kwargs, :record) record = kwargs[:record] else record = "" end
    if haskey(kwargs, :tag) tag = kwargs[:tag] else tag = "" end
    if haskey(kwargs, :ancestor) ancestor = kwargs[:ancestor] else ancestor = "" end
    if haskey(kwargs, :subject) subject = kwargs[:subject] else subject = "" end
    if haskey(kwargs, :creation_date) creation_date = kwargs[:creation_date] else creation_date = "" end
    if haskey(kwargs, :path) path = kwargs[:path] else path = "" end

    for i in 1:lastindex(record)
        if record != ""
            if creation_date[i] != ""
                AddRecord(db, record[i], creation_date[i])
            end
        end
        if tag != ""
            BindTag(db, record[i], tag[i], ancestor[i])
        end
        if subject != ""
            BindSubject(db, record[i], subject[i])
        end
        if path != ""
            BindPath(db, record[i], path[i])
        end
    end
end

function AddToDB_gui_modified(db, kwargs)

    if haskey(kwargs, :record) record = kwargs[:record] else record = "" end
    if haskey(kwargs, :tag) 
        if typeof(kwargs[:tag]) == String
            tag = kwargs[:tag]
            ancestor = ""
        else
            tag = kwargs[:tag][2]
            ancestor = kwargs[:tag][1]
        end
    else 
        tag = "" 
        ancestor = ""
    end
    # if haskey(kwargs, :ancestor) ancestor = kwargs[:ancestor] else ancestor = "" end
    if haskey(kwargs, :subject) subject = kwargs[:subject] else subject = "" end
    if haskey(kwargs, :creation_date) creation_date = kwargs[:creation_date] else creation_date = "" end
    if haskey(kwargs, :path) path = kwargs[:path] else path = "" end

    if record != ""
        if creation_date != ""
            AddRecord(db, record, creation_date)
        end
    end
    if tag != ""
        BindTag(db, record, tag, ancestor)
    end
    if subject != ""
        BindSubject(db, record, subject)
    end
    if path != ""
        BindPath(db, record, path)
    end
end

end
# new_name = ""
# new_date = ""
# new_tag = ""
# new_subject = ""
# new_path = ""

## добавление в текст программы --------------------------------------------*************************
# # путь к базе
# db = SQLite.DB("configs/DBTData.sqlite")

# record = ["WD001080722154122", "WD001080722154425", "WD001080722154729",
#             "WD001120722184220", "WD001120722184515", "WD001120722184837",
#             "WD001020822163444", "WD001020822163737", "WD001020822164219",
#             "WD001120722171552", "WD001120722171829", "WD001120722172110",
#             "WD001120722181247", "WD001120722182323", "WD001120722183939",
#             "WD001080722160930", "WD001080722161127", "WD001080722161330"];

# creation_date = ["08/07/2022", "08/07/2022", "08/07/2022",
#             "12/07/2022", "12/07/2022", "12/07/2022",
#             "02/08/2022", "02/08/2022", "02/08/2022",
#             "12/07/2022", "12/07/2022", "12/07/2022",
#             "12/07/2022", "12/07/2022", "12/07/2022",
#             "08/07/2022", "08/07/2022", "08/07/2022"];

# tag = ["хорошая запись", "хорошая запись", "хорошая запись",
#            "плохая запись", "плохая запись", "плохая запись", 
#            "хорошая запись", "хорошая запись", "хорошая запись", 
#            "плохая запись", "плохая запись", "плохая запись",
#            "хорошая запись", "хорошая запись", "хорошая запись",
#            "плохая запись", "плохая запись", "плохая запись"];

# ancestor = fill("проба с глубоким дыханием", 18);

# subject = ["Никита", "Никита","Никита",
#               "Катя","Катя","Катя",
#               "Алексей","Алексей","Алексей",
#               "Лиза", "Лиза", "Лиза",
#               "Катя","Катя","Катя",
#               "Катя", "Катя", "Катя"];

# path = fill("D:/ИНКАРТ/sql/data", 18);

# AddToDB(db; record = record, creation_date = creation_date, tag = tag, ancestor = ancestor, subject = subject, path = path)

# AddTag("нормальная запись", "другое исследование")
##--------------------------------------------------------------------------*****************************

## добавление через консоль ------------------------------------------------
# print("Введите имя существущего или нового файла:")
# new_name = readline()
# print("Введите дату создания файла:")
# new_date = readline()
# print("Введите новый или существующий тег:")
# new_tag = readline()
# print("Введите атора файла:")
# new_subject = readline()
# print("Введите путь к папке с файлом:")
# new_path = readline()
##--------------------------------------------------------------------------

# function func(;kwargs...)
#     for (k, v) in kwargs
#         println("$k = $v")
#     end
# end

# func(a=1, b=2, c=3)

# function func(;kwargs...)
#     kwargs = Dict(kwargs)
#     if haskey(kwargs, :a)
#         a = kwargs[:a]
#     else 
#         a = ""
#     end

#     if haskey(kwargs, :b)
#         b = kwargs[:b]
#     else
#         b = ""
#     end

#     if haskey(kwargs, :c)
#         c = kwargs[:c]
#     else
#         c = ""
#     end

#     return a, b, c
# end

# func(a=1, c=3)

# dir = open_dialog_native("", action=GtkFileChooserAction.SELECT_FOLDER)
# file = "WD001020822163444"
# fullname = string(dir*"\\"*file)
# creation_date = Dates.unix2datetime(mtime(test))

# if isdir(dir)
#     files = readdir(dir)
# end

# creation_dates = []
# for i in 2:length(files)-1
#     filename = files[i]
#     date = filename[6:7]*"/"*filename[8:9]*"/"*filename[10:11]
#     push!(creation_dates, date)
# end

# AddToDB(db; record = files[2:length(files)-1], creation_date = creation_dates)