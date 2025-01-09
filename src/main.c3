import std::io;
import cache, github;

def AddWorkflow = fn void(Workflows*, Workflow);

fn void main()
{
    Allocator allocator = allocator::heap();
    @pool(allocator) {
        Cache(<Workflows>) workflows = cache::new(<Workflows>)("workflows.json", &action::load, allocator);
        defer workflows.free(&Workflows.free);

        workflows.call_data(AddWorkflow, &Workflows.add, { 1, "a", "e1", "123", "img.png", "ok", "2025-01-01T00:00:00", "234" });
        workflows.call_data(AddWorkflow, &Workflows.add, { 2, "b", "e2", "456", "img.png", "err", "2025-01-01T00:00:00", "3845" });
        workflows.call_data(AddWorkflow, &Workflows.add, { 3, "c", "e3", "789", "img.png", "ok", "2025-01-01T00:00:00", "5" });
        io::printfn("%s", workflows.data);
        // workflows.save();
    };
}

