require 'json'

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

def cla(key, default)
  arg = ARGV.detect{ |arg| arg.start_with?("--#{key}=")}
  if arg
    arg.split('=')[1]
  else
    default
  end
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def id_size
  # The number of digits in the ID
  cla('id_size','6').to_i
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def all_max
  # The maximum number of dirs to create at a given 'level'.
  # For example, suppose a split of 6 being timed is 5/1
  # then given an alphabet of 0..9 there are
  # 10^5 == 100,000 possible dirs for the 'level-0' 5-digit dir
  # but creating this many dirs takes ages and might fill the disk.
  # So all_max=1000 would reduce 10^5 down to 1000
  cla('all_max','2000').to_i
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def alphabet
  '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

def sample_max
  # The number of dirs, at each level, to keep 'alive'
  # for the next level.
  # For example, suppose a split of 6 is 3/3
  # then assuming an alphabet of 0..9
  # at the first level there are 1000 dirs
  # (assuming all_max >= 1000).
  # A sample_max of 5 means only 5 of these dirs are selected to
  # become the base-dir for the dirs at the next level.
  # This would result in dirs that are created and actually
  # contain a file, of
  # 000/000, 000/001, 000/002, 000/003, 000/004
  # 001/000, 001/001, 001/002, 001/003, 001/004
  # 002/000, 002/001, 002/002, 002/003, 002/004
  # 003/000, 003/001, 003/002, 003/003, 003/004
  # 004/000, 004/001, 004/002, 004/003, 004/004
  # A large sample_max can easily fill up a disk.
  cla('sample_max','3').to_i
end

# = = = = = = = = = = = = = = = = = = = = = =

$cache_all_dir_names = []

def all_dir_names(digits)
  # eg digits==1 --> [0..9]
  # eg digits==2 --> [00..99]
  # eg digits==3 --> [000..999]
  $cache_all_dir_names[digits] ||=
    make_all_dir_names(digits)
end

# - - - - - - - - - - - - - - - - - - - - - - -

def make_all_dir_names(digits)
  max = [alphabet.size**digits, all_max].min
  (0...max).map { |n| zerod(n, digits) }
           .shuffle
end

def zerod(n,digits)
  base = alphabet.size
  res = ''
  loop do
    index = n % base
    letter = alphabet[index]
    res += letter
    n /= base
    break if n == 0
  end
  res += '0' * (digits - res.length)
  res.reverse
end

# = = = = = = = = = = = = = = = = = = = = = =

$cache_sample_dir_names = []

def sample_dir_names(digits)
  $cache_sample_dir_names[digits] ||=
    all_dir_names(digits).sample(sample_max)
end

# = = = = = = = = = = = = = = = = = = = = = =

def partitions(n, max = n)
  # See https://stackoverflow.com/questions/10889379
  if n == 0
    [[]]
  else
    [max, n].min.downto(1).flat_map do |i|
      partitions(n-i, i).map { |rest| [i, *rest] }
    end
  end
end

# - - - - - - - - - - - - - - - - - - - - - - -

def timed
  started = Time.now
  result = yield
  finished = Time.now
  duration = (finished - started)
  [duration,result]
end

# - - - - - - - - - - - - - - - - - - - - - - -

def sample_dirs(split)
  # eg split = [3,2,1]
  tmp =  '/tmp/id_splits'
  `rm -rf #{tmp} && mkdir -p #{tmp}`
  verbose('% 20s' % split.inspect+' ')
  sample = [ tmp ]
  split.each_with_index do |digits,index|
    verbose(" L#{index}(#{digits})")
    all_dirs = splice_dirs(sample, all_dir_names(digits)).flatten(1)
    make_dirs(all_dirs)
    sample = all_dirs.select { |dir| in_sample?(dir, digits) }
  end
  write_files(sample)
  verbose("\n")
  #verbose(sample[0].inspect)
  sample
end

# - - - - - - - - - - - - - - - - - - - - - - -

def splice_dirs(lhs, rhs)
  progress = ProgressBar.new('S', lhs.size * rhs.size)
  lhs.map do |a|
    rhs.map do |b|
      progress.show
      a + '/' + b
    end
  end
end

# - - - - - - - - - - - - - - - - - - - - - - -

def make_dirs(dirs)
  progress = ProgressBar.new('M', dirs.size)
  dirs.each do |dir|
    progress.show
    `mkdir #{dir}`
  end
end

# - - - - - - - - - - - - - - - - - - - - - - -

def write_files(dirs)
  progress = ProgressBar.new('W', dirs.size)
  dirs.each do |dir|
    progress.show
    IO.write(dir + '/info.txt', 'hello')
  end
  verbose("(#{dirs.size})")
end

# - - - - - - - - - - - - - - - - - - - - - - -

class ProgressBar
  def initialize(prefix,max)
    @prefix = prefix
    @max = max
    @count = 0
    verbose(percent)
  end
  def show
    @count += 1
    verbose(backspaced(percent))
  end
  private
  def percent
    ' ' + @prefix + (':%3d' % (@count / @max.to_f * 100).to_i) + '%'
  end
  def backspaced(msg)
    ("\b" * msg.length) + msg
  end
end

# - - - - - - - - - - - - - - - - - - - - - - -

def in_sample?(dir, digits)
  sample_dir_names(digits).any? { |sample|
    dir.end_with?(sample)
  }
end

# - - - - - - - - - - - - - - - - - - - - - - -

def verbose(s)
  STDOUT.print(s)
  STDOUT.flush
end

# - - - - - - - - - - - - - - - - - - - - - - -

def average_of(times)
  '%.07f' %  (times.reduce(:+) / times.size.to_f)
end

# - - - - - - - - - - - - - - - - - - - - - - -

def gather_times(splits)
  times = { e:{}, r:{}, w:{} }
  splits.each do |split|
    times[:e][split] = []
    times[:r][split] = []
    times[:w][split] = []
    sample_dirs(split).each do |dir|

      time,result = timed { exists?(dir) }
      unless result === true
        fail RuntimeError, "exists?(#{dir}) == #{result}"
      end
      times[:e][split] << time

      time,result = timed { write(dir) }
      unless result == ('hello' * 500).size
        fail RuntimeError, "write(#{dir}) == #{result}"
      end
      times[:w][split] << time

      time,result = timed { read(dir) }
      unless result == 'hello' * 500
        fail RuntimeError, "read(#{dir}) == #{result}"
      end
      times[:r][split] << time
    end
  end
  times
end

# - - - - - - - - - - - - - - - - - - - - - - -

def read(dir)
  IO.read(dir+'/info.txt')
end

def write(dir)
  IO.write(dir+'/info.txt', 'hello'* 500)
end

def exists?(dir)
  File.directory?(dir)
end

# - - - - - - - - - - - - - - - - - - - - - - -

def gather_splits
  partitions(id_size).collect { |p| p.permutation.sort.uniq }
                     .flatten(1)
                     .shuffle
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

def show_averages(averages)
  show_sorted_averages('exists?', averages[:e])
  show_sorted_averages('read',    averages[:r])
  show_sorted_averages('write',   averages[:w])
  show_sorted_averages('all',     averages[:a])
end

# - - - - - - - - - - - - - - - - - - - - - - -

def show_sorted_averages(name, split_times)
  puts "#{name}\n"
  split_times.sort_by { |_split,time| time }
             .each { |split,time|
                t = '%.07f' % time.to_f
                puts "#{t} <-- #{split}"
                # eg 0.020310 <-- [1, 1, 2]
             }
end

# - - - - - - - - - - - - - - - - - - - - - - -

def show_id_splits_times
  puts("all_max=#{all_max}")
  puts("sample_max=#{sample_max}")
  es = ARGV.detect{ |arg| arg.start_with?('--split=') }
  if es
    split = JSON.parse(es.split('=')[1])
    puts("id_size=#{split.reduce(:+)}")
    puts
    splits = [ split ]
  else
    puts("id_size=#{id_size}")
    puts
    splits = gather_splits
  end

  times = gather_times(splits)
  averages = gather_averages(splits, times)

  show_averages(averages)
end

# - - - - - - - - - - - - - - - - - - - - - - -

show_id_splits_times
