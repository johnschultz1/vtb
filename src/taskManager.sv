task automatic taskManager(input string taskName, input msg_t taskConfig, input dependencies_t dependencies, input string taskCallName );
    automatic msgList_t msgList;
    automatic bit dependenciesDone[string];
    automatic bit dontExecuteTask[string];
    automatic bit done=0;
    automatic bit execute=0;

        // a task can have 0 dependencies
        if (dependencies.num() == 0) begin
            printMsg("Started Task", taskName, taskCallName);
            taskFactory(.msgList(msgList), .cfg(taskConfig),  .taskName(taskCallName), .id(taskName));
            printMsg("Finished", taskName, taskCallName);
            triggerTaskDone(taskName, taskCallName);
        end else begin
            while (!done) begin
                // wait
                foreach (dependencies[x]) begin
                    if (dependenciesDone[x]  != 1) begin
                        automatic dependency_e dType = dependencies[x].dependencyType;
                        automatic string msgType = dependencies[x].messageType;
                        automatic string dependencyName = x;
                        automatic bit taskDone;
                        automatic bit msgRdy;
                        automatic string currentTask = taskName;
                        automatic msg_t consumedMsg;
                        
                        if (dType == onFinish) begin
                            printMsg($sformatf("Started To Wait On %s", dependencyName) , taskName, taskCallName);
                            taskDone = taskFinished(dependencyName);
                            if (taskDone == 0) waitOnTaskDone(dependencyName);
                            dependenciesDone[dependencyName]  = 1;
                            dontExecuteTask[dependencyName]   = 0;
                        end else if (dType == onMsgAvail) begin  
                            taskDone = taskFinished(dependencyName);
                            msgRdy = msgAvail(.taskName(dependencyName), .msgType(msgType), .dependencyName(currentTask));
                            // If the Q empty and the parent Task done, no more msgs can come so this task is done as well
                            if (taskDone && !msgRdy) begin
                                dependenciesDone[dependencyName]  = 1;
                                dontExecuteTask[dependencyName]   = 1;
                            // msg available so consume it
                            end else if (msgRdy) begin
                                // get message
                                consumeMsg(dependencyName, msgType, currentTask, consumedMsg);
                                // write it to the list
                                msgList[msgType] = consumedMsg;
                                dontExecuteTask[dependencyName]   = 0;
                                dependenciesDone[dependencyName]  = 0;
                            // message not available but the task has not finished yet
                            end else begin
                                printMsg($sformatf("Started To Wait On %s", dependencyName) , currentTask, taskCallName);
                                dontExecuteTask[dependencyName]   = 1;
                                waitOnMsgAvail(dependencyName, msgType, currentTask);
                            end
                        end
                    end
                end
                // execute
                execute = 1;
                done = 1;
                foreach(dontExecuteTask[x]) begin
                    if (dontExecuteTask[x] == 1) execute = 0;
                end
                foreach(dependenciesDone[x]) begin
                    if (dependenciesDone[x] == 0) done = 0;
                end
                if (execute == 1) begin
                    printMsg("Started Task", taskName, taskCallName);
                    taskFactory(.msgList(msgList), .cfg(taskConfig),  .taskName(taskCallName), .id(taskName));

                end
                #0;
            end
            triggerTaskDone(taskName, taskCallName);
        end
        
endtask