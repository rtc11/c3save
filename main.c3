import std::io;
import cache, token, state;

def AddWorkflow = fn void(State*, Workflow);

fn void main()
{
    Allocator allocator = allocator::heap();
    @pool(allocator) {
        Cache(<State>) state = cache::new(<State>)("state.json", &state::load, allocator);
        state.call_data(AddWorkflow, &State.add, { 11, "name", "event", "commit", "img", "state", "build_at", "duration" });
        state.call_data(AddWorkflow, &State.add, { 12, "name", "event", "commit", "img", "state", "build_at", "duration" });
        state.call_data(AddWorkflow, &State.add, { 13, "name", "event", "commit", "img", "state", "build_at", "duration" });
        io::printfn("%s", state.data);
        // state.save();
    };
}

