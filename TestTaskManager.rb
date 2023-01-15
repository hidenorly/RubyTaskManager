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


class TestTaskManager < Minitest::Test
	def setup
	end

	def teardown
	end

	def test_TaskManager
		puts "test_TaskManager"
		resultCollector = ResultCollector.new()
		taskMan = TaskManagerAsync.new(4)
		taskMan.addTask( TestTask.new( "thread1", resultCollector ) )
		taskMan.addTask( TestTask.new( "thread2", resultCollector ) )
		taskMan.addTask( TestTask.new( "thread3", resultCollector ) )
		taskMan.addTask( TestTask.new( "thread4", resultCollector ) )

		assert_equal true, taskMan.isRemainingTasks()
		taskMan.executeAll()
		assert_equal true, taskMan.isRunning()
		assert_equal false, taskMan.isRemainingTasks()
		taskMan.finalize()
		assert_equal false, taskMan.isRunning()
		assert_equal false, taskMan.isRemainingTasks()

		result = resultCollector.getResult()
		assert_equal 4, result.length
	end

	def test_ThreadPool
		puts "test_ThreadPool"
		resultCollector = ResultCollector.new()
		taskMan = ThreadPool.new()
		taskMan.addTask( TestTask.new( "thread1", resultCollector ) )
		taskMan.addTask( TestTask.new( "thread2", resultCollector ) )
		taskMan.addTask( TestTask.new( "thread3", resultCollector ) )
		taskMan.addTask( TestTask.new( "thread4", resultCollector ) )

		taskMan.executeAll()
		assert_equal true, taskMan.isRunning()
		taskMan.finalize()
		assert_equal false, taskMan.isRunning()

		result = resultCollector.getResult()
		assert_equal 4, result.length
	end
end