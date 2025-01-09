import std::io;
import cache, token, state;

def AddWorkflow = fn void(State*, Workflow);

fn void main()
{
    Allocator allocator = allocator::heap();
    @pool(allocator) {
        Cache(<State>) state = cache::new(<State>)("state.json", &state::load, allocator);
        defer state.free(&State.free);

        state.call_data(AddWorkflow, &State.add, { 1, "a", "e1", "123", "img.png", "ok", "2025-01-01T00:00:00", "234" });
        state.call_data(AddWorkflow, &State.add, { 2, "b", "e2", "456", "img.png", "err", "2025-01-01T00:00:00", "3845" });
        state.call_data(AddWorkflow, &State.add, { 3, "c", "e3", "789", "img.png", "ok", "2025-01-01T00:00:00", "5" });
        io::printfn("%s", state.data);
        // state.save();
    };
}

