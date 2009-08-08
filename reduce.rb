require "rubygems"
require "eventmachine"
require "vendor/moneta/lib/moneta/basic_file"

class Reduce < EM::Connection
  @@all = []

  def initialize(*args)
    super
    @doc, @data = args[0], [] 
  end

  def post_init
    send_data(@doc)
  end

  def receive_data(data)
    @data = Marshal.load(data)
  end

  def unbind
    Reduce.job_completed
    @@all += @data
    unless Reduce.pending_jobs?
      # groups = @@all.group_by {|word| word[0] }
      # groups.each { |g| p "#{g[0]} : #{g[1].size}" }

       puts @@all.inspect
       EM.stop
    end
  end

  def self.send_map_job(port, tuple)
    @job_count ||= 0
    increment_job_count
    packet = Marshal.dump(tuple) 
    EM.connect("localhost", port, Reduce, packet)
  end

  def self.increment_job_count
    @job_count += 1
  end

  def self.pending_jobs?
    @job_count != 0
  end

  def self.job_completed
    @job_count -= 1
  end

  def self.search(image)
    store = Moneta::BasicFile.new(:path => File.join(File.dirname(__FILE__), "tags")) 
    tags = store["tags"]
    servers = [ 5555, 6666 ]
    slice_size = tags.length / servers.length
    server_id = 0

    cluster = Hash.new
    tags.each_slice(slice_size) do |slice|
      cluster[servers[server_id]] = [image, slice]
      server_id += 1 
    end

    EM.run do
     cluster.each { |port, tuple| Reduce.send_map_job(port, tuple) }
    end
  end
end

Reduce.search ARGV[0]
