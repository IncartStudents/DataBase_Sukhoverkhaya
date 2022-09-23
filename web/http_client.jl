#!/usr/bin/env julia --project=@.

import HTTP
import JSON.json

const PORT = "8080"
const HOST = "127.0.0.1"
const NAME = "Jemand"

# Зададим формат документа
struct Document
    title::String
    body::String
end

# Метод для печати тела отклика или кода ошибки
Base.show(r::HTTP.Messages.Response) =
    println(r.status == 200 ? String(r.body) : "Error: " * r.status)

# запрашиваем корневой маршрут
r = HTTP.get("http://$(HOST):$(PORT)")
show(r)

# запрашиваем маршрут /user/:name
r = HTTP.get("http://$(HOST):$(PORT)/user/$(NAME)"; verbose=1) # verbose задаёт объём необходимой отладочной информации
show(r)

# отправляем JSON-документ POST-запросом
doc = Document("Some document", "Test document with some content.")
r = HTTP.post(
    "http://$(HOST):$(PORT)/resource/process",
    [("Content-Type" => "application/json")],
    json(doc);
    verbose=3)
show(r)

# ---------------------------------------------------------------------------------------

# проверка незнакомых приколов
# прикол с конструкцией внутри println

# status = 400 # заменить на 200
# body = "body"
# println(status == 200 ? String(body) : "Error: " * string(status))
# то есть типа: println(если что-то тру ? принт вот это : иначе принт вот это)