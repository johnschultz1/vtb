package typesPkg;    
    // ***************************************************************
    //   __  __                                  _____        __      
    //  |  \/  |                                |_   _|      / _|     
    //  | \  / | ___  ___ ___  __ _  __ _  ___    | |  _ __ | |_ ___  
    //  | |\/| |/ _ \/ __/ __|/ _` |/ _` |/ _ \   | | | '_ \|  _/ _ \ 
    //  | |  | |  __/\__ \__ \ (_| | (_| |  __/  _| |_| | | | || (_) |
    //  |_|  |_|\___||___/___/\__,_|\__, |\___| |_____|_| |_|_| \___/ 
    //                               __/ |                            
    //                              |___/                             
    // ***************************************************************
    typedef string stringList_t[];
    typedef string intList_t[];

    typedef struct {
        string msgType;
        string strings[string];
        stringList_t stringList[string];
        int ints[string];
        bit bits[int];
        bit bool[string];
    } msg_t;

    typedef msg_t   msgList_t[string];
    typedef msg_t   cfgList_t[string];

    // Message queue types
    typedef msg_t msg_q_t[$];                       // Queue of messages
    typedef msg_q_t dependency_q_t[string];         // Dependency queues
    typedef dependency_q_t job_q_t[string];          // job queues

    // *********************************************************************
    //   _______        _      ____        _ _     _   _____        __      
    //  |__   __|      | |    |  _ \      (_) |   | | |_   _|      / _|     
    //     | | __ _ ___| | __ | |_) |_   _ _| | __| |   | |  _ __ | |_ ___  
    //     | |/ _` / __| |/ / |  _ <| | | | | |/ _` |   | | | '_ \|  _/ _ \ 
    //     | | (_| \__ \   <  | |_) | |_| | | | (_| |  _| |_| | | | || (_) |
    //     |_|\__,_|___/_|\_\ |____/ \__,_|_|_|\__,_| |_____|_| |_|_| \___/ 
    //                                                                      
    // *********************************************************************                                                                      
    typedef enum {onFinish, onMsgAvail} dependency_e;
    typedef struct {
        dependency_e dependencyType;
    } dependency_t;
    
    typedef dependency_t dependencies_t[string];

    
    typedef struct {
        dependencies_t dependencies;
        msg_t jobConfig;
        string jobCallName;
        bit finishes;
    } jobInfo_t;

    typedef jobInfo_t scenarioInfo_t[string];
    
    // ********************************************************************
    //   _______        _      ______                 _____        __      
    //  |__   __|      | |    |  ____|               |_   _|      / _|     
    //     | | __ _ ___| | __ | |__  __  _____  ___    | |  _ __ | |_ ___  
    //     | |/ _` / __| |/ / |  __| \ \/ / _ \/ __|   | | | '_ \|  _/ _ \ 
    //     | | (_| \__ \   <  | |____ >  <  __/ (__   _| |_| | | | || (_) |
    //     |_|\__,_|___/_|\_\ |______/_/\_\___|\___| |_____|_| |_|_| \___/ 
    //                                                                     
    // ********************************************************************   
    typedef time msgTypeTimes_t[$];

    typedef struct {
        time jobStartTime; // when job started
        time jobEndTime; // when job ended
        string jobStatus; // if the job is done or running or error
        bit done;
        msgTypeTimes_t consumedMsgTime;
        msgTypeTimes_t producedMsgTime;
    } jobStatus_t;

    typedef jobStatus_t jobsStatus_t[string];

    class jobEvent;
        event e;
        task setEvent();
            -> e;
        endtask

        task waitOnEvent();
            @(this.e);
        endtask

        function new();
        endfunction

    endclass
endpackage