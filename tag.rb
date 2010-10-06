require File.dirname(__FILE__) + "/vendor/moneta/lib/moneta/basic_file"

class Tag

  def self.store(tag, file)
    template_file = File.join(File.dirname(__FILE__), "templates", "#{tag}.jpg")
    system "convert #{file} -gravity center -crop '100x100+0+0' +repage #{template_file}" 

    store = Moneta::BasicFile.new(:path => File.join(File.dirname(__FILE__), "tags")) 
    current_tags = store.delete("tags")
    store["tags"] = current_tags.nil? ? [tag] : (current_tags << tag)
  end

end
 
