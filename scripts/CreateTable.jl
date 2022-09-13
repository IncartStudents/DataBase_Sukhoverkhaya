using SQLite
using DataFrames

# db = SQLite.DB(joinpath(@__DIR__, "DeepBreathTestFiles_full.sqlite"))
db = SQLite.DB(joinpath(@__DIR__, "DeepBreathTestFiles_short.sqlite"))

#------------------------------------------------------------------------------------------------
# Создание таблиц

# SQLite.execute(db, "CREATE TABLE IF NOT EXISTS Foldernames
#                                     (foldername_id INTEGER PRIMARY KEY AUTOINCREMENT, 
#                                     foldername_name TEXT,
#                                     UNIQUE (foldername_id))");

# SQLite.execute(db, "CREATE TABLE IF NOT EXISTS Filenames
#                                     (filename_id INTEGER PRIMARY KEY AUTOINCREMENT, 
#                                     filename_name TEXT,
#                                     UNIQUE (filename_id))");

SQLite.execute(db, "CREATE TABLE IF NOT EXISTS Class
                                    (class_id INTEGER PRIMARY KEY AUTOINCREMENT, 
                                    class_name TEXT,
                                    UNIQUE (class_id))");

SQLite.execute(db, "CREATE TABLE IF NOT EXISTS Authors
                                    (author_id INTEGER PRIMARY KEY AUTOINCREMENT, 
                                    author_name TEXT,
                                    UNIQUE (author_id))");

SQLite.execute(db, "CREATE TABLE IF NOT EXISTS Date
                                    (date_id INTEGER PRIMARY KEY AUTOINCREMENT, 
                                    date_name TEXT,
                                    UNIQUE (date_id ))");

SQLite.execute(db, "CREATE TABLE IF NOT EXISTS Directories
                                    (dir_id INTEGER PRIMARY KEY AUTOINCREMENT, 
                                    dir_name TEXT,
                                    UNIQUE (dir_id))");

# Создание связующей таблицы

SQLite.execute(db, "CREATE TABLE IF NOT EXISTS Deep_breath_test_data
                                    (file_id INTEGER PRIMARY KEY AUTOINCREMENT, 
                                    foldername TEXT,
                                    class_id INT,
                                    date_id INT,
                                    author_id INT,
                                    dir_id INT,
                                    UNIQUE (file_id),
                                    FOREIGN KEY (class_id) REFERENCES Class (class_id) ON DELETE SET NULL,
                                    FOREIGN KEY (date_id) REFERENCES Authors (date_id) ON DELETE SET NULL,
                                    FOREIGN KEY (author_id) REFERENCES Date (author_id) ON DELETE CASCADE,
                                    FOREIGN KEY (dir_id) REFERENCES Directories (dir_id) ON DELETE SET NULL)");

# SQLite.execute(db, "CREATE TABLE IF NOT EXISTS Deep_breath_test_data
#                                     (file_id INTEGER PRIMARY KEY AUTOINCREMENT, 
#                                     foldername_id INT,
#                                     filename_id INT,
#                                     class_id INT,
#                                     date_id INT,
#                                     author_id INT,
#                                     dir_id INT,
#                                     UNIQUE (file_id),
#                                     FOREIGN KEY (foldername_id) REFERENCES Foldernames (foldername_id) ON DELETE CASCADE,
#                                     FOREIGN KEY (filename_id) REFERENCES Filenames (filename_id) ON DELETE CASCADE,
#                                     FOREIGN KEY (class_id) REFERENCES Class (class_id) ON DELETE SET NULL,
#                                     FOREIGN KEY (date_id) REFERENCES Authors (date_id) ON DELETE SET NULL,
#                                     FOREIGN KEY (author_id) REFERENCES Date (author_id) ON DELETE CASCADE,
#                                     FOREIGN KEY (dir_id) REFERENCES Directories (dir_id) ON DELETE SET NULL)");
#------------------------------------------------------------------------------------------------

#____ Заполнение таблиц

# DBInterface.execute(db, "INSERT INTO Foldernames (foldername_name)
#                                     VALUES ('WD001020822163444'),
#                                            ('WD001020822163737'),
#                                            ('WD001020822164219')");

# DBInterface.execute(db, "INSERT INTO Filenames (filename_name)
#                                     VALUES ('brth'),
#                                            ('ecg'),
#                                            ('move'),
#                                            ('oxy'),
#                                            ('prs'),
#                                            ('reo'),
#                                            ('ton'),
#                                            ('marks')");

DBInterface.execute(db, "INSERT INTO Class (class_name)
                                    VALUES ('хорошая проба'),
                                           ('плохая проба')");

DBInterface.execute(db, "INSERT INTO Date (date_name)
                                    VALUES ('02/08/2022'),
                                           ('12/07/2022')");
                          
DBInterface.execute(db, "INSERT INTO Authors (author_name) 
                                    VALUES  ('Никита'),
                                            ('Лиза'),
                                            ('Алексей'),
                                            ('Катя')");

DBInterface.execute(db, "INSERT INTO Directories (dir_name) 
                                    VALUES  ('D:/ИНКАРТ/sql/data')");

#____ Заполнение связующей таблицы

DBInterface.execute(db, "INSERT INTO Deep_breath_test_data (foldername, class_id, date_id, author_id, dir_id) 
                                        VALUES  ('WD001020822163444', '1', '1', '3', '1'),
                                                ('WD001120722171552', '2', '2', '2', '1'),
                                                ('WD001120722183939', '1', '2', '4', '1')");

# (????)
# DBInterface.execute(db, "INSERT INTO Deep_breath_test_data (foldername_id, filename_id, class_id, date_id, author_id, dir_id) 
#                                                 VALUES  ('')");

#------------------------------------------------------------------------------------------------


# Черновик

# db = SQLite.DB(joinpath(@__DIR__, "test0609.sqlite"))

# SQLite.execute(db, "CREATE TABLE IF NOT EXISTS Files
#                                     (ID INTEGER PRIMARY KEY AUTOINCREMENT, 
#                                     Name TEXT,
#                                     Type TEXT,
#                                     Author TEXT,
#                                     UNIQUE (ID))")
# DBInterface.execute(db, "INSERT INTO Files (Name, Type, Author) 
#                                     VALUES ('JJ433t342.bin', '1', 'CJ')")            

# DBInterface.execute(db, "SELECT * FROM Files") |> DataFrame

# SQLite.execute(db, "CREATE TABLE IF NOT EXISTS Tags
#                                     (ID INTEGER PRIMARY KEY AUTOINCREMENT, 
#                                     tag_name TEXT,
#                                     UNIQUE (ID))")
# DBInterface.execute(db, "INSERT INTO Tags (tag_name) 
#                                     VALUES ('spiro')")   

# DBInterface.execute(db, "SELECT * FROM Tags") |> DataFrame

# SQLite.execute(db, "CREATE TABLE IF NOT EXISTS FilesNew
#                                     (ID INTEGER PRIMARY KEY AUTOINCREMENT, 
#                                     Name TEXT,
#                                     Type TEXT,
#                                     TAG INT,
#                                     UNIQUE (ID),
#                                     FOREIGN KEY (TAG) REFERENCES Tags (ID) ON DELETE CASCADE)")
# DBInterface.execute(db, "INSERT INTO FilesNew (Name, Type, TAG) 
#                                     VALUES ('JJ433t342.bin', 'spiro', '1')")            

# DBInterface.execute(db, "SELECT * FROM FilesNew") |> DataFrame

# -------------------------------------------------------------------------------------------
# Выбор значений из БД
db = SQLite.DB("configs/DeepBreathTestFiles_short.sqlite")

f = DBInterface.execute(db, "SELECT foldername, class_name, date_name, author_name, dir_name
                        FROM 
                            Class
                            INNER JOIN Deep_breath_test_data ON Class.class_id = Deep_breath_test_data.class_id
                            INNER JOIN Date ON Date.date_id = Deep_breath_test_data.date_id
                            INNER JOIN Authors ON Authors.author_id = Deep_breath_test_data.author_id
                            INNER JOIN Directories ON Directories.dir_id = Deep_breath_test_data.dir_id;") |> DataFrame

DBInterface.execute(db, "SELECT foldername, class_name, date_name, author_name, dir_name
                            FROM 
                                Class
                                INNER JOIN Deep_breath_test_data ON Class.class_id = Deep_breath_test_data.class_id
                                INNER JOIN Date ON Date.date_id = Deep_breath_test_data.date_id
                                INNER JOIN Authors ON Authors.author_id = Deep_breath_test_data.author_id
                                INNER JOIN Directories ON Directories.dir_id = Deep_breath_test_data.dir_id
                            WHERE Deep_breath_test_data.class_id = 1
                                AND Deep_breath_test_data.author_id = 4;") |> DataFrame

a = DBInterface.execute(db, "SELECT class_name FROM Class;") |> DataFrame
a[2,1]

f.foldername


#---------------------------------------------------------------------------------------------
DBInterface.execute(db, "SELECT * FROM Deep_breath_test_data;") |> DataFrame
DBInterface.execute(db, "SELECT * FROM Class;") |> DataFrame
DBInterface.execute(db, "SELECT * FROM Date;") |> DataFrame
DBInterface.execute(db, "SELECT * FROM Authors;") |> DataFrame
DBInterface.execute(db, "SELECT * FROM Directories;") |> DataFrame