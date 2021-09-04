# RubyTaskManager

# What's this?

This enables you to be easier to handle what you'd like to execute concurrently with multi thread.

Remarkable point is that you can run the tasks simultaneously within the number of CPU cores. 

In short, the task manager provides task pool and execute within the efficient concurrency.
(You can specify the number of concurrent running tasks manually too.)


# How to use this?

```
require './TaskManager'

class SampleTask < TaskAsync
	def initialize(threadInfo)
		@threadInfo = threadInfo
		super("SampleTask::#{threadInfo.to_s}")
	end
	def execute
		result = []
		for i in 0..99 do
			result.push( i )
		end
		_doneTask()
	end
end

taskMan = TaskManagerAsync.new()

taskMan.addTask( SampleTask.new( "thread1" ) )
taskMan.addTask( SampleTask.new( "thread2" ) )
taskMan.addTask( SampleTask.new( "thread3" ) )
taskMan.addTask( SampleTask.new( "thread4" ) )
taskMan.addTask( SampleTask.new( "thread5" ) )

taskMan.executeAll()
taskMan.finalize()
```

```
$ ruby sample.rb
```

In this example with 4 CPU cores, there are 4 concurrently running tasks by executeAll().
And after the finishing task, the remaining task is automatically execusting.
When the all of queued tasks are finished, the finalize() method will return.
Therefore you can finish the all of task execution easily too.

