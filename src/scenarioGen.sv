    task scenarioGen(scenarioInfo_t tasks);
        $display($sformatf("[%t] Starting Scenario", $realtime()));
        scenarioPkg::threadIncr = new(1);
        scenarioPkg::done = 1'b0;

        // init tasks
        foreach(tasks[x]) begin
            automatic taskInfo_t currentTask;
            automatic string taskName;
            scenarioPkg::initTaskStatus(x);
            // init the message event arrays
            currentTask = tasks[x];
            taskName = x;
            foreach (currentTask.dependencies[y]) begin
                if (currentTask.dependencies[y].dependencyType == onMsgAvail) scenarioPkg::initTaskMsg(y, currentTask.dependencies[y].messageType, taskName);
            end
            if (currentTask.finishes) scenarioPkg::incrNumThreads();
        end

        //run tasks
        foreach(tasks[x]) begin
            automatic msg_t taskConfig = tasks[x].taskConfig;
            automatic dependencies_t dependencies = tasks[x].dependencies;
            automatic string taskName = x;
            automatic string taskCallName = tasks[x].taskCallName;
            fork
                taskManager(.taskName(taskName), .taskConfig(taskConfig), .dependencies(dependencies), .taskCallName(taskCallName)); 
            join_none
        end

        wait(scenarioPkg::done == 1'b1);
        //wait fork;
        #0;
        $finish();
    endtask