#  Copyright (C) 2023 hidenorly
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# TaskManager and Task definitions

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
		sleep 0.01
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


	def test_addTaskManagerInRunning
		puts "test_addTaskManagerInRunning"
		resultCollector = ResultCollector.new()
		taskMan = TaskManagerAsync.new(4)
		taskMan.addTask( TestTask.new( "task1", resultCollector ) )
		taskMan.addTask( TestTask.new( "task2", resultCollector ) )
		taskMan.addTask( TestTask.new( "task3", resultCollector ) )
		taskMan.addTask( TestTask.new( "task4", resultCollector ) )
		assert_equal true, taskMan.isRemainingTasks()
		taskMan.executeAll()
		sleep 0.01
		assert_equal true, taskMan.isRunning()
		assert_equal false, taskMan.isRemainingTasks()
		taskMan.addTask( TestTask.new( "task5", resultCollector ) )
		taskMan.addTask( TestTask.new( "task6", resultCollector ) )
		taskMan.addTask( TestTask.new( "task7", resultCollector ) )
		taskMan.addTask( TestTask.new( "task8", resultCollector ) )
		assert_equal true, taskMan.isRunning()
		assert_equal true, taskMan.isRemainingTasks()
		taskMan.finalize()
		assert_equal false, taskMan.isRunning()
		assert_equal false, taskMan.isRemainingTasks()

		result = resultCollector.getResult()
		assert_equal true, result.kind_of?(Array)
		assert_equal 8, result.length
	end


	def test_TaskManagerSync
		puts "test_TaskManagerSync"

		resultCollector = ResultCollector.new()
		taskMan = TaskManager.new()
		taskMan.addTask( TestTask.new( "id1", resultCollector ) )
		taskMan.addTask( TestTask.new( "id2", resultCollector ) )
		taskMan.addTask( TestTask.new( "id3", resultCollector ) )
		taskMan.addTask( TestTask.new( "id4", resultCollector ) )
		taskMan.executeAll()
		taskMan.finalize()
		assert_equal false, taskMan.isRunning()
		assert_equal false, taskMan.isRemainingTasks()

		result = resultCollector.getResult()
		assert_equal true, result.kind_of?(Array)
		assert_equal 4, result.length
	end
end