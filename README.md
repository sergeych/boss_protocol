# Boss Protocol

Supported version: 1.4 (stream mode with no caching, regular cached mode)

BOSS is an acronym for Binary Object Streaming Specification.

The bit-effective, platform-independent streamable and traversable
typed binary protocol. Allow to effectively store small or any sized integers,
strings or binary data of any size, floats and doubles, arrays and hashes and time objects in a
very effective way. It caches repeating objects and stores/restores links to
objects.

The protocol allow to effectively store texts and binary data of absolutely any
size, signed integers of absolutely any size, arrays and hashes with no limit
on items and overall gross size. It is desirable to use build-in compression when
appropriate.

Streamable means that you can use a pipe (for example tcp/ip), put the object at
one side and load it on other, one-by-one, and caching and links will be
restored properly.

Initially, this protocol was intended to be used in secure communications. Its
main goal was to very effective data sending and is a great replacement for
json/boss/whatever. For example, typical JSON reduces in size twice with Boss.

Boss protocol also allow to transparently compress its representations.

Boss also supports "stream mode" that lacks tree reconstruction but could be
effectively use when implementing long-living streams (e.g. stream protocols).
In regular mode it causes unlimited cache grows as Boss would try to reconstruct
all possible references to already serialized objects. In the stream mode only
strings are cached, and cache size and capacity are dynamically limited.
Boss writes stream mode marker and handles stream mode on receiving end
automatically.

Supported types:

 * Signed integers of any length
 * Signed floats and doubles (4 or 8 bytes)
 * Boolean values (true/false)
 * UTF-8 encoded texts, any length
 * Binary data, any length
 * Time objects (date and time with 1 second resolution)
 * Arrays with any number of elements of any type
 * Hashes with any keys and values and unlimited length
 * Reference to the object that already was serialized (unless in stream mode)

There is a working JAVA implemetation also.

## Installation

Add this line to your application's Gemfile:

    gem 'boss-protocol'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install boss-protocol

## Simple Usage

    1.9.3-p327 :011 > require 'boss-protocol'
     => false
    1.9.3-p327 :012 > data = { 'test' => [1, 2, -1.22, 'great!'] }
     => {"test"=>[1, 2, -1.22, "great!"]}
    1.9.3-p327 :013 > x = Boss.dump data
     => "\x0F#test&\b\x109\x85\xEBQ\xB8\x1E\x85\xF3\xBF3great!"
    1.9.3-p327 :014 > Marshal.dump data
     => "\x04\b{\x06I\"\ttest\x06:\x06ET[\ti\x06i\af\n-1.22I\"\vgreat!\x06;\x00T"

Note that boss representation is smaller than ruby's Marshal one

    1.9.3-p327 :015 > Boss.load(x) == data
     => true

To use the transparent compression:

    1.9.3-p327 :013 >   data = "Boss is a very effective protocol!" * 4096; nil
     => nil
    1.9.3-p327 :014 > data.length
     => 139264
    1.9.3-p327 :015 > x = Boss.dump_compressed(data); nil
     => nil
    1.9.3-p327 :016 > x.length
     => 147
    1.9.3-p327 :017 > data == Boss.load(x)
     => true

## Streaming sample

Boss can work with any stream-like object^ e.g. pipe, file stringIO, whatever that 
provides #eof? #read and #write methods. If the stream supprts #readbyte, it will be used instead.

This sample shows boss object hierarchies passing between 2 forked processes
using a pipe (see samples/):

    if fork
      wr.close
      if true
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
      out << { "That's all" => "folks!" }
      wr.close
    end

Both ways in the sample are identical; second one (with get) may be sometimes
more convenient, say, to terminate object polling on some condition before eof.

All you need is IO-like object that provide io.read(length) on the read side
and io.write(data) on another, capable to read/write binary data. Usual files,
pipes, tcp sockets, stringIO - everything is ok.

The protocol could be very effectively used to form higher level protocols over the
network as it caches data on the fly and can provide links (if used with

## Note about caching objects

When reconstructing object tree, cache is used for strings. As ruby language hash
mutable strings, it might cause side effects, as all ecounters of a given string
will share same object after reconstruction. For this reason, ruby implementation
freezes shared strings.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
