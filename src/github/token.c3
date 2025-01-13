module github;
import std::collections::object;
import std::encoding::json;
import std::io;
import std::time;
import log;

distinct Token = void *;
def Exp = long;

struct TokenImpl (Printable) {
    Allocator allocator;
    String access_token;
    String[] scopes;
    Exp expire_in; 
    DateTime expire_at; 
    String refresh_token;
    Exp refresh_in;
}

fn Token load(String filename, Allocator allocator = allocator::heap())
{
    Token token = new(allocator: allocator);
    String! content = (String) file::load_new(filename, allocator);
    if (catch err = content) {
        log::random("creating %s", filename);
        file::save(filename, "")!!;
        return token;
    }

    log::random("loading %s", filename);
    if (content.len == 0) {
        log::random("%s was empty, initializing content", filename);
        return token;
    }

    Object*! json = json::parse_string(content, allocator)!!;
    defer (void)json.free();

    Object* json_scopes = json.get("scopes")!!;
    String[50] scopes;
    for(int i; i < json_scopes.get_len(); i++) {
       scopes[i] = json_scopes.get_string_at(i).copy()!!;
    }
    token.update(
        json.get_string("access_token").copy()!!,
        scopes[..json_scopes.get_len() - 1],
        json.get_long("expire_in")!!,
        json.get_string("expire_at").copy()!!.to_datetime(),
        json.get_string("refresh_token").copy()!!,
        json.get_long("refresh_in")!!,
    );

    return token;
}

fn void Token.update(&self, String access_token, String[] scopes, Exp exp_in, DateTime exp_at, String refresh_token, Exp refresh_in)
{
    TokenImpl* token = (TokenImpl*)*self;
    token.access_token = access_token;
    token.scopes = scopes;
    token.expire_in = exp_in;
    token.expire_at = exp_at;
    token.refresh_token = refresh_token;
    token.refresh_in = refresh_in;
}

fn void Token.free(&self)
{
    log::random("free token");
    if (!self) return;
    TokenImpl* token = (TokenImpl*) *self;
    allocator::free(token.allocator, token);
}

fn Token new(Allocator allocator = allocator::heap())
{
    TokenImpl* impl = allocator::alloc(allocator, TokenImpl);
    *impl = { .allocator = allocator };
    return (Token) impl;
}

fn usz! DateTime.to_format(&self, Formatter* formatter) @dynamic
{
    return formatter.printf("%04d-%02d-%02dT%02d:%02d:%02dZ",
        self.year,
        self.month.ordinal+1,
        self.day,
        self.hour,
        self.min,
        self.sec,
    );
}

// 2025-01-09T12:07:39Z
macro DateTime String.to_datetime(&self)
{
    String str = self.copy();
    return datetime::from_date(
        year:  str[0..3].to_int()!!,
        month: Month.from_ordinal(str[5..6].to_int()!! - 1),
        day:   str[8..9].to_int()!!,
        hour:  str[11..12].to_int()!!,
        min:   str[14..15].to_int()!!,
        sec:   str[17..18].to_int()!!,
    );
}

fn usz! Token.to_format(&self, Formatter* formatter) @dynamic
{
    TokenImpl* token = (TokenImpl*)*self;
    DString scopes;
    foreach(s: token.scopes) {
        scopes.append(string::tformat(`"%s",`, s));
    }

    return formatter.printf(
`{
    "access_token" : "%s",
    "scopes": [%s],
    "expire_in": %d,
    "expire_at": "%s",
    "refresh_token": "%s",
    "refresh_in": %d
}`, 
        token.access_token,
        scopes.str_view()[..^2],
        token.expire_in,
        token.expire_at,
        token.refresh_token,
        token.refresh_in,
    );
}

