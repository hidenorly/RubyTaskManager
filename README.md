# RubyTaskManager

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

taskMan.executeAll()
taskMan.finalize()
```

```
$ ruby sample.rb
```
