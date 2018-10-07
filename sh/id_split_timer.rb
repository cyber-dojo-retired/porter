
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

def setup_dirs(split)
  # eg split = [3,2,1]
  tmp = ARGV[0] + '/id_splits'
  `rm -rf #{tmp}`

  all_dirs = [ tmp ]
  r10_dirs = [ tmp ]
  split.each do |digits|
    sss = (0...10**digits)     .map{ |n| zerod(n,digits) } # eg [00..99]
    r10 = (0...10).to_a.shuffle.map{ |n| zerod(n,digits) } # eg [00..09]
    all_dirs = splice(all_dirs, sss)
    r10_dirs = splice(r10_dirs, r10)
  end

  # TODO: create all_dirs

  # TODO: write known file into each r10 dirs

  #puts "#{split}==> #{all_dirs.size}"

  # return only those dirs that exist and have file in them
  r10_dirs
end

# - - - - - - - - - - - - - - - - - - - - - - -

def zerod(n, digits)
  "%0#{digits}d" % n
end

def splice(lhs,rhs)
  lhs.map do |a|
    rhs.map do |b|
      print_dot
      a + '/' + b
    end
  end.flatten(1)
end

$tally = 0

def print_dot
  $tally += 1
  if $tally % 1000 == 0
    STDOUT.print('.')
    STDOUT.flush
  end
end

# - - - - - - - - - - - - - - - - - - - - - - -

def read(dir)
  sleep 0.00001
end

def write(dir)
  sleep 0.00002
end

def exists?(dir)
  sleep 0.00001
end

# - - - - - - - - - - - - - - - - - - - - - - -

def average_of(times)
  times.reduce(:+) / times.size.to_f
end

# - - - - - - - - - - - - - - - - - - - - - - -

def split_times(splits)
  Hash[splits.map { |split|
    times = setup_dirs(split).map { |dir|
      timed { yield dir }
    }
    [split, '%.06f' % average_of(times)]
  }]
end

# - - - - - - - - - - - - - - - - - - - - - - -

def show_times(name, splits)
  puts "\n#{name}\n"
  splits.sort_by { |_split,time| time }
        .each { |split,time|
           puts "#{time} <-- #{split}"
           # eg 0.020310 <-- [1, 1, 2]
        }
end

# - - - - - - - - - - - - - - - - - - - - - - -

n = ARGV[1].to_i
splits = partitions(n).collect{ |p| p.permutation
                                     .sort
                                     .uniq }
                      .flatten(1)

STDOUT.puts("split times for #{n}")
show_times('exists?', split_times(splits) {|dir| exists?(dir) })
show_times('read',    split_times(splits) {|dir| read(dir) })
show_times('write',   split_times(splits) {|dir| write(dir) })
