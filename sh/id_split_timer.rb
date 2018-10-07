
$n = ARGV[1].to_i
$max = ARGV[2].to_i    # increase to get large dir-spread for high digit values
$sample = ARGV[3].to_i # increase to get a bigger sample (will take longer)

# - - - - - - - - - - - - - - - - - - - - - - -

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

def zerod(n, digits)
  "%0#{digits}d" % n
end

# - - - - - - - - - - - - - - - - - - - - - - -

def make_new_dir_names(digits)
  # increase 5000 to get more dirs when digits is large
  max = [10**digits, $max].min
  (0...max).map{ |n| zerod(n, digits) }
end

# - - - - - - - - - - - - - - - - - - - - - - -

$new_dir_names = []

def new_dir_names(n)
  # eg n==1 --> [0..9]
  # eg n==2 --> [00..99]
  # eg n==3 --> [000..999]
  $new_dir_names[n] ||= make_new_dir_names(n)
end

# - - - - - - - - - - - - - - - - - - - - - - -

def setup_dirs(split)
  # eg split = [3,2,1]
  tmp = ARGV[0] + "/id_splits"
  `rm -rf #{tmp} && mkdir -p #{tmp}`

  sample_dirs = [ tmp ]

  split.each do |digits|
    all_dirs = splice(sample_dirs, new_dir_names(digits))
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
  #puts "read(#{dir})"
  IO.read(dir+'/info.txt')
end

def write(dir)
  #puts "write(#{dir})"
  IO.write(dir+'/info.txt', 'blah blah')
end

def exists?(dir)
  #puts "exists?(#{dir})"
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


