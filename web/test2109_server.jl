#!/usr/bin/env julia --project=@.

# http://localhost:8080 # ссылка для браузера

using Sockets
using HTTP

using JSON

using SQLite
using DataFrames

# декларируем обработчики маршрутов
# выдаём строку приветствия
index(req::HTTP.Request) = HTTP.Response(200, "hi there")

db = db = SQLite.DB("configs/DBTData.sqlite")

# выдаём список записей бд
# function all_records(req::HTTP.Request)
#     db = SQLite.DB("configs/DBTData.sqlite")
#     data = DBInterface.execute(db, "SELECT recordname, creation_date FROM Records") |> Dict

#     return HTTP.Response(200, data)
# end

# склеиваем две введённые фразы и выводим результат
function join_two(req::HTTP.Request)
    # dump(req)
    w1 = ""
    w2 = ""
    if (m = match( r".*/join/([[:alpha:]]+)/([[:alpha:]]+)", req.target)) != nothing # "math = ..." - регулярное выражение, разбирающее маршрут, на который зарегистрирован обработчик.
        w1 = m[1]
        w2 = m[2]
    end

    return HTTP.Response(200, string(w1*w2))
end

# Регистрируем маршруты и их обработчики
const ROUTER = HTTP.Router()
HTTP.register!(ROUTER, "GET", "/", index)
HTTP.register!(ROUTER, "GET", "/join/*/*", join_two)

serve = HTTP.serve!(ROUTER, Sockets.localhost, 8080)

# close(serve)

# a = r".*/join/([[:alpha:]]+)"
# typeof(a)

# targ = "http://join/bar/closed"
# m = match( r".*/join/([[:alpha:]]+)/([[:alpha:]]+)", targ)
# m[1]
# m[2]