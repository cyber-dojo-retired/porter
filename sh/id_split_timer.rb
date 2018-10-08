
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

def id_size
  # The number of digits in the ID
  ARGV[1].to_i
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def all_max
  # The maximum number of dirs to create at a given 'level'.
  # For example, suppose a split of 6 being timed is 5/1
  # then given an alphabet of 0..9 there are
  # 10^5 == 100000 possible dirs for the initial 5-digit dir
  # but creating this many dirs takes ages and might fill the disk.
  # So max=1000 would reduce 10^5 down to 1000
  ARGV[2].to_i
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def sample_max
  # The number of dirs, at each level, to keep 'alive'
  # for the next level.
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
  ARGV[3].to_i
end

# = = = = = = = = = = = = = = = = = = = = = =

$cache_all_dir_names = []

def all_dir_names(n)
  # eg n==1 --> [0..9]
  # eg n==2 --> [00..99]
  # eg n==3 --> [000..999]
  $cache_all_dir_names[n] ||= make_all_dir_names(n).shuffle
end

# - - - - - - - - - - - - - - - - - - - - - - -

def make_all_dir_names(digits)
  max = [10**digits, all_max].min
  make_dir_names(max, digits)
end

# = = = = = = = = = = = = = = = = = = = = = =

$cache_sample_dir_names = []

def sample_dir_names(n)
  $cache_sample_dir_names[n] ||= make_sample_dir_names(n).shuffle
end

def make_sample_dir_names(digits)
  make_dir_names(sample_max, digits)
end

def make_dir_names(max, digits)
  (0...max).map{ |n| "%0#{digits}d" % n }
end

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
    sample_dirs = all_dirs.select{ |dir| in_sample?(dir, digits) }
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

def in_sample?(dir, digits)
  sample_dir_names(digits).any?{ |sample|
    dir.end_with?(sample)
  }
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
  IO.write(dir+'/info.txt', 'blah '*100)
end

def exists?(dir)
  File.directory?(dir)
end

# - - - - - - - - - - - - - - - - - - - - - - -

def average_of(times)
  '%.07f' %  (times.reduce(:+) / times.size.to_f)
end

# - - - - - - - - - - - - - - - - - - - - - - -

def show_sorted_times(name, split_times)
  puts "\n#{name}\n"
  split_times.sort_by { |_split,time| time }
        .each { |split,time|
           t = '%.07f' % time.to_f
           puts "#{t} <-- #{split}"
           # eg 0.020310 <-- [1, 1, 2]
        }
end

# - - - - - - - - - - - - - - - - - - - - - - -

def gather_times(splits)
  times = { e:{}, r:{}, w:{} }
  splits.each do |split|
    times[:e][split] = []
    times[:r][split] = []
    times[:w][split] = []

    sample_dirs = setup_dirs(split)
    sample_dirs.each{ |dir|
      times[:e][split] << timed { exists?(dir) }
      times[:r][split] << timed {    read(dir) }
      times[:w][split] << timed {   write(dir) }
    }
  end
  times
end

# - - - - - - - - - - - - - - - - - - - - - - -

def gather_averages(splits, times)
  averages = { e:{}, r:{}, w:{}, a:{} }
  splits.each do |split|
    et = times[:e][split]
    rt = times[:r][split]
    wt = times[:w][split]

    averages[:e][split] = average_of(et)
    averages[:r][split] = average_of(rt)
    averages[:w][split] = average_of(wt)
    averages[:a][split] = average_of(et + rt + wt)
  end
  averages
end

# - - - - - - - - - - - - - - - - - - - - - - -

puts("id_size=#{id_size}")
puts("all_max=#{all_max}")
puts("sample_max=#{sample_max}")

splits = partitions(id_size).collect{ |p| p.permutation
                                     .sort
                                     .uniq }
                      .flatten(1)

$times = gather_times(splits)
$averages = gather_averages(splits, $times)

# - - - - - - - - - - - - - - - - - - - - - - -

show_sorted_times('exists?', $averages[:e])
show_sorted_times('read',    $averages[:r])
show_sorted_times('write',   $averages[:w])
show_sorted_times('all',     $averages[:a])
