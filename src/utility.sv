  function scenarioInfo_t readScenario(cfgList_t configs);
      automatic int fileHandle;
      string scenarioFile;
      automatic string line;
      int eof;
      string varName, varType;
      string value, values;
      scenarioInfo_t scenario;
  
      // Open the CSV file
      if (!$value$plusargs("scenarioFile=%s", scenarioFile)) begin
          $error("No scenarioFile argument provided.");
      end
      fileHandle = $fopen(scenarioFile, "r");
      if (fileHandle == 0) begin
          $display("Error: Could not open file %s", scenarioFile);
          return scenario;
      end
  
      // Read and skip the header
      $fgets(line, fileHandle);
  
      // Read each line
      while (!$feof(fileHandle)) begin
          automatic string jobName;
          automatic string callName;
          automatic string dependencyName;
          automatic string dependencyType;
          automatic string configName;
          automatic bit finishes;
          automatic string fields[];
          $fgets(line, fileHandle);
          if (line != "") begin
            // Parse the CSV
            fields              = splitString(line, ",");
            jobName            = fields[0];
            callName            = fields[1];
            configName          = fields[2];
            dependencyName      = fields[3];
            dependencyType      = fields[4];
            if (fields[5] == "true") finishes = 1'b1; 
            else finishes = 1'b0;
            scenario[jobName].jobConfig                                                             = configs[configName];
            scenario[jobName].jobCallName                                                           = callName;
            scenario[jobName].finishes                                                              = finishes;
            if (dependencyName != "") scenario[jobName].dependencies[dependencyName].dependencyType = getDependencyType(dependencyType);
          end
      end
  
      // Close the file
      $fclose(fileHandle);
      return scenario;
  endfunction

  function cfgList_t readConfig();
    automatic int fileHandle;
    string configFile;
    automatic string line;
    int eof;
    automatic cfgList_t configs;

    // Open the CSV file
    if (!$value$plusargs("configFile=%s", configFile)) begin
        $error("No configFile argument provided.");
    end

    fileHandle = $fopen(configFile, "r");
    if (fileHandle == 0) begin
        $display("Error: Could not open file %s", configFile);
        return configs;
    end

    // Read and skip the header
    $fgets(line, fileHandle);
  
    // Read each line
    while (!$feof(fileHandle)) begin
        automatic string fields[];
        // Parse the CSV row
        $fgets(line, fileHandle);
        if (line != "") begin
            automatic string cfgName;
            automatic string varName;
            automatic string varType;
            automatic string varValue;
            automatic stringList_t varValues;
            fields    = splitString(line, ",");
            cfgName   = fields[0];
            varName   = fields[1];
            varType   = fields[2];
            varValue  = fields[3];
            varValues = splitString(fields[4].substr(1, fields[4].len()-2), " ");
        
            // create config object based off var type
            case (varType)
                "strings":    configs[cfgName].strings[varName] = varValue;
                "stringList": configs[cfgName].stringList[varName] = varValues;
                "ints":       configs[cfgName].ints[varName] = varValue.atoi();// convert the string to an integer
                "bool":       configs[cfgName].bool[varName] = varValue.atoi();
                default: $error($sformatf("Could not decode the variable type %s provided for config %s", varType, cfgName));
            endcase
        end
    end
    // Close the file
    $fclose(fileHandle);
    return configs;
  endfunction

  function dependency_e getDependencyType(string name);
    case(name)
        "onFinish"  : return onFinish;
        "onMsgAvail": return onMsgAvail;
        ""          : return onFinish;
        default: $error($sformatf("Could not decode the dependency type %s", name));
    endcase
  endfunction

  function stringList_t splitString(string line, string delimiter);
      automatic string result[];  // Dynamic array to hold split parts
      automatic int idx;
      result = {};
  
      while (line != "") begin
          idx = find(line, delimiter);  // Find the position of the delimiter
          if (idx != -1) begin
              result = {result, line.substr(0, idx-1)}; // Append substring before delimiter
              line = line.substr(idx + 1, line.len()-1); // Remove processed part
          end else begin
              if (string'(line[line.len()-1]) == "\n") result = {result, line.substr(0, line.len()-2)}; //remove newline
              else result = {result, line}; // Append the remaining part
              line = "";               // Exit the loop
          end
      end
      return result; // Return the dynamic array
  endfunction

  function int find(string str, string searchChar);
    for (int i = 0; i < str.len(); i++) begin
        if (string'(str[i]) == searchChar) begin
            return i; // Return the index of the first match
        end
    end
    return -1; // Return -1 if not found
  endfunction

  function void printMsg(string message, string jobName, string jobCallName);
    $display($sformatf("[%t][job Manager][%s : %s] %s", $realtime(), jobName, jobCallName, message));
  endfunction

  function bit compareMsg(msg_t msgA, msg_t msgB);

    // strings compare
    if (msgA.strings.size() != msgB.strings.size()) begin
        $display($sformatf("error, message string length mismatch, %d != %d", msgA.strings.size(), msgB.strings.size()));
        return 0;
    end
 
    foreach (msgA.strings[x]) begin
        if (msgA.strings[x] != msgB.strings[x] && x != "NAME") begin
            $display($sformatf("error, message strings element %s mismatch, %s != %s", x, msgA.strings[x], msgB.strings[x]));
            return 0;
        end
    end

    // stringList compare
    //if (msgA.stringList.size() != msgB.stringList.size()) begin
    //    $display($sformatf("error, message stringList length mismatch, %d != %d", msgA.stringList.size(), msgB.stringList.size()));
    //    return 0;
    //end
//
    //foreach (msgA.stringList[x]) begin
//
    //    if (msgA.stringList[x].size() != msgB.stringList[x].size()) begin
    //        $display($sformatf("error, message stringList length mismatch, %d != %d", msgA.stringList[x].size(), msgB.stringList[x].size()));
    //        return 0;
    //    end
//
    //    foreach (msgA.string)
//
    //    if (msgA.stringList[x] != msgA.stringList[x]) begin
    //        $display($sformatf("error, message stringList element %s mismatch, %s != %s", x, msgA.stringList[x], msgB.stringList[x]));
    //        return 0;
    //    end
    //end
   
    // ints compare
    if (msgA.ints.size() != msgB.ints.size()) begin
        $display($sformatf("error, message ints length mismatch, %d != %d", msgA.ints.size(), msgB.ints.size()));
        return 0;
    end

    foreach (msgA.ints[x]) begin
        if (msgA.ints[x] != msgB.ints[x]) begin
            $display($sformatf("error, message ints element %s mismatch, %d != %d", x, msgA.ints[x], msgB.ints[x]));
            return 0;
        end
    end

    // bits compare
    if (msgA.bits.size() != msgB.bits.size()) begin
        $display($sformatf("error, message bits length mismatch, %d != %d", msgA.bits.size(), msgB.bits.size()));
        return 0;
    end

    foreach (msgA.bits[x]) begin
        if (msgA.bits[x] != msgB.bits[x]) begin
            $display($sformatf("error, message bits element %s mismatch, %b != %b", x, msgA.bits[x], msgB.bits[x]));
            return 0;
        end
    end

    // bool compare
    if (msgA.bool.size() != msgB.bool.size()) begin
        $display($sformatf("error, message bool length mismatch, %d != %d", msgA.bool.size(), msgB.bool.size()));
        return 0;
    end

    foreach (msgA.bool[x]) begin
        if (msgA.bool[x] != msgB.bool[x]) begin
            $display($sformatf("error, message bool element %s mismatch, %b != %b", x, msgA.bool[x], msgB.bool[x]));
            return 0;
        end
    end

    return 1;
  endfunction
