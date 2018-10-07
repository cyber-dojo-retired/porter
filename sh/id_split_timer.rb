
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
  result = yield
  finished = Time.now
  duration = '%.4f' % (finished - started)
  [result,duration]
end

# - - - - - - - - - - - - - - - - - - - - - - -

def timed_reads(all)
  Hash[all.map {|one| [one,timed_read(one)] }]
end

# - - - - - - - - - - - - - - - - - - - - - - -

def timed_read(one)
  # eg one = [3,2,1]
  # do setup...
  result,duration = timed {
    sleep 0.01
  }
  duration
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