package scenarioPkg;
    import typesPkg::*;
    import utilityPkg::*;

    scenarioInfo_t scenario;
    task_q_t msgQ;
    tasksStatus_t taskStatus;
    // string entry: TASKNAME_MSGTYPENAME
    taskEvent msgEvents[string];
    // string entry: TASKNAME_[STARTED | FINISHED | ERROR]
    taskEvent taskEvents[string]; 

    int numThreads;
    int threadDoneCount;
    semaphore threadIncr;
    bit done;

    virtual dutInterface vif;

    task automatic incrThreadDone(string taskName, string taskCallName);
        threadIncr.get(1);
        threadDoneCount = threadDoneCount + 1;
        printMsg($sformatf("%s job done %d / %d jobs finished", taskName, threadDoneCount, numThreads), taskName, taskCallName);
        if (threadDoneCount == numThreads) begin
            done = 1'b1;
        end
        threadIncr.put(1);
    endtask

    task automatic incrNumThreads();
        threadIncr.get(1);
        numThreads = numThreads + 1;
        threadIncr.put(1);
    endtask

    task automatic waitOnTaskDone(input string taskName);
        string eventName = {taskName,"_","FINISHED"};
        taskEvents[eventName].waitOnEvent();    
    endtask

    function  bit taskFinished(input string taskName);
        return taskStatus[taskName].done;
    endfunction

    task automatic triggerTaskDone(input string taskName, input string taskCallName);
        string eventName = {taskName,"_","FINISHED"};
        taskStatus[taskName].taskEndTime = $realtime();
        taskStatus[taskName].taskStatus = "DONE";
        taskStatus[taskName].done = 1'b1;
        taskEvents[eventName].setEvent();
        incrThreadDone(taskName,taskCallName);
    endtask

    task automatic initTaskStatus(input string taskName);
        string eventName = {taskName,"_","FINISHED"};
        taskStatus[taskName].done = 1'b0;
        taskEvents[eventName] = new();    
        taskStatus[taskName].taskStartTime = $realtime();
        taskStatus[taskName].taskStatus = "INIT";
    endtask


    task automatic initTaskMsg(input string taskName, input string msgType, input string dependencyName);
        string eventName = {taskName,"_", msgType,"_",dependencyName};
        msgEvents[eventName] = new();
        msgQ[taskName][msgType][dependencyName] = {};    
    endtask

    // TODO: could also conditionally store msg based on logging level
    task automatic triggerNewMessageProducedEvent(input string taskName, input string msgType, input string dependencyName);
         string eventName = {taskName,"_", msgType,"_",dependencyName};
         msgEvents[eventName].setEvent();
         taskStatus[taskName].producedMsgTime[msgType].push_back($realtime);
    endtask

    task automatic waitOnMsgAvail(input string taskName, input string msgType, input string dependencyName);
        string eventName = {taskName,"_", msgType,"_",dependencyName};
        string taskDoneEvent = {taskName,"_","FINISHED"};
        @(msgEvents[eventName].e, taskEvents[taskDoneEvent].e.triggered );   
    endtask

    task automatic triggerNewMessageConsumedEvent(input string taskName, input string msgType);
       taskStatus[taskName].consumedMsgTime[msgType].push_back($realtime);
    endtask

endpackage