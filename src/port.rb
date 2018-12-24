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

def saver
  externals.saver
end

# - - - - - - - - - - - - - - - - - - - - -

def arg
  ARGV[0]
end

def port_sample_id10
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

def port_sample_id2
end

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

# - - - - - - - - - - - - - - - - - - - -

args = {}
ARGV.each do |arg|
  case arg
  when '--id10'           then args[:id_10] = true
    else
      args[:error] = true
      STDERR.puts("ERROR: unknown arg <#{arg}>")
      STDERR.flush
  end
end

if args[:error]
  exit(10)
end

if args[:id_10]
  port_sample_id10
end
