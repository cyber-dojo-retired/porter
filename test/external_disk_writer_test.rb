require_relative 'test_base'
require_relative '../src/external_disk_writer'

class ExternalDiskWriterTest < TestBase

  def self.hex_prefix
    'FDF'
  end

  def disk
    ExternalDiskWriter.new
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '435',
  'dir can already exist' do
    dir = disk['/tmp']
    assert dir.exists?
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '436',
  'dir.make succeeds if dir is made and fails if dir already exists' do
    dir = disk['/tmp/436']
    assert dir.make
    refute dir.make
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '437',
  'dir.exists?() is true after a successful dir.make' do
    dir = disk['/tmp/437']
    refute dir.exists?
    assert dir.make
    assert dir.exists?
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '440',
  'dir.exists?(filename) is true after a successful dir.make(filename)' do
    dir = disk['/tmp/440']
    dir.make
    filename = 'idyll.txt'
    refute dir.exists?(filename)
    dir.write(filename, 'wibble')
    assert dir.exists?(filename)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '438',
  'dir.read() reads back what dir.write() writes' do
    dir = disk['/tmp/438']
    dir.make
    filename = 'limerick.txt'
    content = 'the boy stood on the burning deck'
    dir.write(filename, content)
    assert_equal content, dir.read(filename)
  end

  # - - - - - - - - - - - - - - - - - - - - - - - - -

  test '439',
  'dir.append() appends to the end' do
    dir = disk['/tmp/439']
    dir.make
    filename = 'readme.md'
    content = 'hello world'
    dir.append(filename, content)
    assert_equal content, dir.read(filename)
    dir.append(filename, content.reverse)
    assert_equal "#{content}#{content.reverse}", dir.read(filename)
  end

end
