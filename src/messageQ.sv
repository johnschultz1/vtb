task automatic publishMsg (
    string jobName,          // job name for which dependencies are present
    msg_t msg                 // Message to be published
);
    string msgType = msg.msgType;
    dependency_q_t tempQ;

    // Check if the specified job exists in the scenario
    if (scenarioPkg::msgQ.exists(jobName) == 1) begin

        // Check if the message type queue exists within the specified job
        if (scenarioPkg::msgQ[jobName].exists(msgType) == 1) begin
            // Iterate over all dependency queues under the given message type
            tempQ = scenarioPkg::msgQ[jobName][msgType];
            foreach (tempQ[x]) tempQ[x].push_back(msg);
            scenarioPkg::msgQ[jobName][msgType] = tempQ;
            foreach (tempQ[x]) triggerNewMessageProducedEvent(jobName, msgType, x);
        end else begin
            $display("Error: Message type '%s' does not exist under job '%s'", msgType, jobName);
        end
    end else begin
        $display("Error: job '%s' does not exist in the scenario", jobName);
    end
endtask

task automatic consumeMsg (
    string jobName,            
    string msgType,
    string dependencyName,
    output msg_t msg            // Message to be consumed
);
    // Check if the specified job exists in the scenario
    if (scenarioPkg::msgQ.exists(jobName)== 1) begin
        // Check if the message type queue exists within the specified job
        if (scenarioPkg::msgQ[jobName].exists(msgType)== 1) begin
            // Read the message from the dependency queue
            if (msgQ[jobName][msgType][dependencyName].size() > 0) begin
                msg = scenarioPkg::msgQ[jobName][msgType][dependencyName].pop_front();
            end else begin
                $error("no message to consume");
            end
    end else begin
        $display("Error: Message type '%s' does not exist under job '%s'", msgType, jobName);
        end
    end else begin
        $display("Error: job '%s' does not exist in the scenario", jobName);
    end
endtask

function bit msgAvail (
    input string jobName,            
    input string msgType,
    input string dependencyName
);
    // Check if the specified job exists in the scenario
    if (scenarioPkg::msgQ.exists(jobName)== 1) begin
        // Check if the message type queue exists within the specified job
        if (scenarioPkg::msgQ[jobName].exists(msgType)== 1) begin
            // Read the message from the dependency queue
            if (scenarioPkg::msgQ[jobName][msgType][dependencyName].size() != 0) begin
                return 1'b1;
            end else begin
                return 1'b0;
            end
        end else begin
            $display("Error: Message type '%s' does not exist under job '%s' dependency %s", msgType, jobName, dependencyName);
            return 1'b0;
        end
    end else begin
        $display("Error: job '%s' does not exist in the scenario with msgType %s and dependencyName %s", jobName, msgType, dependencyName);
        return 1'b0;
    end
endfunction