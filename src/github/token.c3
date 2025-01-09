module github::token;
import std::time;
import std::io;
import std::collections::object;

distinct Token = String;
distinct Exp = long;

struct GHToken (Printable) {
    Token access;
    String[] scopes;
    Exp expire_in; 
    DateTime expire_at; 
    Token refresh;
    Exp refresh_in;
}

fn GHToken from_json_str(String json)
{
    return GHToken {
        .access = "123secret456",
        .scopes = { "a", "b" },
        .expire_in = 60*60,
        .expire_at = datetime::now(),
        .refresh = "fresh",
        .refresh_in = 60*60*60,
    };
}

fn String DateTime.to_str(&self)
{
    return string::tformat("%04d-%02d-%02dT%02d:%02d:%02dZ", 
        self.year, self.month.ordinal+1, self.day, self.hour, self.min, self.sec);
}
fn String GHToken.to_string(&self, Allocator allocator = allocator::heap()) @dynamic
{
    DString scopes;
    foreach(s: self.scopes) {
        scopes.append(string::tformat(`"%s",`, s));
    }
    return string::tformat(
`{
    "access" : "%s",
    "scopes": [%s],
    "expire_in": %d,
    "expire_at": "%s",
    "refresh": "%s",
    "refresh_in": %d
}`, self.access, scopes.str_view()[..^2], self.expire_in, self.expire_at.to_str(), self.refresh, self.refresh_in);
}

