module cache(<Data>);
import std::io;
import log;

def Load = fn Data(String, Allocator);
def Free = fn void(Data*);

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

macro Cache.free(Cache* self, Free free) => free(&self.data);

macro Cache.call_data(Cache* self, $FnType, void* function, ...)
{
    self.dirty = true;
    return (($FnType) function)(&self.data, $vasplat);
}

macro Cache.save(Cache* self)
{
    @pool()
    {
        if (!self.dirty) return; 
        log::random("saving %s", self.filename);
        file::save(self.filename, string::tformat("%s", self.data))!!;
        self.dirty = false;
    };
}
