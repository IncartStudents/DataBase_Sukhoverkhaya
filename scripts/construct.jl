using SQLite
using Gtk

mutable struct AppData
    PrDir::String  # Directory of the project
    ChosenDir::String   # Directory of ECG files for database
    delete_tag_button::GtkButton   #Button for Tags "new" actions
    tags_list::GtkListStore   # Tag List of all tags in system
    tags_list_view::GtkTreeView   # TreeView for the list tags_list
    currentItTag::GtkTreeIter   # Catch the the action, clicking on row in the whole tags'list
    files_list::GtkListStore   # Files List for all files in the system 
    files_list_view::GtkTreeView   # TreeView for the list files_list
    MainWindow2Sortvbox::GtkBox   # Last component to add Label and List of files(tags) for one tag(file)
    logwindow::GtkScrolledWindow # For Scrolling
    MainWindow2::GtkWindow   # The second Window with all Lists
    TagInfo::GtkLabel   # Label for the chosen tag
    TagsListForFile::GtkListStore   # Click on file, the list of tags for chosen file
    TagsListForFileView::GtkTreeView # TreeView for the TagsListForFile
    AnnotationAdd::GtkEntry   # Annotation for creation of tag
    DefinitionAdd::GtkEntry   # Definition for creation of tag
    FilesListForTag::GtkListStore   # Click on tag, the list of files for chosen tag
    FilesListForTagView::GtkTreeView   # TreeView for the list FilesListForTag
    FileInfo:: GtkLabel   # Label for the chosen file
    AttDet_atachhbox::GtkButtonBox   # Attach chosen tag to files
    DetachButton::GtkButton   # Attach chosen tag from file
    currentItTagAttDet::GtkTreeIter   # Catch the the action, clicking on row in the tags'list
    attach_detach_file::String   # Clicking on the file row in the List of files of the chosen tag
    tag_detach_name::String # To remember the tag annotation fo detach
    sort_list_of_tags::Array
    ExportButton::GtkButton
    AttDetFileMode::Int64
    file_name::String
    WindowEntry::GtkWindow   # Window for entry
end

application_data =  AppData(@__DIR__, @__DIR__,GtkButton("Delete"), GtkListStore(String, String), 
                    GtkTreeView(), GtkTreeIter(), GtkListStore(String, String, String, Int64),
                    GtkTreeView(), GtkBox(:v), GtkScrolledWindow(),GtkWindow("Files", 1350, 800), 
                    GtkLabel(""),GtkListStore(String, String), GtkTreeView(),GtkEntry(),
                    GtkEntry(), GtkListStore(String, String, String, Int64), GtkTreeView(),
                    GtkLabel(""), GtkButtonBox(:h), GtkButton("detach"), GtkTreeIter(), "", "", [], GtkButton("export"), 0, "", GtkWindow())
#-------------------------------------------------------------------------------
# Creation of Database
function CreationOfDataBase()
    # Connection to database
        db = SQLite.DB(joinpath(application_data.PrDir, "pictures.sqlite"))
    # Creation of tables
        SQLite.execute(db, "DROP TABLE IF EXISTS Files")
        SQLite.execute(db, "CREATE TABLE IF NOT EXISTS Files
                                    (ID INTEGER PRIMARY KEY AUTOINCREMENT, 
                                    FullName TEXT,
                                    creation_date TEXT,
                                    change_date TEXT,
                                    size  INTEGER,
                                    UNIQUE (ID))")
        SQLite.execute(db, "DROP TABLE IF EXISTS Tags")
        SQLite.execute(db, "CREATE TABLE IF NOT EXISTS Tags
                                    (ID INTEGER PRIMARY KEY AUTOINCREMENT UNIQUE, 
                                    tag_name TEXT,
                                    fullname TEXT,
                                    ancestor INTEGER,
                                    UNIQUE (ID))")
        SQLite.execute(db, "DROP TABLE IF EXISTS Tagmap")
        SQLite.execute(db, "CREATE TABLE IF NOT EXISTS Tagmap
                                    (ID INTEGER PRIMARY KEY AUTOINCREMENT UNIQUE,
                                    file_id INTEGER,
                                    tag_id INTEGER,
                                    UNIQUE (ID),
                                    FOREIGN KEY (file_id) REFERENCES Files (ID),
                                    FOREIGN KEY (tag_id) REFERENCES Tags (ID))")
    # Connection to database closed
        DBInterface.close!
end
#-------------------------------------------------------------------------------
# CreationOfDataBase()
function fillingTheDatabase(BaseDir)
    # Addition of tags
        db = SQLite.DB(joinpath(application_data.PrDir, "pictures.sqlite"))
        for i = 1:length(tagssymb)
            tag_name = tagssymb[i]
            fullname = tagsnames[i]
            DBInterface.execute(db, 
                "INSERT INTO Tags (tag_name, fullname) 
                VALUES ('$tag_name', '$fullname')")                         
        end
    # Addition of files
        filesNames = readdir(BaseDir)
        for i = 1:2:length(filesNames) 
            if (filesNames[i][end-3:end]==".atr")
                fileFullAddr = joinpath(BaseDir, filesNames[i])
                fileName = filesNames[i]
                mdate = unix2datetime(stat(fileFullAddr).mtime)
                cdate = unix2datetime(stat(fileFullAddr).ctime)
                fileSize = stat(fileFullAddr).size
                DBInterface.execute(db, 
                    "INSERT INTO Files (FullName, creation_date, change_date, size)
                    VALUES ('$fileName', '$cdate', '$mdate', '$fileSize')")  
    # Filling Tagmap Table
                frame = DBInterface.execute(db,"SELECT max(id) FROM Files")|> DataFrame
                file_id = frame."max(id)"[1]
                filetags = tagsMapping(fileName, application_data.ChosenDir)
                for i=1:length(filetags)
                    tag_name = filetags[i]
                    frame = DBInterface.execute(db,"SELECT ID From Tags Where tag_name='$tag_name'") |> DataFrame
                    if (length(frame.ID)>0)
                    tag_id = frame.ID[1]
                    DBInterface.execute(db, 
                    "INSERT INTO Tagmap (file_id, tag_id) 
                    VALUES ('$file_id', '$tag_id')")  
                    end
                end 
        end
        DBInterface.close!
        end
    end
