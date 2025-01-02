task automatic jobManager(input string jobName, input msg_t jobConfig, input dependencies_t dependencies, input string jobCallName );
    automatic msgList_t msgList;
    automatic bit dependenciesDone[string];
    automatic bit dontExecutejob[string];
    automatic bit done=0;
    automatic bit execute=0;

        // a job can have 0 dependencies
        if (dependencies.num() == 0) begin
            printMsg("Started job", jobName, jobCallName);
            jobFactory(.msgList(msgList), .cfg(jobConfig),  .jobName(jobCallName), .id(jobName));
            printMsg("Finished", jobName, jobCallName);
            triggerjobDone(jobName, jobCallName);
        end else begin
            while (!done) begin
                // wait
                foreach (dependencies[x]) begin
                    if (dependenciesDone[x]  != 1) begin
                        automatic dependency_e dType = dependencies[x].dependencyType;
                        automatic string msgType = dependencies[x].messageType;
                        automatic string dependencyName = x;
                        automatic bit jobDone;
                        automatic bit msgRdy;
                        automatic string currentjob = jobName;
                        automatic msg_t consumedMsg;
                        
                        if (dType == onFinish) begin
                            printMsg($sformatf("Started To Wait On %s", dependencyName) , jobName, jobCallName);
                            jobDone = jobFinished(dependencyName);
                            if (jobDone == 0) waitOnjobDone(dependencyName);
                            dependenciesDone[dependencyName]  = 1;
                            dontExecutejob[dependencyName]   = 0;
                        end else if (dType == onMsgAvail) begin  
                            jobDone = jobFinished(dependencyName);
                            msgRdy = msgAvail(.jobName(dependencyName), .msgType(msgType), .dependencyName(currentjob));
                            // If the Q empty and the parent job done, no more msgs can come so this job is done as well
                            if (jobDone && !msgRdy) begin
                                dependenciesDone[dependencyName]  = 1;
                                dontExecutejob[dependencyName]   = 1;
                            // msg available so consume it
                            end else if (msgRdy) begin
                                // get message
                                consumeMsg(dependencyName, msgType, currentjob, consumedMsg);
                                // write it to the list
                                msgList[msgType] = consumedMsg;
                                dontExecutejob[dependencyName]   = 0;
                                dependenciesDone[dependencyName]  = 0;
                            // message not available but the job has not finished yet
                            end else begin
                                printMsg($sformatf("Started To Wait On %s", dependencyName) , currentjob, jobCallName);
                                dontExecutejob[dependencyName]   = 1;
                                waitOnMsgAvail(dependencyName, msgType, currentjob);
                            end
                        end
                    end
                end
                // execute
                execute = 1;
                done = 1;
                foreach(dontExecutejob[x]) begin
                    if (dontExecutejob[x] == 1) execute = 0;
                end
                foreach(dependenciesDone[x]) begin
                    if (dependenciesDone[x] == 0) done = 0;
                end
                if (execute == 1) begin
                    printMsg("Started job", jobName, jobCallName);
                    jobFactory(.msgList(msgList), .cfg(jobConfig),  .jobName(jobCallName), .id(jobName));

                end
                #0;
            end
            triggerjobDone(jobName, jobCallName);
        end
        
endtask