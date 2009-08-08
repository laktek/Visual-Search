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
