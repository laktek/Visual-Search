require "rubygems"
require "eventmachine"
require 'hornetseye'
include Hornetseye

require 'multiarray_ext'

module Map

  def match_image(target_image, template_image)
    begin
      image = MultiArray.load_grey8( target_image )
      template = MultiArray.load_grey8( template_image )
      ncc = image.ncc( template )
      idx = MultiArray.lint( *ncc.shape ).indgen!.mask( ncc >= ncc.max )[0]
      shiftx = idx % ncc.shape[0]
      shifty = idx / ncc.shape[0]
      shiftx = shiftx - image.shape[0] - template.shape[0] if shiftx > image.shape[0]
      shifty = shifty - image.shape[1] - template.shape[1] if shifty > image.shape[1]

      puts shiftx
      puts shifty

      withinx = ((image.shape[0]/2 - 75)..(image.shape[0]/2 + 75)).include?(shiftx)
      withiny = ((image.shape[1]/2 - 75)..(image.shape[1]/2 + 75)).include?(shifty)

      puts withinx
      puts withiny

      if (withinx && withiny) 
        [shiftx - (image.shape[0]/2 - 50), shifty - (image.shape[1]/2 - 50) ].inject(0) { |deviation, v| deviation + v.abs}
      else
        return nil
      end
    rescue
      return nil 
    end
  end

  def receive_data(packet)
    tuple = Marshal.load(packet)
    target_image = tuple[0]
    templates = tuple[1]
    valid_results = {} 

    templates.each do |template|
      template_image = "templates/#{template}.jpg"
      if deviation = match_image(target_image, template_image)
        valid_results.store(template, deviation)
      end
    end

    puts valid_results.inspect
    output = Marshal.dump(valid_results)

    send_data(output)
    close_connection_after_writing
  end
end

EM.run {
  EM.start_server("localhost", 5555, Map)
  EM.start_server("localhost", 6666, Map)
}
