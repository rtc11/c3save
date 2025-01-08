import std::io;
import std::core::mem;
import std::encoding::json;
import std::collections::object;
import cache, token, state;

const String FILE_STATE = "state.json";
const String FILE_TOKEN = "token.json";

def AddWorkflow = fn void(State*, Workflow);


fn void main()
{
    Cache(<State>) state = {
        .data = state::load(FILE_STATE),
    };
    io::printfn("%s", state.data);
    io::printfn("dirty: %s", state.dirty);

    // Workflow w = {
    //     .id = 6,
    //     .name = "eman",
    //     .event = "tneve",
    //     .commit = "timmoc",
    //     .img = "gmi",
    //     .state = "etats",
    //     .build_at = "ta_dliub",
    //     .duration = "noitarud",
    // };
    //
    // state.push(AddWorkflow, &State.add, w);
    // io::printfn("%s", state.data);
    // io::printfn("dirty: %s", state.dirty);

    if (state.dirty) {
        save(FILE_STATE, state.data.to_string());
    }
}

fn String load(String filename, Allocator alloc = allocator::heap())
{
    @pool(alloc)
    {
        String! content = (String)file::load_temp(filename);
        if (catch err = content) {
            io::printfn("INFO: creating %s", filename);
            file::save(filename, "")!!;
            return "";
        } else {
            io::printfn("INFO: loading %s", filename);
            return content;
        }
    };
}

fn void save(String filename, String json, Allocator alloc = allocator::heap())
{
    @pool(alloc)
    {
        io::printfn("INFO: saving %s", filename);
        Object* o = json::parse_string(json)!!;
        defer o.free();
        file::save(filename, string::tformat("%s", *o))!!;
    };
}

