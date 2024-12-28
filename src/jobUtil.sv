import VtbPkg::*;
import typesPkg::*;
`define taskStart(NAME) task automatic NAME (msgList_t msgs, msg_t cfg );
`define staticTaskStart(NAME) task automatic NAME (msgList_t msgs, msg_t cfg );

`define startJob function new();\
  endfunction \
              \
  task automatic startJob (msgList_t msgs, msg_t cfg, virtual dutInterface vif);

`define endJob endtask;