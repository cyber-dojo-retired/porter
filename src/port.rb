require_relative 'externals'

# - - - - - - - - - - - - - - - - - - - - -
# if E(exeption) or M(id-mapped)
#    porter.rb (not this) will add id info (to json? file, named from date+time?)

def externals
  Externals.new
end

def porter
  externals.porter
end

def storer
  externals.storer
end

#def saver
#  externals.saver
#end

# - - - - - - - - - - - - - - - - - - - - -

def port_one_sample
  sample = storer.sample_id10
  if sample.nil?
    STDERR.puts('ERROR: storer is empty!')
    STDERR.flush
    exit(11)
  else
    STDOUT.puts(sample)
    STDOUT.flush
  end
end

def port_one(id10)
#  check id10 well-formed, else error 12
#  check id10 exists in storer, else error 13
#  porter.port_one(id10)
#  print P/E/M
end

# - - - - - - - - - - - - - - - - - - - - -

def port_many_sample
  sample = storer.sample_id2
  if sample.nil?
    STDERR.puts('ERROR: storer is empty!')
    STDERR.flush
    exit(14)
  else
    STDOUT.puts(sample)
    STDOUT.flush
  end
end

def port_many(id2)
#  check id2 well-formed, else error 15
#  check id2 exists in storer, else error 16 ???
#  print "#{id2}:"
#  kata_completions(id2).each do |id10|
#    port_one(id10)
#  end
end

# - - - - - - - - - - - - - - - - - - - - -

def port_all
#  use all 58x58 generated id-2's.each do |id2|
#    print percentage:
#    port_many(id2)
#  end
end

# - - - - - - - - - - - - - - - - - - - -

args = {}
case ARGV[0]
  when '--id10' then args[:id_10 ] = true
  when '--id2'  then args[:id_2  ] = true
  when '--all'  then args[:id_all] = true
  else               args[:error ] = true
end

if args[:error]
  STDERR.puts("ERROR: unknown arg <#{ARGV[0]}>")
  STDERR.flush
  exit(10)
end

if args[:id_10]
  id10 = ARGV[1]
  if id10.nil?
    port_one_sample
  else
    port_one(id10)
  end
end

if args[:id_2]
  id2 = ARGV[1]
  if id2.nil?
    port_many_sample
  else
    port_many(id2)
  end
end

if args[:all]
  port_all
end
