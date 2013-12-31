require 'helper'

$CLASSPATH << 'test/dummyjavaparser/classes'

java_import 'it.codemodels.javaparserwrapper.ast.Project'
java_import 'it.codemodels.javaparserwrapper.ast.Todo'
java_import 'java.util.Date'
java_import 'java.util.GregorianCalendar'

class TestParser < Test::Unit::TestCase

    include CodeModels::JavaParserWrapper

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

        class Todo < RGen::MetamodelBuilder::MMBase
            has_attr 'description',String
            has_attr 'status',String
        end

        class Project < RGen::MetamodelBuilder::MMBase
            has_attr 'name',String
            contains_many_uni 'todos', Todo
        end        

    end

    class MyJavaObjectsToRgenTransformer < JavaObjectsToRgenTransformer
#        include CodeModels::Javaparserwrapper::BasicTransformationFactory

        def initialize
            super
            @factory.target_module = TestParser::Dest
        end

    end

    def setup
        @poli = Project.new('Poli')
        @original_a = Src::A.new
        @original_a.x = 1
        @original_a.y = '2'

        d1 = GregorianCalendar.new

        @fill_report = Todo.new('fill report')

        @have_a_party = Todo.new('have a party!')
        @have_a_party.status = Todo::Status::WORKING_ON

        @poli.addTodo(@fill_report)
        @poli.addTodo(@have_a_party)
    end

    class MyBasicTransformationFactory < CodeModels::JavaParserWrapper::BasicTransformationFactory
#        include CodeModels::Javaparserwrapper::BasicTransformationFactory

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

    def test_node_to_model_enum_attr
        j2rt = MyJavaObjectsToRgenTransformer.new

        t = j2rt.node_to_model(@fill_report)
        assert t.is_a?(Dest::Todo)
        assert_equal 'fill report',t.description
        assert_equal 'NOT_STARTED',t.status

        t = j2rt.node_to_model(@have_a_party)
        assert t.is_a?(Dest::Todo)
        assert_equal 'have a party!',t.description
        assert_equal 'WORKING_ON',t.status        
    end

    def test_node_to_model_containment
        j2rt = MyJavaObjectsToRgenTransformer.new
        t = j2rt.node_to_model(@poli)
        assert_equal 2,@poli.todos.count
        assert_equal 'fill report',@poli.todos[0].description
        assert_equal 'have a party!',@poli.todos[1].description
    end    

end