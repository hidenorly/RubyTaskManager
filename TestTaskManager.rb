require "minitest/autorun"
require_relative "TaskManager"

class TestTask < TaskAsync
	def initialize(id, resultCollector)
		@id = id
		@resultCollector = resultCollector
		super("TestTask::#{id}")
	end
	def execute
		sleep 0.1
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
		assert_equal true, result.kind_of?(Array)
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
		assert_equal true, result.kind_of?(Array)
		assert_equal 4, result.length
	end


	def test_ThreadPoolWithResultCollectorHash
		puts "test_ThreadPool"
		resultCollector = ResultCollectorHash.new()
		taskMan = ThreadPool.new()
		taskMan.addTask( TestTask.new( "thread1", resultCollector ) )
		taskMan.addTask( TestTask.new( "thread2", resultCollector ) )
		taskMan.addTask( TestTask.new( "thread3", resultCollector ) )
		taskMan.addTask( TestTask.new( "thread4", resultCollector ) )

		taskMan.executeAll()
		taskMan.finalize()

		result = resultCollector.getResult()
		assert_equal true, result.kind_of?(Hash)
		assert_equal 4, result.length
	end


	def test_cancelThreadPool
		puts "test_cancelThreadPool"
		resultCollector = ResultCollector.new()
		taskMan = ThreadPool.new(4)
		task1 = TestTask.new( "thread1", resultCollector )
		task2 = TestTask.new( "thread2", resultCollector )
		task3 = TestTask.new( "thread3", resultCollector )
		task4 = TestTask.new( "thread4", resultCollector )
		taskMan.addTask( task1 )
		taskMan.addTask( task2 )
		taskMan.addTask( task3 )
		taskMan.addTask( task4 )

		taskMan.cancelTask( task1 )
		assert_equal true, taskMan.isRemainingTasks()
		taskMan.executeAll()
		sleep 0.1
		assert_equal true, taskMan.isRunning()
		assert_equal false, taskMan.isRemainingTasks()
		taskMan.cancelTask( task1 )
		taskMan.cancelTask( task2 )
		taskMan.cancelTask( task3 )
		taskMan.cancelTask( task4 )
		taskMan.finalize()
		assert_equal false, taskMan.isRunning()
		assert_equal false, taskMan.isRemainingTasks()

		result = resultCollector.getResult()
		assert_equal true, result.kind_of?(Array)
		assert_equal 3, result.length
	end


	def test_cancelTaskManager
		puts "test_cancelTaskManager"
		resultCollector = ResultCollector.new()
		taskMan = TaskManagerAsync.new(4)
		task1 = TestTask.new( "thread1", resultCollector )
		task2 = TestTask.new( "thread2", resultCollector )
		task3 = TestTask.new( "thread3", resultCollector )
		task4 = TestTask.new( "thread4", resultCollector )
		taskMan.addTask( task1 )
		taskMan.addTask( task2 )
		taskMan.addTask( task3 )
		taskMan.addTask( task4 )

		taskMan.cancelTask( task1 )
		assert_equal true, taskMan.isRemainingTasks()
		taskMan.executeAll()
		sleep 0.01
		assert_equal true, taskMan.isRunning()
		assert_equal false, taskMan.isRemainingTasks()
		taskMan.finalize()
		assert_equal false, taskMan.isRunning()
		assert_equal false, taskMan.isRemainingTasks()

		result = resultCollector.getResult()
		assert_equal true, result.kind_of?(Array)
		assert_equal 3, result.length
	end

end