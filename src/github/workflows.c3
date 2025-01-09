module github::action;
import std::io;
import std::math;
import std::encoding::json;
import std::collections::object;

const uint DEFAULT_CAPACITY = 16;

distinct Workflows = void*;

struct WorkflowsImpl (Printable) {
    Workflow*[] workflows;
    Allocator allocator;
    int idx;
    uint capacity;
}

struct Workflow (Printable) {
    uint id;
    String name;
    String event;
    String commit;
    String img;
    String state;
    String build_at;
    String duration;
}

fn Workflows new(uint capacity = DEFAULT_CAPACITY, Allocator allocator)
{
    WorkflowsImpl* impl = allocator::alloc(allocator, WorkflowsImpl);
    *impl = {
        .workflows = allocator::new_array(allocator, Workflow*, math::next_power_of_2(capacity)),
        .allocator = allocator,
        .capacity = capacity,
    };
    return (Workflows) impl;
}

fn Workflows load(String filename, Allocator allocator)
{
    Workflows workflows = new(allocator: allocator);
    String! content = (String)file::load_new(filename, allocator);
    if (catch err = content) {
        io::printfn("INFO: creating %s", filename);
        file::save(filename, "")!!;
        return workflows;
    } 

    io::printfn("INFO: loading %s", filename);
    if (content.len == 0) {
        io::printfn("INFO: empty file, initializing");
        return workflows;
    }

    Object*! json = json::parse_string(content, allocator)!!;
    defer (void)json.free();

    Object* json_wfs = json.get("workflows")!!;
    for(int i; i < json_wfs.get_len(); i++) {
        Workflow w = {
            .id = json_wfs.get_at(i).get_uint("id")!!,
            .name = json_wfs.get_at(i).get_string("name").copy()!!,
            .event = json_wfs.get_at(i).get_string("event").copy()!!,
            .commit = json_wfs.get_at(i).get_string("commit").copy()!!,
            .img = json_wfs.get_at(i).get_string("img").copy()!!,
            .state = json_wfs.get_at(i).get_string("state").copy()!!,
            .build_at = json_wfs.get_at(i).get_string("build_at").copy()!!,
            .duration = json_wfs.get_at(i).get_string("duration").copy()!!,
        };
        
        workflows.add(w);
    }

    return workflows;
}

fn void Workflows.add(&self, Workflow w)
{
    WorkflowsImpl* workflows = (WorkflowsImpl*)*self;
    if (workflows.idx >= workflows.capacity) workflows._resize();
	Workflow* wf = allocator::new(workflows.allocator, Workflow, w);
    workflows.workflows[workflows.idx++] = wf;
}

fn void Workflows.free(&self)
{
    io::printfn("INFO: free workflows");
    if(!self) return;
	WorkflowsImpl* workflows = (WorkflowsImpl*)*self;
    workflows.workflows = {};
    allocator::free(workflows.allocator, workflows.workflows.ptr);
    allocator::free(workflows.allocator, workflows);
}

fn void WorkflowsImpl._resize(&self) @private
{
    io::printfn("INFO: resize workflows");
    Workflow*[] old_wfs = self.workflows; 
    uint old_capacity = old_wfs.len;
    uint new_capacity = old_capacity * 2;
    Workflow*[] new_wfs = allocator::new_array(self.allocator, Workflow*, new_capacity);
    self.capacity = new_capacity;
    self._transfer(new_wfs);
    self.workflows = new_wfs;
}
fn void WorkflowsImpl._transfer(&self, Workflow*[] new_wfs) @private
{
    foreach(int i, Workflow *w: self.workflows) {
        if (!w) continue;
        new_wfs[i] = w;
    }
}

fn usz! Workflows.to_format(&self, Formatter* formatter) @dynamic
{
    WorkflowsImpl* workflows = (WorkflowsImpl*)*self;
    switch (workflows.idx) {
        case 0:  return formatter.printf(
`{ 
    "workflows": [] 
}`);
        default: return formatter.printf(
`{
    "workflows": %s
}`, workflows.workflows[0..workflows.idx - 1]); 
    }
}

fn usz! Workflow.to_format(&self, Formatter* formatter) @dynamic
{
    return formatter.printf(`
    {
        "id" : %d,
        "name": "%s",
        "event": "%s",
        "commit": "%s",
        "img": "%s",
        "state": "%s",
        "build_at": "%s",
        "duration": "%s"
    }`, 
        self.id, 
        self.name,
        self.event,
        self.commit,
        self.img,
        self.state,
        self.build_at,
        self.duration,
    );
}

