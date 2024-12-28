task automatic publishMsg (
    string taskName,          // Task name for which dependencies are present
    msg_t msg                 // Message to be published
);
    string msgType = msg.msgType;
    dependency_q_t tempQ;

    // Check if the specified task exists in the scenario
    if (scenarioPkg::msgQ.exists(taskName) == 1) begin

        // Check if the message type queue exists within the specified task
        if (scenarioPkg::msgQ[taskName].exists(msgType) == 1) begin
            // Iterate over all dependency queues under the given message type
            tempQ = scenarioPkg::msgQ[taskName][msgType];
            foreach (tempQ[x]) tempQ[x].push_back(msg);
            scenarioPkg::msgQ[taskName][msgType] = tempQ;
            foreach (tempQ[x]) triggerNewMessageProducedEvent(taskName, msgType, x);
        end else begin
            $display("Error: Message type '%s' does not exist under task '%s'", msgType, taskName);
        end
    end else begin
        $display("Error: Task '%s' does not exist in the scenario", taskName);
    end
endtask

task automatic consumeMsg (
    string taskName,            
    string msgType,
    string dependencyName,
    output msg_t msg            // Message to be consumed
);
    // Check if the specified task exists in the scenario
    if (scenarioPkg::msgQ.exists(taskName)== 1) begin
        // Check if the message type queue exists within the specified task
        if (scenarioPkg::msgQ[taskName].exists(msgType)== 1) begin
            // Read the message from the dependency queue
            if (msgQ[taskName][msgType][dependencyName].size() > 0) begin
                msg = scenarioPkg::msgQ[taskName][msgType][dependencyName].pop_front();
            end else begin
                $error("no message to consume");
            end
    end else begin
        $display("Error: Message type '%s' does not exist under task '%s'", msgType, taskName);
        end
    end else begin
        $display("Error: Task '%s' does not exist in the scenario", taskName);
    end
endtask

function bit msgAvail (
    input string taskName,            
    input string msgType,
    input string dependencyName
);
    // Check if the specified task exists in the scenario
    if (scenarioPkg::msgQ.exists(taskName)== 1) begin
        // Check if the message type queue exists within the specified task
        if (scenarioPkg::msgQ[taskName].exists(msgType)== 1) begin
            // Read the message from the dependency queue
            if (scenarioPkg::msgQ[taskName][msgType][dependencyName].size() != 0) begin
                return 1'b1;
            end else begin
                return 1'b0;
            end
        end else begin
            $display("Error: Message type '%s' does not exist under task '%s' dependency %s", msgType, taskName, dependencyName);
            return 1'b0;
        end
    end else begin
        $display("Error: Task '%s' does not exist in the scenario with msgType %s and dependencyName %s", taskName, msgType, dependencyName);
        return 1'b0;
    end
endfunction