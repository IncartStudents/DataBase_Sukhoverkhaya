using SQLite
using DataFrames

# путь к базе
db = SQLite.DB("configs/DBTData.sqlite")

#------------------------------------------------------------------------
# Функции добавления записей в главные таблицы
function AddRecord(new_name::String, creation_date::String)
    # добавление нового имени, если такого ещё нет в базе
    DBInterface.execute(db, "INSERT INTO Records (recordname, creation_date) SELECT '$new_name', '$creation_date'
                                WHERE NOT EXISTS (SELECT recordname FROM Records 
                                                                    WHERE recordname = '$new_name')");
end

function AddTag(new_tag::String, ancestor::String)
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
        ancestor_id = Int((DBInterface.execute(db, "SELECT ID FROM Tags WHERE tag_name = '$ancestor'") |> DataFrame)[1,1])

        DBInterface.execute(db, "INSERT INTO Tags (tag_name, ancestor) SELECT '$new_tag', '$ancestor_id'
                                    WHERE NOT EXISTS (SELECT tag_name, ancestor FROM Tags
                                                                        WHERE tag_name = '$new_tag'
                                                                        AND ancestor = '$ancestor_id')");
    end
end

function AddSubject(new_subject::String)
    # добавление нового автора, если такого ещё нет в базе
    DBInterface.execute(db, "INSERT INTO Subjects (subject_name) SELECT '$new_subject'
                                WHERE NOT EXISTS (SELECT subject_name FROM Subjects
                                                                    WHERE subject_name = '$new_subject')");
end

function AddPath(new_path::String)
    # добавление нового пути, если такого ещё нет в базе
    DBInterface.execute(db, "INSERT INTO Paths (path_name) SELECT '$new_path'
                                WHERE NOT EXISTS (SELECT path_name FROM Paths
                                                                    WHERE path_name = '$new_path')");
end

# Функции добавления записей в связующие таблицы 
function BindTag(recordname::String, tag::String, ancestor::String)

    # добавление нового тега, если такого ещё нет в базе
    AddTag(tag::String, ancestor::String)

    # поиск айдишника имени
    name_id = Int((DBInterface.execute(db, "SELECT ID FROM Records WHERE recordname = '$recordname'") |> DataFrame)[1,1])

    # поиск айдишника материнского тега
    ancestor_id = Int((DBInterface.execute(db, "SELECT ID FROM Tags WHERE tag_name = '$ancestor'") |> DataFrame)[1,1])

    # поиск айдишника дочернего тега
    tag_id = Int((DBInterface.execute(db, "SELECT ID FROM Tags WHERE tag_name = '$tag'
                                                                AND ancestor = '$ancestor_id'") |> DataFrame)[1,1])

    # привязка к тегу, если такой ещё не было
    DBInterface.execute(db, "INSERT INTO TagsMap (record_id, tag_id) SELECT '$name_id', '$tag_id'
                                WHERE NOT EXISTS (SELECT record_id, tag_id FROM TagsMap
                                                                            WHERE record_id = '$name_id'
                                                                            AND tag_id = '$tag_id')");
end

function BindSubject(recordname::String, subject::String)

    # добавление нового автора, если такого ещё нет в базе
    AddSubject(subject::String)

    # поиск айдишника имени
    name_id = Int((DBInterface.execute(db, "SELECT ID FROM Records WHERE recordname = '$recordname'") |> DataFrame)[1,1])

    # поиск айдишника автора
    subject_id = Int((DBInterface.execute(db, "SELECT ID FROM Subjects WHERE subject_name = '$subject'") |> DataFrame)[1,1])

    # привязка к автору, если такой ещё не было
    DBInterface.execute(db, "INSERT INTO SubjectsMap (record_id, subject_id) SELECT '$name_id', '$subject_id'
                                WHERE NOT EXISTS (SELECT record_id, subject_id FROM SubjectsMap
                                                                                WHERE record_id = '$name_id'
                                                                                AND subject_id = '$subject_id')");
end

function BindPath(recordname::String, path::String)

    # добавление нового пути, если такого ещё нет в базе
    AddPath(path::String)

    # поиск айдишника имени
    name_id = Int((DBInterface.execute(db, "SELECT ID FROM Records WHERE recordname = '$recordname'") |> DataFrame)[1,1])

    # поиск айдишника пути
    path_id = Int((DBInterface.execute(db, "SELECT ID FROM Paths WHERE path_name = '$path'") |> DataFrame)[1,1])

    # привязка к пути
    DBInterface.execute(db, "INSERT INTO PathsMap (record_id, path_id) SELECT '$name_id', '$path_id'
                                WHERE NOT EXISTS (SELECT record_id, path_id FROM PathsMap
                                                                            WHERE record_id = '$name_id'
                                                                            AND path_id = '$path_id')");
end
#------------------------------------------------------------------------
new_name = ""
new_date = ""
new_tag = ""
new_subject = ""
new_path = ""

## добавление в текст программы --------------------------------------------
new_name = ["WD001080722154122", "WD001080722154425", "WD001080722154729",
            "WD001120722184220", "WD001120722184515", "WD001120722184837",
            "WD001020822163444", "WD001020822163737", "WD001020822164219",
            "WD001120722171552", "WD001120722171829", "WD001120722172110",
            "WD001120722181247", "WD001120722182323", "WD001120722183939",
            "WD001080722160930", "WD001080722161127", "WD001080722161330"];

new_date = ["08/07/2022", "08/07/2022", "08/07/2022",
            "12/07/2022", "12/07/2022", "12/07/2022",
            "02/08/2022", "02/08/2022", "02/08/2022",
            "12/07/2022", "12/07/2022", "12/07/2022",
            "12/07/2022", "12/07/2022", "12/07/2022",
            "08/07/2022", "08/07/2022", "08/07/2022"];

new_tag = ["хорошая запись", "хорошая запись", "хорошая запись",
           "плохая запись", "плохая запись", "плохая запись", 
           "хорошая запись", "хорошая запись", "хорошая запись", 
           "плохая запись", "плохая запись", "плохая запись",
           "хорошая запись", "хорошая запись", "хорошая запись",
           "плохая запись", "плохая запись", "плохая запись"];
new_ancestor = fill("проба с глубоким дыханием", 18);
new_subject = ["Никита", "Никита","Никита",
              "Катя","Катя","Катя",
              "Алексей","Алексей","Алексей",
              "Лиза", "Лиза", "Лиза",
              "Катя","Катя","Катя",
              "Катя", "Катя", "Катя"];

new_path = fill("D:/ИНКАРТ/sql/data", 18);
##--------------------------------------------------------------------------

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

for i in 1:lastindex(new_name)
    if new_name[i] != ""
        if new_date[i] != ""
            AddRecord(new_name[i], new_date[i])
        end
        if new_tag[i] != ""
            BindTag(new_name[i], new_tag[i], new_ancestor[i])
        end
        if new_subject[i] != ""
            BindSubject(new_name[i], new_subject[i])
        end
        if new_path[i] != ""
            BindPath(new_name[i], new_path[i])
        end
    end
end

# function func(;kwargs...)
#     for (k, v) in kwargs
#         println("$k = $v")
#     end
# end

# func(a=1, b=2, c=3)
