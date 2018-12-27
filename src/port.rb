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

def disk
  externals.disk
end

# - - - - - - - - - - - - - - - - - - - - -

def port_one(id10)
  begin
    id6 = porter.port(id10)
    if id10[0..5] == id6
      return 'P'
    else
      return 'M'
    end
  rescue => error
    disk['/porter/raised-ids'].write(id10, error.message)
    return 'E'
  end
end

# - - - - - - - - - - - - - - - - - - - - -

def port_many(id2)
  counts = { 'P' => 0, 'M' => 0, 'E' => 0 }
  print "#{id2}:"
  storer.katas_completions(id2).each do |id8|
    pme = port_one(id2+id8)
    counts[pme] += 1
    print pme
  end
  print "\n"
  puts "P(#{counts['P']}),M(#{counts['M']}),E(#{counts['E']})"
  counts
end

# - - - - - - - - - - - - - - - - - - - - -

def port_all
  # Can't use sample_id2 because 2-digit outer-dir
  # is still left after all the katas inside
  # it have been ported and then removed.
  alphabet = Base58.alphabet
  max = alphabet.size * alphabet.size
  count = 0
  alphabet.each_char do |c1|
    alphabet.each_char do |c2|
      count += 1
      id2 = c1 + c2
      percent = (count / max * 100).to_i
      print "~#{percent}%:"
      port_many(id2)
    end
  end
end

# - - - - - - - - - - - - - - - - - - - -

args = {}
case ARGV[0]
  when '--id10' then args[:id_10] = true
  when '--id2'  then args[:id_2 ] = true
  when '--all'  then args[:all  ] = true
  else               args[:error] = true
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
    pme = port_one(id10)
    print pme
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
