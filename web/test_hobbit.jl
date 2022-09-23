using HTTP, Sockets, URIs

body = read("web/test_hobbit.html", String);

HTTP.serve(ip"127.0.0.1", 8080) do req::HTTP.Request
   @show req["Content-Type"]

   if req["Content-Type"] == "application/x-www-form-urlencoded"
       payload = HTTP.payload(req, String)
       dict = queryparams(payload)
       @show dict
       return HTTP.Response(200, body)
   else
       return HTTP.Response(200, body)
   end
end