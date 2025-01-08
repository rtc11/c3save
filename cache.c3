module cache(<Data>);
import std::io;

struct Cache (Printable) {
    bool dirty;
    Data data;
}

macro Cache.push(Cache* self, $FnType, void* function, ...)
{
    self.dirty = true;
    (($FnType) function)(&self.data, $vasplat);
}
