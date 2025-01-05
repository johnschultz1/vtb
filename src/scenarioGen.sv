    task scenarioGen(scenarioInfo_t jobs);
        $display($sformatf("[%t] Starting Scenario", $realtime()));
        scenarioPkg::threadIncr = new(1);
        scenarioPkg::done = 1'b0;

        // init jobs
        foreach(jobs[x]) begin
            automatic jobInfo_t currentJob;
            automatic string jobName;
            scenarioPkg::initjobStatus(x);
            // init the message event arrays
            currentJob = jobs[x];
            jobName = x;
            foreach (currentJob.dependencies[y]) begin
                if (currentJob.dependencies[y].dependencyType == onMsgAvail) scenarioPkg::initjobMsg(y, jobName);
            end
            if (currentJob.finishes) scenarioPkg::incrNumThreads();
        end

        //run jobs
        foreach(jobs[x]) begin
            automatic msg_t jobConfig = jobs[x].jobConfig;
            automatic dependencies_t dependencies = jobs[x].dependencies;
            automatic string jobName = x;
            automatic string jobCallName = jobs[x].jobCallName;
            fork
                jobManager(.jobName(jobName), .jobConfig(jobConfig), .dependencies(dependencies), .jobCallName(jobCallName)); 
            join_none
        end

        wait(scenarioPkg::done == 1'b1);
        //wait fork;
        #0;
        $finish();
    endtask