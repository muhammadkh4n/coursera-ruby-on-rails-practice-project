module RacersHelper
  def toRacer(val)
    return val.is_a?(Racer) ? val : Racer.new(val)
  end
end
