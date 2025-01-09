module state;
import std::io;
import std::math;
import std::encoding::json;
import std::collections::object;

const uint DEFAULT_CAPACITY = 16;

distinct State = void*;

struct StateImpl (Printable) {
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

fn State new(uint capacity = DEFAULT_CAPACITY, Allocator allocator)
{
    StateImpl* impl = allocator::alloc(allocator, StateImpl);
    *impl = {
        .workflows = allocator::new_array(allocator, Workflow*, math::next_power_of_2(capacity)),
        .allocator = allocator,
        .capacity = capacity,
    };
    return (State) impl;
}

fn State load(String filename, Allocator allocator)
{
    State state = new(allocator: allocator);
    String! content = (String)file::load_new(filename, allocator);
    if (catch err = content) {
        io::printfn("INFO: creating %s", filename);
        file::save(filename, "")!!;
        return state;
    } 

    io::printfn("INFO: loading %s", filename);
    if (content.len == 0) {
        io::printfn("INFO: empty file, initializing");
        return state;
    }

    Object*! json = json::parse_string(content, allocator)!!;
    defer (void)json.free();

    Object* workflows = json.get("workflows")!!;
    for(int i; i < workflows.get_len(); i++) {
        Workflow w = {
            .id = workflows.get_at(i).get_uint("id")!!,
            .name = workflows.get_at(i).get_string("name").copy()!!,
            .event = workflows.get_at(i).get_string("event").copy()!!,
            .commit = workflows.get_at(i).get_string("commit").copy()!!,
            .img = workflows.get_at(i).get_string("img").copy()!!,
            .state = workflows.get_at(i).get_string("state").copy()!!,
            .build_at = workflows.get_at(i).get_string("build_at").copy()!!,
            .duration = workflows.get_at(i).get_string("duration").copy()!!,
        };
        
        state.add(w);
    }

    return state;
}

fn void State.add(&self, Workflow w)
{
    StateImpl* state = (StateImpl*)*self;
    if (state.idx >= state.capacity) state._resize();
	Workflow* wf = allocator::new(state.allocator, Workflow, w);
    state.workflows[state.idx++] = wf;
}

fn void State.free(&self)
{
    if(!self) return;
	StateImpl* state = (StateImpl*)*self;
    state.workflows = {};
    allocator::free(state.allocator, state.workflows.ptr);
    allocator::free(state.allocator, state);
}

fn void StateImpl._resize(&self) @private
{
    Workflow*[] old_wfs = self.workflows; 
    uint old_capacity = old_wfs.len;
    uint new_capacity = old_capacity * 2;
    Workflow*[] new_wfs = allocator::new_array(self.allocator, Workflow*, new_capacity);
    self.capacity = new_capacity;
    self._transfer(new_wfs);
    self.workflows = new_wfs;
}
fn void StateImpl._transfer(&self, Workflow*[] new_wfs) @private
{
    foreach(int i, Workflow *w: self.workflows) {
        if (!w) continue;
        new_wfs[i] = w;
    }
}

fn usz! State.to_format(&self, Formatter* formatter) @dynamic
{
    StateImpl* state = (StateImpl*)*self;
    switch (state.idx) {
        case 0:  return formatter.printf(
`{ 
    "workflows": [] 
}`);
        default: return formatter.printf(
`{
    "workflows": %s
}`, state.workflows[0..state.idx - 1]); 
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

