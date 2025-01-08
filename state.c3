module state;
import std::io;
import std::math;
import std::encoding::json;
import std::collections::object;

distinct State = void*;

struct StateImpl (Printable) {
    Workflow*[] workflows;
    int idx;
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

fn State new()
{
    StateImpl* impl = mem::temp_alloc(StateImpl);
    uint capacity = math::next_power_of_2(16);
    *impl = {
        .workflows = allocator::new_array(allocator::heap(), Workflow*, capacity)
    };
    return (State) impl;
}

fn State load(String filename)
{
    State state = new();
    String! content = (String)file::load_temp(filename);
    if (catch err = content) {
        io::printfn("INFO: creating %s", filename);
        file::save(filename, "")!!;
        return state;
    } else {
        io::printfn("INFO: loading %s", filename);
        if (content.len == 0) {
            io::printfn("INFO: empty file, initializing");
            return state;
        }


        Object* json = json::parse_string(content)!!;
        defer json.free();

        Object* workflows = json.get("workflows")!!;
        for(int i; i < workflows.get_len(); i++) {
            Workflow w = Workflow {
                .id = workflows.get_at(i).get_int("id")!!,
                .name = workflows.get_at(i).get_string("name")!!,
                .event = workflows.get_at(i).get_string("event")!!,
                .commit = workflows.get_at(i).get_string("commit")!!,
                .img = workflows.get_at(i).get_string("img")!!,
                .state = workflows.get_at(i).get_string("state")!!,
                .build_at = workflows.get_at(i).get_string("build_at")!!,
                .duration = workflows.get_at(i).get_string("duration")!!,
            };
            
            state.add(w);
        }

        return state;
    }
}

fn void State.add(&self, Workflow w)
{
	StateImpl* state = (StateImpl*)*self;
	Workflow* wf = allocator::new(allocator::heap(), Workflow, w);
    state.workflows[state.idx++] = wf;
}

fn String State.to_string(&self, Allocator allocator = allocator::heap()) @dynamic 
{
    @pool(allocator)
    {
        StateImpl* state = (StateImpl*)*self;
        if (state.idx == 0) {
            return `{ "workflows": [] }`;
        } else {
            Workflow*[] wfs = state.workflows[0..state.idx - 1];
            return string::format(`{ "workflows": %s }`, wfs, allocator: allocator); 
        }
    };
}

fn String Workflow.to_string(&self, Allocator allocator = allocator::heap()) @dynamic
{
    @pool(allocator)
    {
        return string::format(
`
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
        allocator: allocator);
    };
}
