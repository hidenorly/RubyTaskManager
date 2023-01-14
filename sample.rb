#!/usr/bin/ruby

#  Copyright (C) 2021, 2022 hidenorly
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

require_relative 'TaskManager'

class SampleTask < TaskAsync
	def initialize(key, resultCollector)
		@key = key
		@resultCollector = resultCollector
		super("SampleTask::#{key}")
	end
	def execute
		result = []
		for i in 0..99 do
			result.push( i )
		end
		@resultCollector.onResult(@key, result)
		_doneTask()
	end
end

class ResultCollector
	def initialize
		@result = {}
		@_mutex = Mutex.new
	end
	def onResult( path, result )
		@_mutex.synchronize {
			@result[ path ] = result
		}
	end
	def dump
		@result.each do |aPath, result|
			print "| " + aPath.to_s + " | "
			result.each do |aValue|
				print aValue.to_s + " | "
			end
			puts ""
		end
	end
end

#---- main --------------------------
taskMan = TaskManagerAsync.new()

result = ResultCollector.new()

taskMan.addTask( SampleTask.new( "thread1", result ) )
taskMan.addTask( SampleTask.new( "thread2", result ) )
taskMan.addTask( SampleTask.new( "thread3", result ) )
taskMan.addTask( SampleTask.new( "thread4", result ) )

taskMan.executeAll()
taskMan.finalize()
result.dump()



threadPool = ThreadPool.new()
result2 = ResultCollector.new()
threadPool.addTask( SampleTask.new( "task1", result2 ) )
threadPool.addTask( SampleTask.new( "task2", result2 ) )
threadPool.addTask( SampleTask.new( "task3", result2 ) )
threadPool.addTask( SampleTask.new( "task4", result2 ) )

threadPool.executeAll()
threadPool.finalize()
result2.dump()

