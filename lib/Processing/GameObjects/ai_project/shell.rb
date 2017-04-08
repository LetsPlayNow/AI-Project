require 'object'
require 'helpers'
require 'settings'

# todo there are misunderstanding between constants SPEED RADIUS and related class fields
module AIProject
	ShellState = Struct.new(:location, :destination) # for world_getters.rb

	class Shell < Object
		attr_accessor :location, :destination, :speed, :damage, :radius

		def initialize(options = {location: AIProject::Location.new(-1, -1), destination: AIProject::Location.new(-1, -1)})
				@location    = options[:location]
				@destination = options[:destination]

				# These 3 properties below may be useful in future
				# ( if Shells will be different (e.g. different radius or damage))
				@speed       = SPEED
				@damage      = DAMAGE
				@radius      = RADIUS

				@time        = (Helpers.line_length(location, destination) / @speed).round(Settings::PRECISION)
		end

		SPEED  = 1.0
		DAMAGE = 50.0
		RADIUS = 1.0

		# Special setter and getter with round for time
		def time=(value)
			@time = value.round(Settings::PRECISION)
		end

		def time
			@time
		end

		def to_hash
			{location: {x: @location.x, y: @location.y}}
		end
	end
end