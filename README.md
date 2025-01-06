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

# Build Steps

## Dependencies
Inorder to run vtb you need to have the following tools installed:
1) go, at least version go1.23.2 linux/amd64
2) slang version 7.0.14+2ba40871 https://github.com/MikePopoloski/slang
3) verilator version 5.030 2024-10-27 rev v5.030-45-g2cb1a8de7 https://github.com/verilator

once those are build you need to set the env variables associated with thier binaries. An example script is provided in env.sh

## build go exe
the vtb executable can be build with go build and run with ./vtb
## Create Project Directory
An example project has been created already in in vtb/examples/simpleDutExample. This example project was create with the following cmd: 
```
./vtb create tb -f ./examples/duts/simpleDut.f -t simpleDut -p ./examples/simpleDutExample/
```
In this stage, a design file .f, a design top name, and a project must be provided. A projEnv.sh is also generated that sets the $PROJECTDIR variable that makes running sims easier and should be sourced.
## Run a Sim
The example project can be run with
```
./vtb sim -s scenario1
```
All yaml files within the ./examples/simpleDutExample/verif/scenarios are processed with this command and any scenarion within them can be run.
