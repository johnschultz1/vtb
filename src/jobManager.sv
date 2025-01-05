task automatic jobManager(input string jobName, input msg_t jobConfig, input dependencies_t dependencies, input string jobCallName );
    automatic msg_t msgOut;
    automatic bit done=0;

        // a job can have 0 dependencies
        if (dependencies.num() == 0) begin
            printMsg("Started job", jobName, jobCallName);
            jobFactory(.msgList(msgOut), .cfg(jobConfig),  .jobName(jobCallName), .jobInstName(jobName));
            printMsg("Finished", jobName, jobCallName);
            triggerjobDone(jobName, jobCallName);
        end else begin
            while (!done) begin
                // wait
                foreach (dependencies[x]) begin
                        automatic dependency_e dType = dependencies[x].dependencyType;
                        automatic string dependencyName = x;
                        automatic bit jobDone;
                        automatic bit msgRdy;
                        automatic string currentjob = jobName;
                        automatic msg_t consumedMsg;

                        if (dType == onFinish) begin
                            printMsg($sformatf("Started To Wait On %s", dependencyName) , jobName, jobCallName);
                            jobDone = jobFinished(dependencyName);
                            if (jobDone == 0) waitOnjobDone(dependencyName);
                            printMsg("Started job", jobName, jobCallName);
                            jobFactory(.msgList(msgOut), .cfg(jobConfig),  .jobName(jobCallName), .jobInstName(jobName));
                            done = 1;
                        end else if (dType == onMsgAvail) begin  
                            jobDone = jobFinished(dependencyName);
                            msgRdy = msgAvail(.jobName(dependencyName), .dependencyName(currentjob));
                            // If the Q empty and the parent job done, no more msgs can come so this job is done as well
                            if (jobDone && !msgRdy) begin
                                done = 1;
                            // msg available so consume it
                            end else if (msgRdy) begin
                                // get message
                                consumeMsg(dependencyName, currentjob, consumedMsg);
                                // write it to the list
                                msgOut = consumedMsg;
                                printMsg("Started job", jobName, jobCallName);
                                jobFactory(.msgList(msgOut), .cfg(jobConfig),  .jobName(jobCallName), .jobInstName(jobName));
                            // message not available but the job has not finished yet
                            end else begin
                                printMsg($sformatf("Started To Wait On %s", dependencyName) , currentjob, jobCallName);
                                waitOnMsgAvail(dependencyName, currentjob);
                            end
                        end
                    end
                end
            triggerjobDone(jobName, jobCallName);
        end
        
endtask