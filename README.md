# Boss Protocol

BOSS is acronym for Binary Object Streamable Storage.

The very space-effective, platfomr-independent streamable and traversable typed binary protocol.
Allow to effectively store small or
any
sized
integers, strings or binary data of any size, floats and doubles, arrays and hashes in a very effective way. It caches
repeating objects and stores/restores links to objects.

Streamable means that you can use a pipe (tcp/ip, wahtever), put the object at one side and load it on other, one-by-one,
and caching and links will be restored properly.

Initially, this protocol was intended to be used in secure communications. Its
main goal was to very effective data sending and is a great replacement for json/boss/whatever. For example, typical
JSON reduces in size twice with Boss.

Boss protocol also allow to transparently compress its representations.

*Attention* ruby version is under final development, its streaming support may not work as expected, while the rest
seem to work just fine.

There are versions in C and Python that are in most part ready.

## Installation

Add this line to your application's Gemfile:

    gem 'boss-protocol'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install boss-protocol

## Usage

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

Streaming docs are in progress. Please wait.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
