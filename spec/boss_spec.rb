# encoding: utf-8

require 'spec_helper'
require 'json'
require 'zlib'
require 'base64'
require 'boss-protocol'

describe 'Boss' do

  it 'should perform compatible encode' do
    Vectors.each do |a, b|
      Boss.load(a).should == b
    end
  end

  it 'should perform compatible decode' do
    Vectors.each do |a, b|
      Boss.load(a).should == b
    end
  end

  it 'should properly encode positive and negative floats' do
    round_check 0
    round_check 1.0
    round_check -1.0
    round_check 2.0
    round_check -2.0
    round_check 1.11
    round_check -1.11
  end

  it 'should encode booleans' do
    round_check true
    round_check false
  end

  it 'should properly encode nil' do
    round_check(1)
    round_check(nil)
    round_check([1])
    round_check([nil, nil, nil, 3, 4, 5, nil])
  end

  it 'should encode Time' do
    # Time is rounded to seconds on serialization, so we need
    # take care of the comparison
    t = Time.now
    Boss.load(Boss.dump t).should be_within(1).of(t)
  end

  it 'should cache data' do
    a                = [1, 2, 3, 4]
    ca               = { 1 => 55 }
    b, c, d, e, f, g = Boss.load(Boss.dump([a, a, ca, ca, "oops", "oops"]))
    a.should == b
    b.should == c
    b.should be_eql(c)

    ca.should == d
    ca.should == e
    d.should be_equal(e)

    f.should == "oops"
    g.should == f
    g.should be_frozen
    g.should be_equal(f)
  end

  it 'should properly encode very big integers' do
    val = 1<<1024 * 7 + 117
    round_check val
  end

  it 'should decode one by one using block' do
    args = [1, 2, 3, 4, 5]
    s    = Boss.dump(*args)
    res  = []
    res  = Boss.load(s) { |x| x }
    args.should == res
  end

  it 'should cache arrays and hashes too' do
    d = { "Hello" => "world" }
    a = [112, 11]
    r = Boss.load_all(Boss.dump(a, d, a, d))
    [a, d, a, d].should == r
    r[1].should be_equal(r[3])
    r[0].should be_equal(r[2])
  end

  it 'should properly encode multilevel structures' do
    root = { "level" => 1 }
    p    = root
    200.times { |n|
      x            = { "level" => n+2 }
      p['data']    = x
      p['payload'] = 'great'
      p            = x
    }
    round_check root
  end

  it 'shold encode hash/array ancestors too' do
    class MyHash < Hash
      def []= k, v
        super k.to_s, v.to_s
      end
    end

    class MyArray < Array
      def []= i, val
        super i.to_i, val.to_s
      end
    end

    h       = MyHash.new
    h[:one] = 1
    h[:two] = 2
    round_check h

    a      = MyArray.new
    a["0"] = :zero
    a["1"] = :one
    round_check a

  end

  it 'should effectively compress/decompress' do
    # No compression
    data = "Too short"
    x0   = Boss.dump_compressed data
    Boss.load(x0).should == data
    x0.length.should <= (data.length + 3)

    # short compression: zlib
    data = "z" * 1024
    x1   = Boss.dump_compressed data
    Boss.load(x1).should == data
    x1.length.should <= (data.length/10)

    # hevay compression on big data
    #data = JSON.parse(Zlib::Inflate.new(Zlib::MAX_WBITS).inflate(Base64::decode64(CompressedTestJson)))
    #round_check data
    #x2 = Boss.dump_compressed(data)
    #Boss.load(x2).should == data
    #x2.length.should < 13700
  end

  it 'should raise proper error' do
    class MyObject;
    end
    -> { Boss.dump MyObject.new }.should raise_error(Boss::NotSupportedException)
  end

  it 'should implement stream mode' do
    out = Boss::Formatter.new
    out.stream_mode 3, 10
    3.times { out << "String too long" }
    (1..6).each { |n| out << "test#{n}" }
    (4..6).each { |n| out << "test#{n}" }
    (4..6).each { |n| out << "test#{n}" }
    out << "test7"

    res = "\x81\x18P{String too long{String too long{String too long+test1+test2+test3+test4+test5+test6\r\x15\x1D\r\x15\x1D+test7"
    res.force_encoding 'binary'
    out.string.should == res

    inp = Boss::Parser.new out.string

    3.times { inp.get.should == "String too long" }
    (1..6).each { |n| inp.get.should == "test#{n}" }
    (4..6).each { |n| inp.get.should == "test#{n}" }
    (4..6).each { |n| inp.get.should == "test#{n}" }
    inp.get.should == "test7"

    #src2 = "gRhQe1N0cmluZyB0b28gbG9uZ3tTdHJpbmcgdG9vIGxvbmd7U3RyaW5nIHRvbyBsb25nK3Rlc3QxK3Rlc3QyK3Rlc3QzK3Rlc3Q0K3Rlc3Q1K3Rlc3Q2DRUdDRUdK3Rlc3Q3"
  end

  it 'should work fine with big stream mode' do
    out = Boss::Formatter.new
    out.stream_mode 7, 500
    src = 4096.times.map { |n| s="Long string #{n}"; out << s; s }
    inp = Boss::Parser.new out.string
    src.each { |s| inp.get.should == s }
  end

  it 'should parse following code' do
    src    = 'gcAAAcAAAbwgn0XEfzTatIn6O75xqrvA5yOMHfndd8G1SiIyOj057yZzc3Rh
    cnQgY29tbWFuZDMfQ3RvU2VyaWFsACNkYXRhDzNhbnN3ZXIjcG9uZzNzZXJp
    YWwAHx0IJQ8rZmlsZXMWJyNuYW1lKzRoZXJvM2lzX2RpcmEjc2l6ZbiIK210
    aW1leTZGWxaFJ02LQWRyaWFubyBDZWxlbnRhbm9dYWW4iG15O0ZbFoU9CA=='
    parser = Boss::Parser.new(Base64::decode64 src)
    out    = []
    begin
      loop {
        out << (x=parser.get)
      }
    rescue EOFError
    end
    x=out[-1]
    x['toSerial'].should == 1
    x['serial'].should == 1
    x['data']['files'].length.should == 2
  end

  def round_check(ob)
    ob.should == Boss.load(Boss.dump(ob))
  end


  ##
  # Set (force) string str encoding to binary
  def self.bytes!(str)
    str.force_encoding Encoding::BINARY
    str
  end

  Vectors = [['8', 7], ["\xb8F", 70], [".\x00\x08\n8:", [0, 1, -1, 7, -7]], ["\xc8p\x11\x01", 70000],
             ['+Hello', 'Hello'], [',Hello', bytes!('Hello'), 2, 4, 4, 1]]

  CompressedTestJson = <<-End
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
  End

end