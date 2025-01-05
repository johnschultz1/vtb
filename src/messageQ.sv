task automatic publishMsg (
    string jobName,          // job name for which dependencies are present
    msg_t msg                 // Message to be published
);
    dependency_q_t tempQ;
    msg.strings["NAME"] = jobName;

    // Check if the specified job exists in the scenario
    if (scenarioPkg::msgQ.exists(jobName) == 1) begin
        // Iterate over all dependency queues under the given message type
        tempQ = scenarioPkg::msgQ[jobName];
        foreach (tempQ[x]) tempQ[x].push_back(msg);
        scenarioPkg::msgQ[jobName] = tempQ;
        foreach (tempQ[x]) triggerNewMessageProducedEvent(jobName, x);
    end else begin
        $display("Error: job '%s' does not exist in the scenario", jobName);
    end
endtask

task automatic consumeMsg (
    string jobName,            
    string dependencyName,
    output msg_t msg            // Message to be consumed
);
    // Check if the specified job exists in the scenario
    if (scenarioPkg::msgQ.exists(jobName)== 1) begin
        // Read the message from the dependency queue
        if (msgQ[jobName][dependencyName].size() > 0) begin
            msg = scenarioPkg::msgQ[jobName][dependencyName].pop_front();
        end else begin
            $error("no message to consume");
        end
    end else begin
        $display("Error: job '%s' does not exist in the scenario", jobName);
    end
endtask

function bit msgAvail (
    input string jobName,            
    input string dependencyName
);
    // Check if the specified job exists in the scenario
    if (scenarioPkg::msgQ.exists(jobName)== 1) begin
            // Read the message from the dependency queue
            if (scenarioPkg::msgQ[jobName][dependencyName].size() != 0) begin
                return 1'b1;
            end else begin
                return 1'b0;
            end
    end else begin
        $display("Error: job '%s' does not exist in the scenario with dependencyName %s", jobName, dependencyName);
        return 1'b0;
    end
endfunction