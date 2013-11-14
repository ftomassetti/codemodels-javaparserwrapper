require 'simplecov'
SimpleCov.start do
	add_filter "/test/"	
end

require 'codemodels/javaparserwrapper'
require 'test/unit'
require 'rgen/metamodel_builder'

include CodeModels
