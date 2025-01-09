module cache(<Data>);
import std::io;

def Load = fn Data(String, Allocator);

struct Cache (Printable) {
    String filename;
    bool dirty;
    Data data;
}

macro Cache(<Data>) new(String filename, Load load, Allocator allocator = allocator::heap())
{
   return {
       .filename = filename,
       .data = load(filename, allocator),
   };
}

macro Cache.call_data(Cache* self, $FnType, void* function, ...)
{
    self.dirty = true;
    (($FnType) function)(&self.data, $vasplat);
}

macro Cache.save(Cache* self)
{
    @pool()
    {
        if (!self.dirty) return; 
        io::printfn("INFO: saving %s", self.filename);
        io::printfn("INFO: %s", self.data);
        file::save(self.filename, string::tformat("%s", self.data))!!;
        self.dirty = false;
    };
}
