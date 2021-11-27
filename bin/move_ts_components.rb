#!/usr/bin/ruby
# frozen_string_literal: true

def check_directory(dir)
  raise ArgumentError, "Doesn't exist: #{dir}" unless File.exists?(dir)
  raise ArgumentError, "Not a directory: #{dir}" unless File.directory?(dir)
  raise ArgumentError, "Not readable: #{dir}" unless File.readable?(dir)
  raise ArgumentError, "Not executable: #{dir}" unless File.executable?(dir)
end

def ensure_directory(dir)
  if File.exists?(dir)
    check_directory(dir)
  else
    check_directory(File.dirname(dir))
    puts "mkdir #{dir}"
    Dir.mkdir(dir)
  end
end

Component = Struct.new(:top_dir, :old_file, :component_name) do
  def self.create_moveable(top_dir, file)
    if component_name = File.basename(file).match(/(.*\.component)\.ts$/)&.captures&.first
      component = new(top_dir, file, component_name)

      component unless component.in_valid_component_directory?
    end
  end

  def in_valid_component_directory?
    return false unless File.basename(old_directory) == component_dirleaf
    return true if component_name == 'app.component'  # The top level app component is a bit special

    Dir.entries(old_directory).all? do |f|
      f == '.' || f == '..' || f.match(/#{component_name}\.[^.]/)
    end
  end

  def old_directory
    @old_directory ||= File.dirname(old_file)
  end

  def component_dirleaf
    @component_dirleaf ||= component_name.sub(/\.component$/, '')
  end

  def component_directory
    File.join(File.dirname(old_file), component_dirleaf)
  end

  def ensure_component_directory
    ensure_directory(component_directory)
  end

  def component_files
    Dir.entries(old_directory).filter_map do |f|
      next unless f.start_with?(component_name)

      File.join(old_directory, f)
    end
  end

  def move_component_files
    ensure_component_directory
    component_files.each do |f|
      puts "git mv #{f} #{component_directory}"
      system("git mv #{f} #{component_directory}")
    end
  end

  def change_own_imports
    content = File.read(old_file)
    puts "from './ -> from '../ and from '../ -> from '../../ in #{old_file}"
    new_content = content.gsub('from \'../', 'from \'../../').gsub('from \'./', 'from \'../')
    File.open(old_file, 'w') { |f| f.puts(new_content) }
    puts "git add #{old_file}"
    system("git add #{old_file}")
  end

  def old_import_path
    @old_import_path ||= "/#{component_name}"
  end

  def new_import_path
    @new_import_path ||= "/#{component_dirleaf}/#{component_name}"
  end
  
  def change_other_imports_in_file(f)
    content = File.read(f)
    return unless content.include?(old_import_path)
    return if component_files.include?(f)

    puts "#{old_import_path} -> #{new_import_path} in #{f}"
    File.open(f, 'w') { |g| g.puts(content.gsub(old_import_path, new_import_path)) }
    puts "git add #{f}"
    system("git add #{f}")
  end
end

def extract_components(top_dir, dir)
  check_directory(dir)

  Dir.entries(dir).flat_map do |f|
    next [] if f == '.' || f == '..'

    path = File.join(dir, f)
    if File.directory?(path)
      extract_components(top_dir, path)
    elsif component_ts_file = Component.create_moveable(top_dir, path)
      [component_ts_file]
    else
      []
    end
  end
end

def change_other_imports(dir, components)
  check_directory(dir)

  Dir.entries(dir).each do |f|
    next if f == '.' || f == '..'

    path = File.join(dir, f)
    if File.directory?(path)
      change_other_imports(path, components)
    elsif path.end_with?('.ts')
      components.each do |c|
        c.change_other_imports_in_file(path)
      end
    end
  end
end

def move_files(components)
  components.each(&:move_component_files)
end

def change_own_imports(components)
  components.each(&:change_own_imports)
end

def move_ts_components(dir)
  components = extract_components(dir, dir)
  puts "Found components"
  components.each { |c| puts "* #{c.component_name}" }
  change_other_imports(dir, components)
  change_own_imports(components)
  move_files(components)
end

raise 'Exactly one arg needed.' if ARGV.length != 1

move_ts_components(ARGV.first)
