
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Given a 6-digit ID what is the best way to map that ID
# into a dir structure to achieve fastest read/writes?
# eg given id == 'ejdqsc'
# 3/3   -> 'ejd/qsc'
# 2/2/2 -> 'ej/dq/sc'
# etc
#
# On the one hand, 3/3 means fewer dirs (2), but
# more entries to look through at each dir (10^3==1000)
#
# On the other hand, 2/2/2 means more dirs (3), but
# less entries to look though at each dir (10^2==100)
#
# This program gathers data to help make a decision.
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# n is the number of digits in the ID
$n = ARGV[1].to_i

# max is the maximum number of dirs to create at a given 'level'.
# For example, suppose a split of 6 being timed is 5/1
# then given an alphabet of 0..9 there are
# 10^5 == 100000 possible dirs for the initial 5-digit dir
# but creating this many dirs takes ages and might fill the disk.
# So max=1000 would reduce 10^5 down to 1000
$max = ARGV[2].to_i

# sample is the number of dirs, at each level, to keep 'alive'.
# For example, suppose a split of 6 is 3/3
# then assuming an alphabet of 0..9
# at the first level there are 1000 dirs (assuming max >= 1000).
# A sample of 5 means only 5 of these dirs are selected to
# become the base-dir for the dirs at the 2nd level.
# This would result in dirs that are created and actually
# contain a file, of
# 000/000, 000/001, 000/002, 000/003, 000/004
# 001/000, 001/001, 001/002, 001/003, 001/004
# 002/000, 002/001, 002/002, 002/003, 002/004
# 003/000, 003/001, 003/002, 003/003, 003/004
# 004/000, 004/001, 004/002, 004/003, 004/004
# This value must be kept quite low.
# A value of 10 for example, would result in
# 6 -> 1/1/1/1/1/1 creating 10^6 dirs
$sample = ARGV[3].to_i

# = = = = = = = = = = = = = = = = = = = = = =

$all_dir_names = []

def all_dir_names(n)
  # eg n==1 --> [0..9]
  # eg n==2 --> [00..99]
  # eg n==3 --> [000..999]
  $all_dir_names[n] ||= make_all_dir_names(n).shuffle
end

# - - - - - - - - - - - - - - - - - - - - - - -

def make_all_dir_names(digits)
  max = [10**digits, $max].min
  (0...max).map{ |n| zerod(n, digits) }
end

# - - - - - - - - - - - - - - - - - - - - - - -

def zerod(n, digits)
  "%0#{digits}d" % n
end

# = = = = = = = = = = = = = = = = = = = = = =




# = = = = = = = = = = = = = = = = = = = = = =

def partitions(n, max = n)
  # See https://stackoverflow.com/questions/10889379
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
  tmp = ARGV[0] + "/id_splits"
  `rm -rf #{tmp} && mkdir -p #{tmp}`

  sample_dirs = [ tmp ]

  split.each do |digits|
    all_dirs = splice(sample_dirs, all_dir_names(digits))
    all_dirs.each { |dir| `mkdir #{dir}` }

    samples = (0...$sample).to_a
                     .shuffle
                     .map{ |n| zerod(n, digits) }

    sample_dirs = all_dirs.select{ |dir|
      samples.any?{ |sample| dir.end_with?(sample) }
    }
  end

  sample_dirs.each{ |dir| IO.write(dir + '/info.txt', 'hello') }
  sample_dirs
end

# - - - - - - - - - - - - - - - - - - - - - - -

def splice(lhs,rhs)
  lhs.map do |a|
    rhs.map do |b|
      print_dot
      a + '/' + b
    end
  end.flatten(1)
end

# - - - - - - - - - - - - - - - - - - - - - - -

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
  IO.read(dir+'/info.txt')
end

def write(dir)
  IO.write(dir+'/info.txt', 'blah blah')
end

def exists?(dir)
  File.directory?(dir)
end

# - - - - - - - - - - - - - - - - - - - - - - -

def average_of(times)
  mean = times.reduce(:+) / times.size.to_f
  '%.07f' % mean
end

# - - - - - - - - - - - - - - - - - - - - - - -

def show_times(name, splits)
  puts "\n#{name}\n"
  splits.sort_by { |_split,time| time }
        .each { |split,time|
           t = '%.07f' % time.to_f
           puts "#{t} <-- #{split}"
           # eg 0.020310 <-- [1, 1, 2]
        }
end

# - - - - - - - - - - - - - - - - - - - - - - -

puts("n=#{$n}")
puts("max=#{$max}")
puts("sample=#{$sample}")

splits = partitions($n).collect{ |p| p.permutation
                                     .sort
                                     .uniq }
                      .flatten(1)

$exists_times = {}
$read_times = {}
$write_times = {}

splits.each do |split|
  sample_dirs = setup_dirs(split)

  times = sample_dirs.map{ |dir| timed { exists?(dir) }}
  time = average_of(times)
  $exists_times[split] = time

  times = sample_dirs.map{ |dir| timed { read(dir) }}
  time = average_of(times)
  $read_times[split] = time

  times = sample_dirs.map{ |dir| timed { write(dir) }}
  time = average_of(times)
  $write_times[split] = time
end

show_times('exists?', $exists_times)
show_times('read',    $read_times)
show_times('write',   $write_times)

$all_times = {}
$exists_times.each{|split,time| $all_times[split]  = time.to_f }
$read_times  .each{|split,time| $all_times[split] += time.to_f }
$write_times .each{|split,time| $all_times[split] += time.to_f }

show_times('all', $all_times)
