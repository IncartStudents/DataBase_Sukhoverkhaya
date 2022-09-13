using SQLite
using DataFrames

db = SQLite.DB("configs/DBTData_allfiles.sqlite")

# Таблица с именами папок записей и датами создания
SQLite.execute(db, "CREATE TABLE IF NOT EXISTS Files 
                                    (ID INTEGER PRIMARY KEY AUTOINCREMENT, 
                                    filename TEXT,
                                    creation_date TEXT,
                                    UNIQUE (ID))");

# Таблица с типами сигналов 
SQLite.execute(db, "CREATE TABLE IF NOT EXISTS Signals
                                    (ID INTEGER PRIMARY KEY AUTOINCREMENT, 
                                    signal_name TEXT,
                                    UNIQUE (ID))");

# Таблица с путями к файлам
SQLite.execute(db, "CREATE TABLE IF NOT EXISTS Paths
                                    (ID INTEGER PRIMARY KEY AUTOINCREMENT, 
                                    path_name TEXT,
                                    UNIQUE (ID))");

# Таблица с именами авторов
SQLite.execute(db, "CREATE TABLE IF NOT EXISTS Authors
                                    (ID INTEGER PRIMARY KEY AUTOINCREMENT, 
                                    author_name TEXT,
                                    UNIQUE (ID))");

# Таблица с тегами
SQLite.execute(db, "CREATE TABLE IF NOT EXISTS Tags
                                    (ID INTEGER PRIMARY KEY AUTOINCREMENT, 
                                    tag_name TEXT,
                                    ancestor INT,
                                    UNIQUE (ID))");

##-----------------------------------------------------------------------------------
# Таблица связи типов сигналов с папками (многие ко многим)
SQLite.execute(db, "CREATE TABLE IF NOT EXISTS SignalsMap
                                    (ID INTEGER PRIMARY KEY AUTOINCREMENT, 
                                    file_id INT,
                                    signal_id INT,
                                    UNIQUE (ID),
                                    FOREIGN KEY (file_id) REFERENCES Files (ID) ON DELETE SET NULL,
                                    FOREIGN KEY (signal_id) REFERENCES Signals (ID) ON DELETE SET NULL)");

# Таблица связи авторов с файлами (многие ко многим)
SQLite.execute(db, "CREATE TABLE IF NOT EXISTS AuthorsMap
                                    (ID INTEGER PRIMARY KEY AUTOINCREMENT, 
                                    file_id INT,
                                    author_id INT,
                                    UNIQUE (ID),
                                    FOREIGN KEY (file_id) REFERENCES Files (ID) ON DELETE SET NULL,
                                    FOREIGN KEY (author_id) REFERENCES Authors (ID) ON DELETE SET NULL)");

# Таблица связи тегов с файлами (многие ко многим)
SQLite.execute(db, "CREATE TABLE IF NOT EXISTS TagsMap
                                    (ID INTEGER PRIMARY KEY AUTOINCREMENT, 
                                    file_id INT,
                                    tag_id INT,
                                    UNIQUE (ID),
                                    FOREIGN KEY (file_id) REFERENCES Files (ID) ON DELETE SET NULL,
                                    FOREIGN KEY (tag_id) REFERENCES Tags (ID) ON DELETE SET NULL)");

# Таблица связи путей с файлами (многие ко многим)
SQLite.execute(db, "CREATE TABLE IF NOT EXISTS PathsMap
                                    (ID INTEGER PRIMARY KEY AUTOINCREMENT, 
                                    file_id INT,
                                    path_id INT,
                                    UNIQUE (ID),
                                    FOREIGN KEY (file_id) REFERENCES Files (ID) ON DELETE SET NULL,
                                    FOREIGN KEY (path_id) REFERENCES Paths (ID) ON DELETE SET NULL)");

# DBInterface.execute(db, "SELECT * FROM Files;") |> DataFrame