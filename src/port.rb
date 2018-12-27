require_relative 'base58'
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

# - - - - - - - - - - - - - - - - - - - - -

def port_one(id10)
  porter.port(id10)
  print 'P'  # E/M
end

def port_many(id2)
#  print "#{id2}:"
#  storer.kata_completions(id2).each do |id10|
#    port_one(id10)
#  end
end

def port_all
#  max = 58*58
#  count = 1
#  while !(id2 = storer.sample_id2).nil?
#    percent = (count / max * 100).to_i
#    print "~#{percent}%:"
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

# - - - - - - - - - - - - - - - - - - - -

if args[:error]
  STDERR.puts("ERROR: unknown arg <#{ARGV[0]}>")
  STDERR.flush
  exit(10)
end

if storer.sample_id2.nil?
  STDOUT.puts('storer is empty')
  STDOUT.flush
  exit(0)
end

# - - - - - - - - - - - - - - - - - - - -

if args[:id_10]
  id10 = ARGV[1]
  if id10.nil?
    STDOUT.puts(storer.sample_id10)
    STDOUT.flush
  else
    unless Base58.string?(id10)
      STDERR.puts("ERROR: malformed id10 <#{id10}> (!Base58)")
      STDERR.flush
      exit(11)
    end
    unless id10.size == 10
      STDERR.puts("ERROR: malformed id10 <#{id10}> (size==#{id10.size} !10)")
      STDERR.flush
      exit(12)
    end
    unless storer.kata_exists?(id10)
      STDERR.puts("ERROR: id10 <#{id10}> does not exist")
      STDERR.flush
      exit(13)
    end
    port_one(id10)
  end
end

# - - - - - - - - - - - - - - - - - - - -

if args[:id_2]
  id2 = ARGV[1]
  if id2.nil?
    STDOUT.puts(storer.sample_id2)
    STDOUT.flush
  else
    unless Base58.string?(id2)
      STDERR.puts("ERROR: malformed id2 <#{id2}> (!Base58)")
      STDERR.flush
      exit(14)
    end
    unless id2.size == 2
      STDERR.puts("ERROR: malformed id2 <#{id2}> (size==#{id2.size} !2)")
      STDERR.flush
      exit(15)
    end
    if storer.katas_completions(id2) == []
      STDERR.puts("ERROR: id2 <#{id2}> does not exist")
      STDERR.flush
      exit(16)
    end
    port_many(id2)
  end
end

# - - - - - - - - - - - - - - - - - - - -

if args[:all]
  port_all
end
