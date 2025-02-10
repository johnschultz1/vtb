# vtb
verilator testbench gen. A custom Job execution sceheme developed, since UVM is currently not supported by verilator. Could be used in other simulators.
# Overview
The highest level of stimulus generation here is a scenario, which is defined through a yaml file. The scenario model is meant to speed up the job of sequencing, making connections, memory safe operations, have upfront testbench planning integrate directly into development, and improve validation of the testing throughout every stage of verification. The main component of a scenario is a Job. Jobs are defined inside of system verilog classes as a task. The jobs can be configured at runtime through yaml configuration objects.

## Schema

Example:
```yaml
scenario:
  name: scenario1 
  jobs:
    -
      name: rst
      callName: toggleSeq
      config: rst
    -
      name: clk
      callName: toggleSeq
      config: clk
      finishes: false
    -
      name: dly
      callName: delay
      config: dly
      dependencies:
      -
        name: rst
        type: onFinish
    -

```

### name
This is the name of Scenario and is the name to pass when trying to execute. ex: ./vtb sim -s scenario1
### jobs
```sv
class delay;

    `startJob
        #(cfg.ints["CYCLES"]);
    `endJob

endclass;

```
This is a list of job calls that will be done, in the order that their dependencies are set to. A job is a systemverilog class that includes the startJob and endJob macro. This macro is just a task with message types as the inputs. A Job can be configured with a config yaml file.
#### name
name of the job, this is what is referenced by other jobs when they are declaring their dependencies.
#### callName
This is the name of the system verilog class. 
#### config
This is the name of the configuration object. A yaml configuration object has a reference name and a var list. The variables can be of the following types:  strings, stringList, ints, bool. Within a job these values van be accessed with cfg.{config type}["{name of config variable}"]
``` yaml
---
config:
  name: dly
  vars:
    -
      name: CYCLES
      type: ints
      value: 60
---
config:
  name: ex
  vars:
    -
      name: stringEx
      type: strings
      value: hello
    -
      name: stringListEx
      type: stringList
      values: 
        - hello
        - bye
    -
      name: intsEx
      type: int
      value: 3
    -
      name: boolEx
      type: bool
      value: false
```
### dependencies
Declaring dependencies creates dependency graphs that can help with planning and visualzation of your checking and stimulus networks.
#### name
name field should match the name field of the job the child job is dependent on
#### type
Not all jobs have the same type of dependency. Are you waiting on data? A response? For it to finish? that is what the type field is used to clarify. Dependency type can be one of or of several different configurations from the list below.

```
onFinish
onMsgAvail
onFinish, onMsgAvail
```
##### onFinish
When a parent job finishes and a child has this relationship, the child job will be started. This represents a pure job trigger, with no msg communication between the jobs. If onMsgAvail is used in combination with onFinish, the child will wait for the parent job to finish and then check to see if there is any message from the parent available, this can be used to exchange information.
##### onMsgAvail
When a parent job has a message published, the child job will be started and passed messages as long as they are available from the parent job. If a parent job finishes and all of its messages have been consumed by the child job then the child job will also finish. When onFinish and onMsgAvail on used togehther, all of the onFinish jobs will be completed before the onMsgAvail dependencies are checked to have data available for the child Job. 
# Dependencies
Inorder to build, docker has to be installed
https://docs.docker.com/engine/install/
A taskfile is also included here, so taskfile would have to be installed to run it
https://taskfile.dev/installation/
# Build Steps
A docker container has been created and can be checked out from docker hub with
```` ````
It can also be built with:

```docker build -t vtb:v0 .```

The go executable can also be generated seperatly with ```` go build ```` and the env variables in vtb/build.sh or the dockerfile set to the locations of the dependencies.
## Cmds
The entrypoint for the container is the vtb go binary. The available cmd details below.
### new proj
A project is a copy of the vtb/src/projectTemplate. ENV variable $PROJECTSHOME and $PROJECTNAME should be set before running. THey can also be set in the call to the container. The below example will create a copy of the projectTemplate in $PROJECTSHOME/$PROJECTNAME and mount the data on the host system in the same location.
````
task newProj -- -n projName
````
### import
To import the dut, a design .f file with pointers to the dut and its dependencies (-f) and a design top name (-t) must be provided. The below command imports an example dut from the vtb example directory, parses it and creates a dut wrapper and dut interface based on it.
````
cd projectDirectory
task import -- -t dutTopName -f /../../path/dutFileList.f
````
## sim
The sim cmd currently launchs verilator but could be configured to launch others. The below example runs an a prepared scenario on the dut that was imported with the import dut command.
```

```