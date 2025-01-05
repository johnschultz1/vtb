# vtb
verilator testbench gen
# Overview
The highest level of stimulus generation is a scenario, which is defined through a yaml file. The scenario model is meant to speed up the job of sequencing, making connections, memory safe operations, have upfront testbench planning integrate directly into development, and improve validation of the testing throughout every stage of verification. The main component of a scenario is a Job. Jobs are defined inside of system verilog classes as a task. The jobs can be configured at runtime through configuration objects, that are defined through yaml files.

## Schema

Example:
```yaml
scenario:
  name: scenario1 
  globalconfig:
    -
      name: globals
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
      config: dly6
      dependencies:
      -
        name: rst
        type: onFinish
    -

```
## Jobs


## Dependencies

Declaring dependencies creates dependency graphs that can help with planning and visualzation of your checking and stimulus networks. Dependency graphs can be connected to other sub-graphs that have already been made to help with reuse of scenario structure.

### Type

Not all jobs have the same type of dependency. Are you waiting on data? A response? For it to finish? that is what the type field is used to clarify. Dependency type can be one of or of several different configurations from the list below.


```
onFinish
onMsgAvail
onErr (not implemented)
onOk (not implemented)

onFinish, onOk 
onFinish, onErr
onFinish, onMsgAvail
onMsgAvail, onOk
onMsgAvail, onErr
```
#### onOk
This dependency describes is the explicit combination of onFinish and !onErr. When a parent job finishes with no errors and a child has this relationship, the child job will be started. This could be used for haulting opertions if the preceding parent job does not finish correctly.
#### onErr
When a parent job reports an error and a child has this relationship, the child job will be started. This could be used for error reporting or error tracing operations. For example, if a parent job finishs with an error reported a diagnostic job could be started to pull more information for debugging, or trigger logger verbosity uptick messages to jobs.
#### onFinish
When a parent job finishes and a child has this relationship, the child job will be started. This represents a pure job trigger, with no msg communication between the jobs.
#### onMsgAvail
When a parent job has a message published, the child job will be started and passed messages as long as they are available from the parent job. If a parent job finishes and all of its messages have been consumed by the child job then the child job will also finish.