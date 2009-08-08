#!/usr/bin/env ruby
require 'hornetseye'
include Hornetseye

class MultiArray
  def avg
    to_dfloat.sum / size
  end

  def sqr
    x = to_dfloat
    x * x
  end

  def cov( tmp, u, v )
    pch = self[ u...(u+tmp.shape[0]), v...(v+tmp.shape[1]) ]
    ( ( pch - pch.avg ) * ( tmp - tmp.avg ) ).sum /
    Math.sqrt( ( ( pch - pch.avg ).sqr ).sum *
        ( ( tmp - tmp.avg ).sqr ).sum )
  end

  def corr( other )
    ( rfft * other.rfft.conj ).irfft
  end

  def zcorr( other )
    zother = MultiArray.dfloat( *shape ).fill!
    zother[ 0...other.shape[0], 0...other.shape[1] ] = other
    corr( zother )
  end

  def median( *shape )
    filter = MultiArray.dfloat( *shape ).fill!( 1 )
    zcorr( filter )
  end

  def ncc( other )
    zcorr( other - other.avg ) /
    Math.sqrt( ( sqr.median( *other.shape ) -
    median( *other.shape ).sqr / other.size ) *
    ( other - other.avg ).sqr.sum )
  end
end

syntax = <<END_OF_STRING
  Align images using phase correlation
  Syntax : ncc.rb <image1> <image2>
  Example: ncc.rb image1.jpg image2.jpg
END_OF_STRING

  if ARGV.size != 2
    puts syntax
    raise "Wrong number of command-line arguments"
  end

  image = MultiArray.load_grey8( ARGV[0] )
  template = MultiArray.load_grey8( ARGV[1] )
  ncc = image.ncc( template )
  idx = MultiArray.lint( *ncc.shape ).indgen!.mask( ncc >= ncc.max )[0]
  puts image.shape[1]
  shiftx = idx % ncc.shape[0]
  shifty = idx / ncc.shape[0]
  shiftx = shiftx - image.shape[0] - template.shape[0] if shiftx > image.shape[0]
  shifty = shifty - image.shape[1] - template.shape[1] if shifty > image.shape[1]
  minx = [ 0, shiftx ].min
  miny = [ 0, shifty ].min
  maxx = [ image.shape[0], template.shape[0] + shiftx ].max - 1
  maxy = [ image.shape[1], template.shape[1] + shifty ].max - 1
  offsetx = -minx
  offsety = -miny
  resultwidth  = maxx + 1 - minx
  resultheight = maxy + 1 - miny
  result1 = MultiArray.ubyte( resultwidth, resultheight ).fill!
  result1[ offsetx...( offsetx + image.shape[0] ),
  offsety...( offsety + image.shape[1] ) ] = image / 2
  result2 = MultiArray.ubyte( resultwidth, resultheight ).fill!
  result2[ ( shiftx + offsetx )...( shiftx + offsetx + template.shape[0] ),
  ( shifty + offsety )...( shifty + offsety + template.shape[1] ) ] = template / 2

  puts "#{shiftx}, #{shifty}"

  ( result1 + result2 ).show
