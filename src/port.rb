
puts "Hello from port.rb #{ARGV[0]}"

# The main entry-point, from the shell

# ruby port.rb id-10 => port_one(id-10)

# ruby port.rb id-2 => port_many(id-2)
#    use kata_completions(id-2)

# ruby port.rb      => port_all
#    use all 58x58 generated id-2's

# - - - - - - - - - - - - - - - - - - - - -
# port and individual id
# if ok
#    print P
# if an exeption
#    print E and add id info to json? file (named from date+time)
# if id-mapped
#    print M and add id info to json? file (named from date+time)
