using SQLite
using DataFrames

db = SQLite.DB("configs/DBTData.sqlite")

# Таблица с именами записей и датами создания
SQLite.execute(db, "CREATE TABLE IF NOT EXISTS Records
                                    (ID INTEGER PRIMARY KEY AUTOINCREMENT, 
                                    recordname TEXT,
                                    creation_date TEXT,
                                    UNIQUE (ID))");
# Таблица с путями к записям
SQLite.execute(db, "CREATE TABLE IF NOT EXISTS Paths
                                    (ID INTEGER PRIMARY KEY AUTOINCREMENT, 
                                    path_name TEXT,
                                    UNIQUE (ID))");

# Таблица с именами авторов
SQLite.execute(db, "CREATE TABLE IF NOT EXISTS Subjects
                                    (ID INTEGER PRIMARY KEY AUTOINCREMENT, 
                                    subject_name TEXT,
                                    UNIQUE (ID))");

# Таблица с тегами
SQLite.execute(db, "CREATE TABLE IF NOT EXISTS Tags
                                    (ID INTEGER PRIMARY KEY AUTOINCREMENT, 
                                    tag_name TEXT,
                                    ancestor INT,
                                    UNIQUE (ID))");

# Таблица связи авторов с записями (многие ко многим)
SQLite.execute(db, "CREATE TABLE IF NOT EXISTS SubjectsMap
                                    (record_id INTEGER PRIMARY KEY AUTOINCREMENT, 
                                    subject_id INT,
                                    UNIQUE (record_id),
                                    FOREIGN KEY (record_id) REFERENCES Records (ID) ON DELETE SET NULL,
                                    FOREIGN KEY (subject_id) REFERENCES Subjects (ID) ON DELETE SET NULL)");

# Таблица связи тегов с записями (многие ко многим)
SQLite.execute(db, "CREATE TABLE IF NOT EXISTS TagsMap
                                    (ID INTEGER PRIMARY KEY AUTOINCREMENT, 
                                    record_id INT,
                                    tag_id INT,
                                    UNIQUE (ID),
                                    FOREIGN KEY (record_id) REFERENCES Records (ID) ON DELETE SET NULL,
                                    FOREIGN KEY (tag_id) REFERENCES Tags (ID) ON DELETE SET NULL)");

# Таблица связи путей с записями (многие ко многим)
SQLite.execute(db, "CREATE TABLE IF NOT EXISTS PathsMap
                                    (ID INTEGER PRIMARY KEY AUTOINCREMENT, 
                                    record_id INT,
                                    path_id INT,
                                    UNIQUE (ID),
                                    FOREIGN KEY (record_id) REFERENCES Records (ID) ON DELETE SET NULL,
                                    FOREIGN KEY (path_id) REFERENCES Paths (ID) ON DELETE SET NULL)");
# DBInterface.execute(db, "SELECT * FROM Records;") |> DataFrame