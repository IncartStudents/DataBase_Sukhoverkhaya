using HTTP

const PORT = "8080"
const HOST = "127.0.0.1"

# Метод для печати тела отклика или кода ошибки
Base.show(r::HTTP.Messages.Response) =
    println(r.status == 200 ? string(r.body) : "Error: " * r.status)

# запрашиваем корневой маршрут
r = HTTP.get("http://$(HOST):$(PORT)")
show(r)

# # запрашиваем маршрут /allrecords
# r = HTTP.get("http://$(HOST):$(PORT)/allrecords"; verbose=1) # verbose задаёт объём необходимой отладочной информации
# show(r)

# запрашиваем маршрут /allrecords
r = HTTP.get("http://$(HOST):$(PORT)/allrecords"; verbose=1) # verbose задаёт объём необходимой отладочной информации
show(r)