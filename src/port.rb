$stdout.sync = true
$stderr.sync = true

require_relative 'base58'
require_relative 'externals'

# - - - - - - - - - - - - - - - - - - - - -

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

def already_ported?(id10)
  id2 = id10[0..1]
  id8 = id10[2..-1]
  disk["/porter/mapped-ids/#{id2}"].exists?(id8)
end

# - - - - - - - - - - - - - - - - - - - - -

def port_one(id10)
  if already_ported?(id10)
    return 'a'
  end
  begin
    id6 = porter.port(id10)
    if id10[0..5] == id6
      return 'P'
    else
      return 'M'
    end
  rescue => error
    disk['/porter/raised-ids'].write(id10, error.message)
    return 'e'
  end
end

# - - - - - - - - - - - - - - - - - - - - -

def port_many(id2, msg_prefix)
  counts = { 'P' => 0, 'M' => 0, 'e' => 0, 'a' => 0 }
  many = storer.katas_completions(id2).sort
  if many.size > 0
    STDOUT.print(msg_prefix)
    STDOUT.print("#{id2}:")
    many.each do |id8|
      pme = port_one(id2+id8)
      counts[pme] += 1
      STDOUT.print(pme)
    end
    STDOUT.print("\n")
    STDOUT.puts("P(#{counts['P']}),M(#{counts['M']}),e(#{counts['e']}),a(#{counts['a']})")
  end
  counts
end

# - - - - - - - - - - - - - - - - - - - - -

def port_all
  # Can't use sample_id2 because 2-digit outer-dir
  # is still left after all the katas inside
  # it have been ported and then removed.
  counts = { 'P' => 0, 'M' => 0, 'e' => 0, 'a' => 0 }
  alphabet = Base58.alphabet
  max = alphabet.size * alphabet.size
  count = 0
  alphabet.each_char do |c1|
    alphabet.each_char do |c2|
      count += 1
      id2 = c1 + c2
      percent = (count * 100 / max).to_i
      id2_counts = port_many(id2, "~#{percent}%:")
      counts['P'] += id2_counts['P']
      counts['M'] += id2_counts['M']
      counts['e'] += id2_counts['e']
      counts['a'] += id2_counts['a']
    end
  end
  STDOUT.puts("total: P(#{counts['P']}),M(#{counts['M']}),e(#{counts['e']}),a(#{counts['a']})")
  counts
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
  exit(10)
end

if storer.sample_id2.nil?
  STDOUT.puts('storer is empty')
  exit(0)
end

# - - - - - - - - - - - - - - - - - - - -

if args[:id_10]
  id10 = ARGV[1]
  if id10.nil?
    STDOUT.puts(storer.sample_id10)
  else
    unless Base58.string?(id10)
      STDERR.puts("ERROR: malformed id10 <#{id10}> (!Base58)")
      exit(11)
    end
    unless id10.size == 10
      STDERR.puts("ERROR: malformed id10 <#{id10}> (size==#{id10.size} !10)")
      exit(12)
    end
    if already_ported?(id10)
      STDOUT.print('a')
      exit(0)
    end
    unless storer.kata_exists?(id10)
      STDERR.puts("ERROR: id10 <#{id10}> does not exist")
      exit(13)
    end
    pme = port_one(id10)
    STDOUT.print(pme)
  end
end

# - - - - - - - - - - - - - - - - - - - -

if args[:id_2]
  id2 = ARGV[1]
  if id2.nil?
    STDOUT.puts(storer.sample_id2)
  else
    unless Base58.string?(id2)
      STDERR.puts("ERROR: malformed id2 <#{id2}> (!Base58)")
      exit(14)
    end
    unless id2.size == 2
      STDERR.puts("ERROR: malformed id2 <#{id2}> (size==#{id2.size} !2)")
      exit(15)
    end
    if storer.katas_completions(id2) == []
      STDERR.puts("ERROR: id2 <#{id2}> does not exist")
      exit(16)
    end
    port_many(id2, '')
  end
end

# - - - - - - - - - - - - - - - - - - - -

if args[:all]
  port_all
end
