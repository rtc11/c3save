import std::io;
import std::time;
import cache, github;

def AddWorkflow = fn void(Workflows*, Workflow);
def UpdateToken = fn void(Token*, String, String[], Exp, DateTime, String, Exp);

fn void main()
{
    Allocator allocator = allocator::heap();
    @pool(allocator) {
        Cache(<Workflows>) workflows = cache::new(<Workflows>)("workflows.json", &action::load, allocator);
        defer workflows.free(&Workflows.free);
        // workflows.call_data(AddWorkflow, &Workflows.add, { 1, "a", "e1", "123", "img.png", "ok", "2025-01-01T00:00:00", "234" });
        // workflows.call_data(AddWorkflow, &Workflows.add, { 2, "b", "e2", "456", "img.png", "err", "2025-01-01T00:00:00", "3845" });
        // workflows.call_data(AddWorkflow, &Workflows.add, { 3, "c", "e3", "789", "img.png", "ok", "2025-01-01T00:00:00", "5" });
        // io::printfn("%s", workflows.data);
        // workflows.save();

        Cache(<Token>) token = cache::new(<Token>)("token.json", &github::load, allocator);
        defer token.free(&Token.free);
        // token.call_data(UpdateToken, &Token.update, "123secret456", { "a", "b" }, 60*60, datetime::now(), "fresh", 60*60*24);
        io::printfn("%s", token.data);
        // token.save();
    };
}

