
def partitions(n, max = n)
  if n == 0
    [[]]
  else
    [max, n].min.downto(1).flat_map do |i|
      partitions(n-i, i).map{ |rest| [i, *rest] }
    end
  end
end

# - - - - - - - - - - - - - - - - - - - - - - -

def timed
  started = Time.now
  yield
  finished = Time.now
  finished - started
end

# - - - - - - - - - - - - - - - - - - - - - - -

def setup_dirs(one)
  # eg one = [3,2,1]
  r10 = (0..10).to_a.shuffle
  # do dirs setup... using r10 for each level
  # write known file into each dir

  # digits = 2
  # (0..10).to_a.shuffle.map{ |n| "%0#{digits}d" % n }

  [ '/tmp/000/07/9', '/tmp/009/01/4' ]
end

# - - - - - - - - - - - - - - - - - - - - - - -

def average_of(all)
  all.reduce(:+) / all.size.to_f
end

# = = = = = = = = = = = = = = = = = = = = = = =

def timed_reads(all)
  Hash[all.map {|one| [one,timed_read(one)] }]
end

# - - - - - - - - - - - - - - - - - - - - - - -

def timed_read(one)
  # eg one = [3,2,1]
  times = setup_dirs(one).map { |dir_name| timed { do_read(dir_name) }}
  average_of(times)
end

def do_read(dir_name)
  sleep 0.01
end

# - - - - - - - - - - - - - - - - - - - - - - -

n = ARGV[0].to_i
puts "Hello, world #{n}"

all = partitions(n)
puts all.inspect

results = timed_reads(all)
puts results.inspect


# read
# write
# existence