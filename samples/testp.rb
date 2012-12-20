require '../lib/boss-protocol'

rd, wr = IO.pipe

if fork
  wr.close
  if false
    # You can do it with block:
    Boss::Parser.new(rd).each { |obj| puts "Got an object: #{obj}" }
  else
    # You can do it without block too:
    input = Boss::Parser.new rd
    puts "Got an object: #{input.get}" while !input.eof?
  end
  rd.close
  Process.wait
else
  rd.close
  out = Boss::Formatter.new wr
  out << ["Foo", "bar"]
  out.put_compressed "Zz"*62
  out << ["Hello", "world", "!"]
  out << { "Thats all" => "folks!" }
  wr.close
end