using SQLite
using DataFrames
using CImGui
using CImGui: ImVec2
using Gtk
using Dates

include("../src/Renderer.jl")
using .Renderer

struct Rec
    name::String
    creation_date::DateTime
end

mutable struct Global
    is_gui_started::Bool
    data::DataFrame
    loaded_records::Vector{Rec}
    isselected::Vector{Bool}

    function Global()
        is_gui_started = false
        data = DataFrame()
        loaded_records = []
        isselected = []

        new(is_gui_started, data, loaded_records, isselected)
    end
end

function ui(v::Global, s::Renderer.GR)
    CImGui.SetNextWindowPos(ImVec2(0,0))
    CImGui.SetNextWindowSize(ImVec2(s.w/2, s.h))
    CImGui.Begin("Functions")
        if CImGui.Button("Add records from folder")
            dir = open_dialog_native("Select folder", action = GtkFileChooserAction.SELECT_FOLDER)
            if isdir(dir)
                records = readdir(dir)
                v.loaded_records = []
                for i in 1:lastindex(records)
                    creation_date = Dates.unix2datetime(mtime(string(dir*"\\"*records[i])))
                    push!(v.loaded_records, Rec(records[i], creation_date))
                end
                v.isselected = fill(false, length(records))
            end
        end

        colnames = ["filename", "creation_date", "tag", "subject"]
        row = length(v.loaded_records);
        col = length(colnames);
        CImGui.Columns(col, "New entries");
        CImGui.Separator()

        for c in 1:col
            CImGui.Text(colnames[c])
            CImGui.NextColumn()
        end
        CImGui.Separator()
        for r in 1:row
            for c in 1:col
                if c == 1
                    if CImGui.Selectable(string(v.loaded_records[r].name), pointer(v.isselected)+(r-1)*sizeof(Bool))
                    end
                    CImGui.NextColumn()
                elseif c == 2
                    CImGui.Text(string(v.loaded_records[r].creation_date))
                    CImGui.NextColumn()
                else
                    CImGui.NextColumn()
                end
            end
        end

    CImGui.End()

    CImGui.SetNextWindowPos(ImVec2(s.w/2,0))
    CImGui.SetNextWindowSize(ImVec2(s.w/2, s.h))
    CImGui.Begin("Records")
        if v.is_gui_started == false
            db = SQLite.DB("configs/DBTData.sqlite")
            v.data = DBInterface.execute(db, "SELECT * FROM Records") |> DataFrame
            v.is_gui_started == true
        end

        row, col = size(v.data);
        nms = names(v.data);
        CImGui.Columns(col-1,"DataBase");
        CImGui.Separator()

        for c in 2:col
            CImGui.Text(nms[c])
            CImGui.NextColumn()
        end
        CImGui.Separator()
        for r in 1:row
            for c in 2:col
                CImGui.Text(string(v.data[r, c]))
                CImGui.NextColumn()
            end
        end

    CImGui.End()
end

function show_gui()
    state = Global();
    size = Renderer.GR();
    Renderer.render(
        ()->ui(state, size),
        width = 1700,
        height = 1500,
        title = "",
        v = size
    )
end

show_gui();