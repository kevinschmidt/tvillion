class Test
  def test()
    puts "hello world"
  end
end

if __FILE__ == $0
  t = Test.new()
  t.test
end