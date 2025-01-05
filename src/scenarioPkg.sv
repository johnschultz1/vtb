package scenarioPkg;
    import typesPkg::*;
    import utilityPkg::*;

    scenarioInfo_t scenario;
    job_q_t msgQ;
    jobsStatus_t jobStatus;
    // string entry: jobNAME_MSGTYPENAME
    jobEvent msgEvents[string];
    // string entry: jobNAME_[STARTED | FINISHED | ERROR]
    jobEvent jobEvents[string]; 

    int numThreads;
    int threadDoneCount;
    semaphore threadIncr;
    bit done;

    virtual dutInterface vif;

    task automatic incrThreadDone(string jobName, string jobCallName);
        threadIncr.get(1);
        threadDoneCount = threadDoneCount + 1;
        printMsg($sformatf("%s job done %d / %d jobs finished", jobName, threadDoneCount, numThreads), jobName, jobCallName);
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

    task automatic waitOnjobDone(input string jobName);
        string eventName = {jobName,"_","FINISHED"};
        jobEvents[eventName].waitOnEvent();    
    endtask

    function  bit jobFinished(input string jobName);
        return jobStatus[jobName].done;
    endfunction

    task automatic triggerjobDone(input string jobName, input string jobCallName);
        string eventName = {jobName,"_","FINISHED"};
        jobStatus[jobName].jobEndTime = $realtime();
        jobStatus[jobName].jobStatus = "DONE";
        jobStatus[jobName].done = 1'b1;
        jobEvents[eventName].setEvent();
        incrThreadDone(jobName,jobCallName);
    endtask

    task automatic initjobStatus(input string jobName);
        string eventName = {jobName,"_","FINISHED"};
        jobStatus[jobName].done = 1'b0;
        jobEvents[eventName] = new();    
        jobStatus[jobName].jobStartTime = $realtime();
        jobStatus[jobName].jobStatus = "INIT";
    endtask

    task automatic initjobMsg(input string jobName, input string dependencyName);
        string eventName = {jobName,"_",dependencyName};
        msgEvents[eventName] = new();
        msgQ[jobName][dependencyName] = {};    
    endtask

    // TODO: could also conditionally store msg based on logging level
    task automatic triggerNewMessageProducedEvent(input string jobName, input string dependencyName);
         string eventName = {jobName,"_",dependencyName};
         msgEvents[eventName].setEvent();
         jobStatus[jobName].producedMsgTime.push_back($realtime);
    endtask

    task automatic waitOnMsgAvail(input string jobName, input string dependencyName);
        string eventName = {jobName,"_",dependencyName};
        string jobDoneEvent = {jobName,"_","FINISHED"};
        @(msgEvents[eventName].e, jobEvents[jobDoneEvent].e.triggered );   
    endtask

    task automatic triggerNewMessageConsumedEvent(input string jobName);
       jobStatus[jobName].consumedMsgTime.push_back($realtime);
    endtask

endpackage