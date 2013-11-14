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
        class A < RGen::MetamodelBuilder::MMBase
            has_attr 'x',Integer
            has_attr 'y',String
        end       

        class Project < RGen::MetamodelBuilder::MMBase
            has_attr 'name',String
        end
    end

    class MyJavaObjectsToRgenTransformer < JavaObjectsToRgenTransformer
        include CodeModels::Javaparserwrapper::BasicTransformationFactory

        def initialize
            self.target_module = TestParser::Dest
        end

    end

    def setup
        @poli = Project.new('Poli')
        @original_a = Src::A.new
        @original_a.x = 1
        @original_a.y = '2'
    end

    class MyBasicTransformationFactory
        include CodeModels::Javaparserwrapper::BasicTransformationFactory

        def initialize
            self.target_module = TestParser::Dest
        end
    end

    def test_basic_transformation_factory
        tf = MyBasicTransformationFactory.new
        transformed = tf.instantiate_transformed(@original_a)
        assert transformed.is_a?(TestParser::Dest::A)
    end

    def test_node_to_model_simple_attr
        j2rt = MyJavaObjectsToRgenTransformer.new
        t = j2rt.node_to_model(@poli)
        assert t.is_a?(Dest::Project)
        assert_equal 'Poli',t.name
    end

end