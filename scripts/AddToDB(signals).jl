using SQLite
using DataFrames

# путь к базе
db = SQLite.DB("configs/DBTData_allfiles.sqlite")

#------------------------------------------------------------------------
# Функции добавления записей в главные таблицы
function AddFile(new_name::String, creation_date::String)
    # добавление нового имени, если такого ещё нет в базе
    DBInterface.execute(db, "INSERT INTO Files (filename, creation_date) SELECT '$new_name', '$creation_date'
                                WHERE NOT EXISTS (SELECT filename FROM Files 
                                                                        WHERE filename = '$new_name')");
end

function AddSignal(new_sig::String)
    # добавление нового имени, если такого ещё нет в базе
    DBInterface.execute(db, "INSERT INTO Signals (signal_name) SELECT '$new_sig'
                                WHERE NOT EXISTS (SELECT signal_name FROM Signals 
                                                                        WHERE signal_name = '$new_sig')");
end

function AddTag(new_tag::String)
    # добавление нового тега, если такого ещё нет в базе
    DBInterface.execute(db, "INSERT INTO Tags (tag_name) SELECT ('$new_tag') 
                                WHERE NOT EXISTS (SELECT tag_name FROM Tags
                                                                        WHERE tag_name = '$new_tag')");
end

function AddAuthor(new_author::String)
    # добавление нового автора, если такого ещё нет в базе
    DBInterface.execute(db, "INSERT INTO Authors (author_name) SELECT ('$new_author') 
                                WHERE NOT EXISTS (SELECT author_name FROM Authors
                                                                        WHERE author_name = '$new_author')");
end

function AddPath(new_path::String)
    # добавление нового пути, если такого ещё нет в базе
    DBInterface.execute(db, "INSERT INTO Paths (path_name) SELECT ('$new_path') 
                                WHERE NOT EXISTS (SELECT path_name FROM Paths
                                                                        WHERE path_name = '$new_path')");
end

# Функции добавления записей в связующие таблицы 
function BindSig(filename::String, sig::String)

    # добавление нового сигнала, если такого ещё нет в базе
    AddSignal(sig::String)

    # поиск айдишника имени
    name_id = Int((DBInterface.execute(db, "SELECT ID FROM Files WHERE filename = '$filename'") |> DataFrame)[1,1])

    # поиск айдишника сигнала
    signal_id = Int((DBInterface.execute(db, "SELECT ID FROM Signals WHERE signal_name = '$sig'") |> DataFrame)[1,1])

    # # привязка к сигналу
    # DBInterface.execute(db, "INSERT INTO SignalsMap (file_id, signal_id)
    #                                     VALUES ('$name_id', '$signal_id')");

    # привязка к сигналу, если такой ещё не было
    DBInterface.execute(db, "INSERT INTO SignalsMap (file_id, signal_id) SELECT '$name_id', '$signal_id'
                                WHERE NOT EXISTS (SELECT file_id, signal_id FROM SignalsMap
                                                                            WHERE file_id = '$name_id'
                                                                            AND signal_id = '$signal_id')");
end

function BindTag(filename::String, tag::String)

    # добавление нового тега, если такого ещё нет в базе
    AddTag(tag::String)

    # поиск айдишника имени
    name_id = Int((DBInterface.execute(db, "SELECT ID FROM Files WHERE filename = '$filename'") |> DataFrame)[1,1])

    # поиск айдишника тега
    tag_id = Int((DBInterface.execute(db, "SELECT ID FROM Tags WHERE tag_name = '$tag'") |> DataFrame)[1,1])

    # привязка к тегу, если такой ещё не было
    DBInterface.execute(db, "INSERT INTO TagsMap (file_id, tag_id) SELECT '$name_id', '$tag_id'
                                WHERE NOT EXISTS (SELECT file_id, tag_id FROM TagsMap
                                                                            WHERE file_id = '$name_id'
                                                                            AND tag_id = '$tag_id')");
end

function BindAuthor(filename::String, author::String)

    # добавление нового автора, если такого ещё нет в базе
    AddAuthor(author::String)

    # поиск айдишника имени
    name_id = Int((DBInterface.execute(db, "SELECT ID FROM Files WHERE filename = '$filename'") |> DataFrame)[1,1])

    # поиск айдишника автора
    author_id = Int((DBInterface.execute(db, "SELECT ID FROM Authors WHERE author_name = '$author'") |> DataFrame)[1,1])

    # привязка к автору, если такой ещё не было
    DBInterface.execute(db, "INSERT INTO AuthorsMap (file_id, author_id) SELECT '$name_id', '$author_id'
                                WHERE NOT EXISTS (SELECT file_id, author_id FROM AuthorsMap
                                                                                WHERE file_id = '$name_id'
                                                                                AND author_id = '$author_id')");
end

function BindPath(filename::String, path::String)

    # добавление нового пути, если такого ещё нет в базе
    AddPath(path::String)

    # поиск айдишника имени
    name_id = Int((DBInterface.execute(db, "SELECT ID FROM Files WHERE filename = '$filename'") |> DataFrame)[1,1])

    # поиск айдишника пути
    path_id = Int((DBInterface.execute(db, "SELECT ID FROM Paths WHERE path_name = '$path'") |> DataFrame)[1,1])

    # привязка к пути
    DBInterface.execute(db, "INSERT INTO PathsMap (file_id, path_id) SELECT '$name_id', '$path_id'
                                WHERE NOT EXISTS (SELECT file_id, path_id FROM PathsMap
                                                                            WHERE file_id = '$name_id'
                                                                            AND path_id = '$path_id')");
end
#------------------------------------------------------------------------
new_name = ""
new_sig = ""
new_date = ""
new_tag = ""
new_author = ""
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
new_sig = ["brth", "ecg", "move", "oxy", "prs", "reo"]
new_tag = ["хорошая запись", "хорошая запись", "хорошая запись",
            "плохая запись", "плохая запись", "плохая запись", 
            "хорошая запись", "хорошая запись", "хорошая запись", 
            "плохая запись", "плохая запись", "плохая запись",
            "хорошая запись", "хорошая запись", "хорошая запись",
            "плохая запись", "плохая запись", "плохая запись"];
new_author = ["Никита", "Никита","Никита",
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
# print("Введите название сигнала:")
# new_sig = readline()
# print("Введите новый или существующий тег:")
# new_tag = readline()
# print("Введите атора файла:")
# new_author = readline()
# print("Введите путь к папке с файлом:")
# new_path = readline()
##--------------------------------------------------------------------------

for k in 1:lastindex(new_name)
    if new_name != ""
        if new_date != ""
            AddFile(new_name[k], new_date[k]);
        end
        if new_sig != ""
            for i in 1:lastindex(new_sig)
                BindSig(new_name[k], new_sig[i]);
            end
        end
        if new_tag != ""
            BindTag(new_name[k], new_tag[k]);
        end
        if new_author != ""
            BindAuthor(new_name[k], new_author[k]);
        end
        if new_path != ""
            BindPath(new_name[k], new_path[k]);
        end
    end
end