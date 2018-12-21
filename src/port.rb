require_relative 'externals'

# - - - - - - - - - - - - - - - - - - - - -
# if E(exeption) or M(id-mapped)
#    porter.rb (not this) will add id info to json? file (named from date+time?)

def externals
  Externals.new
end

def porter
  externals.porter
end

def storer
  externals.storer
end

def saver
  externals.saver
end

def arg
  ARGV[0]
end

puts "Hello from port.rb #{arg}"
puts "porter.sha==#{externals.env.sha}"
puts "storer.sha==#{storer.sha}"
puts "saver.sha==#{saver.sha}"

def port_one # arg{id-10}
#    porter.port_one(id-10)
#    print P/E/M
end

def port_many # arg{id-2}
#    kata_completions(id-2).each
#      port_one()
end

def port_all # arg(all)
#    use all 58x58 generated id-2's.each
#      port_many()
end
