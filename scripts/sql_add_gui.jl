using SQLite
using DataFrames
using CImGui
using CImGui: ImVec2
using Gtk
using Dates

include("../src/Renderer.jl")
using .Renderer

include("../src/RequireFromDB(folders).jl")
using .RequireFromDB

include("../src/parser_for_dbt.jl")
using .parse_txt

include("../src/AddToDB(folders).jl")
using .AddToDatabase

mutable struct Rec
    name::String
    creation_date::DateTime
    tag::String
    subject::String
    path::String
end

mutable struct Global
    is_gui_started::Bool
    dbpath::String
    data::DataFrame
    loaded_records::Vector{Rec}
    isselected::Vector{Bool}
    tags::Vector{String}
    current_tag_item::String
    current_tag_item_id::Int64
    subjects::Vector{String}
    current_subject_item::String
    ancestor_input::String
    table_data::DataFrame
    fullpath_saver::Vector{String}
    isselected_table_data::Vector{Bool}
    help_marker_data::String
    need_read::Bool
    help_marker_id::Int64

    function Global()
        is_gui_started = false
        dbpath = "configs/DBTData.sqlite"
        data = DataFrame()
        loaded_records = []
        isselected = []
        tags = []
        current_tag_item = ""
        current_tag_item_id = 0
        subjects = []
        current_subject_item = ""
        ancestor_input = "\0"^100
        table_data = DataFrame()
        fullpath_saver = []
        isselected_table_data = []
        help_marker_data = ""
        need_read = true
        help_marker_id = 0

        new(is_gui_started, dbpath, data, 
            loaded_records, isselected, tags, 
            current_tag_item, current_tag_item_id,
            subjects, current_subject_item,
            ancestor_input, table_data,
            fullpath_saver, isselected_table_data,
            help_marker_data, need_read, help_marker_id)
    end
end

function ShowHelpMarker(symbol::String, text::String) # Справка
    CImGui.TextDisabled(symbol)
    if CImGui.IsItemHovered()
        CImGui.BeginTooltip()
        CImGui.PushTextWrapPos(CImGui.GetFontSize() * 100.0)
        CImGui.TextUnformatted(text)
        CImGui.PopTextWrapPos()
        CImGui.EndTooltip()
    end
end

function ShowAllTags(db)
    tags = []

    parents_id = DBInterface.execute(db, "SELECT ID FROM Tags WHERE ancestor IS NULL") |> DataFrame
    if size(parents_id)[1] != 0
        parents_id = unique!(Vector(Matrix(parents_id)[:,1]))
        for i in parents_id
            parent_name = (DBInterface.execute(db, "SELECT tag_name FROM Tags WHERE ID = '$i'") |> DataFrame)[1,1]
            children_names = DBInterface.execute(db, "SELECT tag_name FROM Tags WHERE ancestor = '$i'") |> DataFrame

            if size(children_names) != 0
                children_names = unique!(Vector(Matrix(children_names)[:,1]))
                push!(tags, string(parent_name))
                for j in children_names
                    push!(tags, string("    "*j))
                end
            else
                push!(tags, string(parent_name))
            end
        end
    else
        return tags
    end

    return tags
end

function ShowAllSubj(db)
    subj = []

    list_of_subjcts = DBInterface.execute(db, "SELECT subject_name FROM Subjects") |> DataFrame
    if size(list_of_subjcts)[1] != 0
        subj = (Vector(Matrix(list_of_subjcts)[:,1]))
    end

    return subj
end

function DataLoad(v::Global)
    if v.is_gui_started == false
        db = SQLite.DB(v.dbpath)
        v.data = DBInterface.execute(db, "SELECT recordname, creation_date FROM Records") |> DataFrame
        v.tags = ShowAllTags(db)
        v.subjects = ShowAllSubj(db)
        v.table_data = v.data ###!!!!! может быть проблема с поинтером
        v.isselected_table_data = fill(false, size(v.table_data)[1])

        v.is_gui_started = true
    end
end

function DeleteRecords(v::Global, rec_to_delete)
    db = SQLite.DB(v.dbpath)
    if length(rec_to_delete) == 1
        rec_to_delete = rec_to_delete[1]
        DBInterface.execute(db, "DELETE FROM Records WHERE recordname = '$rec_to_delete'")
    else
        rec_to_delete = Tuple(String(x) for x in rec_to_delete)
        DBInterface.execute(db, "DELETE FROM Records WHERE recordname IN $rec_to_delete")
    end
    v.is_gui_started = false
    Clean(v)
end

function DeleteAllRecordsButton(v::Global)
    if CImGui.Button("Delete all shown records from database")
        rec_to_delete = []
        for i in 1:size(v.table_data)[1]
            push!(rec_to_delete, v.table_data[i,1])
        end
        
        DeleteRecords(v, rec_to_delete)
    end
end

function DeleteSelecredRecordsButton(v::Global)
    if length(findall(v.isselected_table_data)) != 0
        if CImGui.Button("Delete selected records from database")
            rec_to_delete = []
            for i in 1:length(v.isselected_table_data)
                if v.isselected_table_data[i]
                    push!(rec_to_delete, v.table_data[i,1])
                end
            end
            
            DeleteRecords(v, rec_to_delete)
        end
    end
end

function ShowRecInformation(v::Global, id)
    # CImGui.TextDisabled("(i)")
    # # if v.help_marker_id != id
    # #     v.need_read = true
    # # end
    # if CImGui.IsItemHovered()
    #     # if v.need_read

    #     #     print("yo")

    #     #     v.need_read = false
    #     # end
    #     # CImGui.BeginTooltip()
    #     # CImGui.PushTextWrapPos(CImGui.GetFontSize() * 100.0)
    #     # CImGui.TextUnformatted(v.help_marker_data)
    #     # CImGui.PopTextWrapPos()
    #     # CImGui.EndTooltip()

    #     println(v.help_marker_id)
    #     println(id)
    # end
end

function RecordsTable(data_for_table::DataFrame, s::Renderer.GR, v::Global)
    CImGui.SetNextWindowPos(ImVec2(s.w/2,0))
    CImGui.SetNextWindowSize(ImVec2(s.w/2, s.h))
    CImGui.Begin("Records")

        N = size(v.data)[1]
        n = size(v.table_data)[1]
        CImGui.Text("The number of all entries in database is $N.")
        if v.current_subject_item != "" || v.current_tag_item != ""
            CImGui.Text("The number of entries after filtering is $n.")
        end
        CImGui.NewLine()

        row, col = size(data_for_table);
        nms = names(data_for_table);
        CImGui.Columns(col,"DataBase");
        CImGui.Separator()

        for c in 1:col
            CImGui.Text(nms[c])
            CImGui.NextColumn()
        end
        CImGui.Separator()
        for r in 1:row
            for c in 1:col
                # if c == 1
                #     CImGui.PushID(r)
                #         ShowRecInformation(v, r)
                #         v.help_marker_id = r
                #     CImGui.PopID()
                #     CImGui.SameLine()
                # end
                if CImGui.Selectable(string(data_for_table[r, c]), pointer(v.isselected_table_data)+(r-1)*sizeof(Bool))
                end
                CImGui.NextColumn()
            end
        end

    CImGui.End()
end

function NewEntriesTable(v::Global)
    colnames = ["filename", "creation_date", "tag", "subject"]
        row = length(v.loaded_records);
        col = length(colnames);

        CImGui.BeginChild("New entries table", ImVec2(CImGui.GetWindowContentRegionWidth(), 600), false)
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
                    elseif c == 3
                        CImGui.Text(string(v.loaded_records[r].tag))
                        CImGui.NextColumn()
                    elseif c == 4
                        CImGui.Text(string(v.loaded_records[r].subject))
                        CImGui.NextColumn()
                    else
                        CImGui.NextColumn()
                    end
                end
            end
        CImGui.EndChild()
end

function TagsCombo(v::Global)
    if CImGui.BeginCombo("Tags", v.current_tag_item)
        for i in 1:length(v.tags)
            isselected = (i == v.current_tag_item_id)
            CImGui.PushID(i)
                if CImGui.Selectable(v.tags[i], isselected)
                    tag = split(v.tags[i], "    ")
                    if length(tag) == 1
                        v.current_tag_item = tag[1]
                    else
                        for j in i:-1:1
                            phrase = split(v.tags[j], "    ")
                            if length(phrase) == 1
                                v.current_tag_item = phrase[1]*": "*tag[2]
                                break
                            end
                        end
                    end
                    v.current_tag_item_id = i
                    SelectFromDB(v)
                end
            CImGui.PopID()
        end
        CImGui.EndCombo()
    end
end

function SubjectsCombo(v::Global)
    if CImGui.BeginCombo("Subjects", v.current_subject_item)
        for i in 1:length(v.subjects)
            isselected = (v.subjects[i] == v.current_subject_item)
            if CImGui.Selectable(v.subjects[i], isselected)
                v.current_subject_item = v.subjects[i]

                SelectFromDB(v)
            end
        end
        CImGui.EndCombo()
    end
end

function AddNewRecFolderButton(v::Global)
    if CImGui.Button("Add records from folder")
        Clean(v)

        dir = open_dialog_native("Select folder", action = GtkFileChooserAction.SELECT_FOLDER)
        if isdir(dir)
            records = readdir(dir)
            v.loaded_records = []
            for i in 1:lastindex(records)
                creation_date = Dates.unix2datetime(mtime(string(dir*"\\"*records[i])))
                push!(v.loaded_records, Rec(records[i], creation_date, "", "", string(dir)))
            end
            v.isselected = fill(false, length(records))
        end
    end
end

function AddRecTxtButton(v::Global)
    if CImGui.Button("Add txt with metadata")
        txt = open_dialog_native("Select file")
        entries = parse_txt.dbt_txt_parser(txt)

        for i in 1:length(v.loaded_records) ## не делать сабжектс глобальным??
            for j in entries
                if v.loaded_records[i].name == j.filename
                    v.loaded_records[i].tag = j.tag
                    v.loaded_records[i].subject = j.subj
                end
            end
        end
    end
end

function AddToDBButton(v::Global)

    if CImGui.Button("Add records to database")
        db = SQLite.DB(v.dbpath)
        records = v.loaded_records
        for i in 1:length(records)
            args = []
            if records[i].name != "" push!(args, :record => records[i].name) end
            if records[i].creation_date != "" push!(args, :creation_date => records[i].creation_date) end
            if records[i].tag != "" 
                if length(replace(v.ancestor_input, "\0" => "")) == 0
                    push!(args, :tag => records[i].tag) 
                else
                    push!(args, :tag => [string(split(v.ancestor_input, "\0")[1]),records[i].tag]) 
                end
            end
            if records[i].subject != "" push!(args, :subject => records[i].subject) end
            if records[i].path != "" push!(args, :path => records[i].path) end

            args = Dict(args)
            AddToDatabase.AddToDB_gui_modified(db, args)
        end
        v.is_gui_started = false

        Clean(v)
    end
end

function SelectFromDB(v::Global)
    args = []
    if v.current_tag_item != ""
        tg = split(v.current_tag_item, ": ")
        if length(tg) == 2
            tag = [string(tg[1]), string(tg[2])]
        else
            tag = string(tg[1])
        end
        push!(args, :tag => tag) 
    end
    if v.current_subject_item != "" push!(args, :subject => v.current_subject_item) end

    args = Dict(args)
    db = SQLite.DB(v.dbpath)
    rec_names, v.fullpath_saver = RequireFromDB.FiltBy_gui_modified(db, args)

    if size(rec_names)[1] != 0
        if size(rec_names)[1] == 1
            rec_names = rec_names[1,1]
            v.table_data = DBInterface.execute(db, "SELECT recordname, creation_date FROM Records
                                                    WHERE recordname = '$rec_names'") |> DataFrame
        else
            rec_names = Tuple(String(x) for x in rec_names)
            v.table_data = DBInterface.execute(db, "SELECT recordname, creation_date FROM Records
                                                    WHERE recordname IN $rec_names") |> DataFrame
        end
    else
        v.table_data = DataFrame("recordname" => [], "creation_date" => [])
    end
    v.isselected_table_data = fill(false, size(v.table_data)[1])

end

function SaveToClipboardButton(v::Global)
    if CImGui.Button("Save paths of shown records to clipboard")
        clipboard(v.fullpath_saver)
        v.fullpath_saver = []
    end
end

function CancelFiltersButton(v::Global)
    if CImGui.SmallButton("Cancel filters")
        Clean(v)
    end
end

function Clean(v::Global)
    v.current_tag_item = ""
    v.current_tag_item_id = 0
    v.current_subject_item = ""
    v.table_data = v.data
    v.isselected_table_data = fill(false, size(v.table_data)[1])
    v.loaded_records = []
    v.fullpath_saver = []
end

function DeleteTagButton(v::Global)
    if v.current_tag_item != ""
        CImGui.SameLine()
        if CImGui.SmallButton("delete tag from db")
            db = SQLite.DB(v.dbpath)

            tag = split(v.current_tag_item, ": ")
            if length(tag) == 1
                ancestor = string(tag[1])

                ancestor_id = (DBInterface.execute(db, "SELECT ID FROM Tags WHERE tag_name = '$ancestor'") |> DataFrame)[1,1]
                DBInterface.execute(db, "DELETE FROM Tags WHERE tag_name = '$ancestor'")
                DBInterface.execute(db, "DELETE FROM Tags WHERE ID = '$ancestor_id'")

                DBInterface.execute(db, "DELETE FROM Tags WHERE tag_name = '$tag'")
            else
                tag = string(tag[2])

                DBInterface.execute(db, "DELETE FROM Tags WHERE tag_name = '$tag'")
            end

            v.is_gui_started = false
            Clean(v)
        end
    end
end

function DeleteSubjectButton(v::Global)
    if v.current_subject_item != ""
        CImGui.SameLine()
        if CImGui.SmallButton("delete subject from db")
            db = SQLite.DB(v.dbpath)

            subj = v.current_subject_item
            DBInterface.execute(db, "DELETE FROM Subjects WHERE subject_name = '$subj'")

            v.is_gui_started = false
            Clean(v)
        end
    end
end

function DeleteNewRec(v::Global)
    if length(findall(v.isselected)) != 0 
        if CImGui.SmallButton("Delete selected")
            for i in 1:length(v.isselected)
                if v.isselected[i]
                    v.loaded_records[i] = Rec("",DateTime(0),"","","")
                end
            end
            filter!(x -> string(x) != string(Rec("",DateTime(0),"","","")), v.loaded_records)
            v.isselected = fill(false, length(v.loaded_records))
        end
    end
end

function AncestorInput(v::Global)
    ShowHelpMarker("(?)", "Материнский тег для записей внутри исследования.")
    CImGui.SameLine()
    CImGui.Text("Название исследования:")
    CImGui.InputText("##ancestor", v.ancestor_input, length(v.ancestor_input))
end


function ui(v::Global, s::Renderer.GR)
    CImGui.SetNextWindowPos(ImVec2(0,0))
    CImGui.SetNextWindowSize(ImVec2(s.w/2, s.h))
    CImGui.Begin("Functions")

        AddNewRecFolderButton(v)
        CImGui.SameLine()
        AddRecTxtButton(v)
        CImGui.SameLine(s.w/2-290)
        AddToDBButton(v)

        CImGui.NewLine()
        AncestorInput(v)

        NewEntriesTable(v)
        DeleteNewRec(v)

        CImGui.NewLine()
        CImGui.NewLine()

        # CImGui.SameLine(s.w/2-290)
        # SaveToClipboardButton(v)
        CancelFiltersButton(v)

        TagsCombo(v)
        DeleteTagButton(v)

        SubjectsCombo(v)
        DeleteSubjectButton(v)

        CImGui.NewLine()
        CImGui.NewLine()
        SaveToClipboardButton(v)
        CImGui.NewLine()
        DeleteAllRecordsButton(v)
        DeleteSelecredRecordsButton(v)

    CImGui.End()

   DataLoad(v)
   RecordsTable(v.table_data, s, v)
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
