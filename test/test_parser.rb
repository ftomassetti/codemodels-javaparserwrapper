require 'helper'

$CLASSPATH << 'test/dummyjavaparser/classes'

java_import 'it.codemodels.javaparserwrapper.ast.Project'

class TestParser < Test::Unit::TestCase

    include CodeModels::Javaparserwrapper

    module Src
        class A
            attr_accessor :x
            attr_accessor :y
        end
    end

    module Dest
        class A
            attr_accessor :x
            attr_accessor :y
        end        
    end

    def setup
        @poli = Project.new('Poli')
        @original_a = Src::A.new
        @original_a.x = 1
        @original_a.y = 2
    end

    def test_basic_transformation_factory
        tf = BasicTransformationFactory.new(Dest)
        transformed = tf.instantiate_transformed(@original_a)
        assert transformed.is_a?(Dest::A)
    end

end