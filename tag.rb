require "vendor/moneta/lib/moneta/basic_file"

class Tag

  def self.store(tag, file)
    system "convert #{file} -gravity center -crop '100x100+0+0' +repage templates/#{tag}.jpg" 

    store = Moneta::BasicFile.new(:path => File.join(File.dirname(__FILE__), "tags")) 
    current_tags = store.delete("tags")
    store["tags"] = current_tags.nil? ? [tag] : (current_tags << tag)
  end

end
 
Tag.store(ARGV[0], ARGV[1])
