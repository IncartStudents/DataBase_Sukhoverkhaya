module parse_txt

struct Entry
    filename::String
    subj::String
    tag::String
end

function dbt_txt_parser(txt_filename::String)
    entries = []

    open(txt_filename) do file # Открываем файл
        while !eof(file) # Пока не достигнут конец файла,
            line = rstrip(readline(file)) # читаем его построчно

            ln = split(line, " | | ")
            if length(ln) != 1
                push!(entries, Entry(ln[1], "", ln[2]))
            else
                ln = split(line, " | ")
                if length(ln) != 1
                    push!(entries, Entry(ln[1], ln[2], ln[3]))
                end
            end
        end
    end

    return entries
end

ent = dbt_txt_parser("data/names.txt")

end