module log;
import std::io;
import std::time;
import std::math::random; 

const String RESET_COLOR = "\x1b[0m";
distinct Timestamp = DateTime;
def Color = int[3];

fn Timestamp now() => (Timestamp) datetime::now();
fn usz! Timestamp.to_format(&self, Formatter* formatter) @dynamic => formatter.printf("%02d:%02d:%02d", self.hour, self.min, self.sec);

macro debug(String format, ...) => io::printfn("%s %s ".concat(format), now(), "DEBUG".fg({ 69, 133, 136 }), $vasplat)!!;
macro info(String  format, ...) => io::printfn("%s %s ".concat(format), now(), "INFO ".fg({ 120, 240, 120 }),$vasplat)!!;
macro warn(String  format, ...) => io::printfn("%s %s ".concat(format), now(), "WARN ".fg({ 250, 200, 0 }), $vasplat)!!;
macro error(String format, ...) => io::printfn("%s %s ".concat(format), now(), "ERROR".fg({ 250, 100, 100 }), $vasplat)!!;
macro random(String format, ...)  => io::printfn("%s %s ".concat(format.fg(random_color())), string::new_format("%s", now()).fg(random_color()), "INFO ".fg(random_color()), $vasplat)!!;

fn Color random_color() => { rand(150)+50, rand(150)+50,rand(150)+50 };
fn String String.fg(&self, Color color) => string::new_format("\x1b[38;2;%d;%d;%d;m%s%s", color[0], color[1], color[2], *self, RESET_COLOR);
fn String String.bg(&self, Color color) => string::new_format("\x1b[48;2;%d;%d;%d;m%s%s", color[0], color[1], color[2], *self, RESET_COLOR);

