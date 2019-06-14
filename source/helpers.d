import std.algorithm.searching : count;
import std.algorithm.searching : countUntil;
import std.stdio : writeln;
import std.utf : decode;
import std.conv : to;
import std.range : retro, empty;


class TextReader {
    string s;
    size_t pos; // bytes
    size_t next; // bytes
    dchar front;

        
    this(TextReader from) {
        s = from.s;
        pos = from.pos;
        next = from.next;
        front = from.front;
    }
    
    
    this(TextReader from, size_t spos) {
        s = from.s;
        pos = spos;
        next = from.next;
        front = from.front;
    }
    
    
    this(string s, size_t spos) {
        this.s = s;
        pos = spos;
        next = spos;
        front = s.decode(next);
    }
    
    
    void set_pos(size_t new_pos) {
        // bytes
        pos = new_pos;
        next = new_pos;
        front = s.decode(next);
    }
        
        
    string get_string(size_t spos, size_t epos) {
        // return UTF-8 string
        return s[spos..epos];
    } 
    
    
    void popFront() {
        pos = next;
        front = s.decode(next);
    }
    
    
    @property
    bool empty() {
        return next >= s.length;
    }
    
    
    auto count_nl() {
        return s[0..pos].count('\n');
    }
    
    
    auto get_pos_as_string() {
        auto pos_in_line = s[0..pos].retro().countUntil('\n');
        return "line: " ~ to!string( count_nl() ) ~ ", pos: " ~ to!string(pos_in_line);
    }


    //auto opIndex() { return s[]; }
    //auto opIndex(size_t a) { return s[a]; }
    //auto opIndex(size_t a, size_t b) { return s[a..b]; }
    //auto opDollar(size_t pos)() { return s.length; }
    //auto opSlice(size_t dim)(int start, int end) { return [start, end]; }
}

