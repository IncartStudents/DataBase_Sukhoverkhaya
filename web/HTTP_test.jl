using HTTP
using Sockets
using URIs
using JSON

# #--------------------------------------------------------------------------------------------
# # HTTP.listen! and HTTP.serve! are the non-blocking versions of HTTP.listen/HTTP.serve
# server = HTTP.serve!() do request::HTTP.Request
#    @show request
#    @show request.method
#    @show HTTP.header(request, "Content-Type")
#    @show request.body
#    try
#        return HTTP.Response("Hello")
#    catch e
#        return HTTP.Response(400, "Error: $e")
#    end
# end

# # close(server)
# #--------------------------------------------------------------------------------------------


# # теститик, как работает try-catch
# function func(a::String)
#     println(a)
# end

# a = ["a", "b", "c", 3, "d"] # интовое значение даст ошибку при передаче в func

# for i in a
#     try
#         func(i)
#     catch e
#         print("don't give me int please :(")
#     end
# end
# #--------------------------------------------------------------------------------------------

# Define handler functions
foo(req::HTTP.Request) = HTTP.Response(200, "Called foo")
bar(req::HTTP.Request) = HTTP.Response(200, "Called bar")

# Setup routing to handler functions
const router = HTTP.Router()
HTTP.register!(router, "GET", "/foo", foo)
HTTP.register!(router, "GET", "/bar", bar)

# Setup asyncronous task to perform listening to requests.
# Avoid blocking REPL
serve = HTTP.serve!(router, ip"127.0.0.1", 8080)

resp = HTTP.request("GET", "http://localhost:8080/bar")
# resp = HTTP.request("GET", "http://localhost:8080/foo")

# close(serve)

# A HTTP.Request object to demonstrate
req = HTTP.Request(
   "GET", 
   "http://foo/bar?qux=123", 
   ["Content-Type" => "text/html"], 
   "hello")

resp = HTTP.Router(req)

req.method
req.target
req.headers
HTTP.payload(req)

resp = HTTP.Response(
   200, # status code, meaning success.
   ["Content-Type" => "text/plain"], 
   body = "hello")

uri = URI(HTTP.URI(req.target))
uri.scheme
uri.host
uri.path
uri.query
queryparams(uri)

# parse(IPAddr, "127.0.0.1")
addr = ip"127.0.0.1"

# response
size = Dict("width" => 20,
            "height" => 30)

resp = HTTP.Response(
    200,
    ["Content-Type" => "application/json"],
    body=JSON.json(size)
)

# request
body = HTTP.payload(resp)
io = IOBuffer(body)
JSON.parse(io)