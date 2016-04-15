require 'location'

module AIProject
  class Object
    attr_reader :location
    def initialize(options)
      @location = options[:location]
      @radius = options[:radius]
    end
  end
end