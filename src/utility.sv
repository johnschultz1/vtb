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
          automatic string msgType;
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
            msgType             = fields[5];
            if (fields[6] == "true") finishes = 1'b1; 
            else finishes = 1'b0;
            $display(jobName);
            scenario[jobName].jobConfig                                                             = configs[configName];
            scenario[jobName].jobCallName                                                           = callName;
            scenario[jobName].finishes                                                              = finishes;
            if (dependencyName != "") scenario[jobName].dependencies[dependencyName].dependencyType = getDependencyType(dependencyType);
            if (dependencyName != "") scenario[jobName].dependencies[dependencyName].messageType    = msgType;
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
