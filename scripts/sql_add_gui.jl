using SQLite
using DataFrames
using CImGui
using CImGui: ImVec2

include("../src/Renderer.jl")
using .Renderer

struct DBFields
    class_name::Vector{String}
    data_name::Vector{String}
    author_name::Vector{String}
    dir_name::Vector{String}
end

mutable struct Global
    JTable::DataFrame

end

function JoinTables(db)
    Table = DBInterface.execute(db, "SELECT foldername, class_name, date_name, author_name, dir_name
                                    FROM 
                                        Class
                                        INNER JOIN Deep_breath_test_data ON Class.class_id = Deep_breath_test_data.class_id
                                        INNER JOIN Date ON Date.date_id = Deep_breath_test_data.date_id
                                        INNER JOIN Authors ON Authors.author_id = Deep_breath_test_data.author_id
                                        INNER JOIN Directories ON Directories.dir_id = Deep_breath_test_data.dir_id;") |> DataFrame;

    return Table
end

function ui()
    CImGui.SetNextWindowPos(ImVec2(0,0))
    CImGui.SetNextWindowSize(ImVec2(1700,1500))
    CImGui.Begin("")
        if CImGui.Button("Показать таблицу")
            db = SQLite.DB("configs/DeepBreathTestFiles_short.sqlite")
            JTable = JoinTables(db)
            print(JTable)
        end
    CImGui.End()
end

db = SQLite.DB("configs/DeepBreathTestFiles_short.sqlite")
DBInterface.execute(db, "SELECT * FROM Deep_breath_test_data";) |> DataFrame

# new_file = "WD001120722170605"
# class = 1
# date = "12/07/2021"

function show_gui()
    # state = Global();
    Renderer.render(
        ()->ui(),
        width=1700,
        height=1500,
        title=""
    )
end

show_gui();

