#!/usr/bin/env julia --project=@.

import Sockets
import HTTP

import JSON

# декларируем обработчики маршрутов
# выдаём строку приветствия
index(req::HTTP.Request) =
    HTTP.Response(200, "Hello World")

# выдаём приветствие конкретного пользователя
function welcome_user(req::HTTP.Request)
    # dump(req)
    user = ""
    if (m = match( r".*/user/([[:alpha:]]+)", req.target)) != nothing # "math = ..." - регулярное выражение, разбирающее маршрут, на который зарегистрирован обработчик.
        user = m[1]
    end
    return HTTP.Response(200, "Hello " * user)
end

# обрабатываем JSON
function process_resource(req::HTTP.Request)
    # dump(req) # распечатывает в консоль всё, что известно по объекту. Включая типы данных, значения, а также все вложенные поля и их значения. 
    message = JSON.parse(String(req.body))
    @info message
    message["server_mark"] = "confirmed" # добавление нового ключа (ключа сервер марк со значение конфирмд) в Dict, в который спарсился JSON
    return HTTP.Response(200, JSON.json(message))
end

# Регистрируем маршруты и их обработчики
const ROUTER = HTTP.Router()
HTTP.register!(ROUTER, "GET", "/", index)
HTTP.register!(ROUTER, "GET", "/user/*", welcome_user)
HTTP.register!(ROUTER, "POST", "/resource/process", process_resource)

serve = HTTP.serve!(ROUTER, Sockets.localhost, 8080)

# close(serve)