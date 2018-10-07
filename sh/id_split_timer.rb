
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

  # setup all dirs... using r10 for each level
  # write known file into each final r10 dirs

  all_dirs = [ tmp ]
  r10_dirs = [ tmp ]


  # TODO: all parts in split
  digits = split[0]                                      # eg 2
  sss = (0...10**digits)     .map{ |n| zerod(n,digits) } # eg [00..99]
  r10 = (0...10).to_a.shuffle.map{ |n| zerod(n,digits) } # eg [00..09]

  all_dirs = splice(all_dirs, sss)
  r10_dirs = splice(r10_dirs, r10)

  #puts all_dirs.inspect

  # return only those dirs that exist and have file in them
  r10_dirs
end

# - - - - - - - - - - - - - - - - - - - - - - -

def zerod(n, digits)
  "%0#{digits}d" % n
end

def splice(lhs,rhs)
  lhs.map{|a| rhs.map{|b| a+'/'+b }}.flatten(1)
end

# - - - - - - - - - - - - - - - - - - - - - - -

def read(dir)
  sleep 0.01
end

def write(dir)
  sleep 0.02
end

def exists?(dir)
  sleep 0.001
end

# - - - - - - - - - - - - - - - - - - - - - - -

def average_of(times)
  times.reduce(:+) / times.size.to_f
end

# - - - - - - - - - - - - - - - - - - - - - - -

def split_times(splits)
  Hash[splits.map { |split|
    times = setup_dirs(split).map { |dir|
      STDOUT.print('.')
      STDOUT.flush
      timed { yield dir }
    }
    [split,'%.06f' % average_of(times)]
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
