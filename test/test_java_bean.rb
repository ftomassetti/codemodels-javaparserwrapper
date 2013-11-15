require 'helper'

$CLASSPATH << 'test/dummyjavaparser/classes'

java_import 'it.codemodels.javaparserwrapper.ast.Project'
java_import 'it.codemodels.javaparserwrapper.ast.Todo'
java_import 'it.codemodels.javaparserwrapper.ast.Comment'
java_import 'java.util.Date'
java_import 'java.util.GregorianCalendar'
java_import 'java.text.SimpleDateFormat'
java_import 'java.util.Locale'

class TestJavaBean < Test::Unit::TestCase

    include CodeModels::Javaparserwrapper

    def setup
    	@d1 = SimpleDateFormat.new("MMMM d, yyyy", Locale::ENGLISH).parse( "January 2, 2010");
    	@c1 = Comment.new(@d1,'my comment')
    end

    def test_comment
    	m = JavaBeanModel.new(@c1)
    	assert_equal @d1,m.get_value('insertionDate')
    	assert_equal 'my comment',m.get_value('content')
    end

end
