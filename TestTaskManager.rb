require "minitest/autorun"
require_relative "TaskManager"

class TestTask < TaskAsync
	def initialize(id, resultCollector)
		@id = id
		@resultCollector = resultCollector
		super("TestTask::#{id}")
	end
	def execute
		@resultCollector.onResult( @id, @id )
		_doneTask()
	end
end

class ResultCollector
	def initialize
		@result = {}
		@_mutex = Mutex.new
	end
	def onResult( id, result )
		@_mutex.synchronize {
			@result[ id ] = result
		}
	end
	def getResult
		return @result
	end
end


class TestTaskManager < Minitest::Test
	def setup
	end

	def teardown
	end

	def test_TaskManager
		puts "test_TaskManager"
		resultCollector = ResultCollector.new()
		taskMan = TaskManagerAsync.new()
		taskMan.addTask( TestTask.new( "thread1", resultCollector ) )
		taskMan.addTask( TestTask.new( "thread2", resultCollector ) )
		taskMan.addTask( TestTask.new( "thread3", resultCollector ) )
		taskMan.addTask( TestTask.new( "thread4", resultCollector ) )

		taskMan.executeAll()
		taskMan.finalize()

		result = resultCollector.getResult()
		assert_equal 4, result.length
	end
end