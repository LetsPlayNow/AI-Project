require 'unit'
require 'shell'
require 'world_constants'
require 'world_getters'

# This class used by the Player
# Object of class World is in Strategy object field @info
# It is information interface for player
module AIProject
	class World
		def initialize(options = {units: {}, shells: {}})
				@units  = options[:units]
				@shells = options[:shells]
		end

		include WorldConstants
		include WorldGetters
	end
end