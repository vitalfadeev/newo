import std.algorithm.searching : startsWith, countUntil;
import std.algorithm.searching : countUntil;
import std.uni : isWhite, isAlpha, isAlphaNum;
import std.array : replicate;
import std.string : replace;
import std.conv : to;
import std.stdio : writeln;


import o : O, Comparator, Setter, Color, Checkers, StateMasks, StateMask, MatchedStates, Registry;
import helpers : TextReader;


class NotName      : Exception { this (string msg) { super(msg); } }
class NotComment   : Exception { this (string msg) { super(msg); } }
class NotAttr      : Exception { this (string msg) { super(msg); } }
class NotAttrName  : Exception { this (string msg) { super(msg); } }
class NotEq        : Exception { this (string msg) { super(msg); } }
class NoColon      : Exception { this (string msg) { super(msg); } }
class NotAttrValue : Exception { this (string msg) { super(msg); } }
class NotString    : Exception { this (string msg) { super(msg); } }
class NotClass     : Exception { this (string msg) { super(msg); } }
class NotClassName : Exception { this (string msg) { super(msg); } }
class NotState     : Exception { this (string msg) { super(msg); } }
class NotStateName : Exception { this (string msg) { super(msg); } }
class NotDqString  : Exception { this (string msg) { super(msg); } }
class NotSqString  : Exception { this (string msg) { super(msg); } }
class NotDelimiter : Exception { this (string msg) { super(msg); } }
class NotIndent    : Exception { this (string msg) { super(msg); } }
class NotQuadro    : Exception { this (string msg) { super(msg); } }
class NotOn        : Exception { this (string msg) { super(msg); } }
class NotComparator : Exception { this (string msg) { super(msg); } }
class NoSetterFound : Exception { this (string msg) { super(msg); } }
class NoComparatorFound : Exception { this (string msg) { super(msg); } }


auto read_comment(TextReader reader) {
    if (reader.s[reader.pos..$].startsWith("//")) {
        foreach (c; reader) {
            if (c == '\n') {
                reader.popFront(); // skip '\n'
                break;
            }
        }
    }
    else {
        throw new NotComment("");
    }
}


struct DqString {
    string s;
    
    auto from_string(TextReader reader) {
        auto spos = reader.pos;
        
        foreach (c; reader) {
            if (c == '"') {
                s = reader.s[spos..reader.pos];
                return; // OK
            }
        }
        
        reader.set_pos(spos);
        throw new NotDqString("");
    }
}


struct SqString {
    string s;
    
    auto from_string(TextReader reader) {
        auto spos = reader.pos;
        
        foreach (c; reader) {
            if (c == '\'') {
                s = reader.s[spos..reader.pos];
                return; // OK
            }
        }
        
        reader.set_pos(spos);
        throw new NotDqString("");
    }
}


struct AttrNameValue {
    string name;
    string value;
    string comparator;


    void read_name(TextReader reader) {
        AttrName nm;
        nm.from_string(reader);
        name = nm.s;
    }

    
    void read_comparator(TextReader reader) {
        // == < > >= <= | & !        
        if (!reader.empty) {
            auto spos = reader.pos;
            auto c = reader.front;
            
            if (reader.s[reader.pos..$].startsWith("==")) {
                comparator = "==";
                reader.popFront();
                reader.popFront();
                return;
            }
            if (reader.s[reader.pos..$].startsWith(">=")) {
                comparator = ">=";
                reader.popFront();
                reader.popFront();
                return;
            }
            if (reader.s[reader.pos..$].startsWith("<=")) {
                comparator = "<=";
                reader.popFront();
                reader.popFront();
                return;
            }
            if (c == '<') {
                comparator = "<";
                reader.popFront();
                return;
            }
            if (c == '>') {
                comparator = ">";
                reader.popFront();
                return;
            }
            if (c == '|') {
                comparator = "|";
                reader.popFront();
                return;
            }
            if (c == '&') {
                comparator = "&";
                reader.popFront();
                return;
            }
            if (c == '!') {
                comparator = "!";
                reader.popFront();
                return;
            }                            
        }
        
        throw new NotComparator(reader.get_pos_as_string());
    }

    
    void read_value(TextReader reader) {
        // [A-Za-z0-9_.]* <\n>
        auto spos = reader.pos;
        auto i = reader.pos;
        
        foreach (c; reader) {
            i = reader.pos;
            
            try {
                if (c.isAlphaNum())
                    continue;
                if (c == '_')
                    continue;
                if (c == '.')
                    continue;
                if (c == '"') {
                    DqString s;
                    s.from_string(reader);
                }
                if (c == '\'') {
                    SqString s;
                    s.from_string(reader);
                }
                else {
                    if (c == ' ') {
                        value = reader.s[spos..reader.pos];
                        return; // OK
                    }
                    if (c == '\n') {
                        value = reader.s[spos..reader.pos];
                        reader.popFront();
                        return; // OK
                    }
                    throw new NotAttrValue("");
                }
            }
            catch (NotDqString e) {
                reader.set_pos(i);
                reader.popFront();
            }
            catch (NotSqString e) {
                reader.set_pos(i);
                reader.popFront();
            }
        }
    }
    
    
    auto read_spaces(TextReader reader) {
        foreach (c; reader) {
            if (c == ' ')
                continue;
            else 
                return;
        }
    }


    void from_string(TextReader reader) {        
        auto spos = reader.pos;
        
        try {
            read_name(reader);
            read_spaces(reader);
            
            try {
                read_comparator(reader);
            }
            catch (NotComparator e) {
                comparator = "=="; // default comparator
            }
            
            read_spaces(reader);
            read_value(reader);
        }
        catch (NotName e) {
            throw new NotAttr("");
        }
        catch (NotDelimiter e) {
            throw new NotAttr("");
        }
        catch (NotAttrValue e) {
            throw new NotAttr("");
        }
        
        if (reader.pos == spos) {
            throw new NotAttr("");
        }
    }
}


struct Quadro {
    void* nature;
    void* future;
    Comparator comparator;
    Setter setter;

    Z z;
    //State* state;
    string name;
    string value;
    string comparator_name;


    void from_string(TextReader reader, Z z) {
        auto spos = reader.pos;
        
        try {
            AttrNameValue a;
            a.from_string(reader);
            name = a.name;
            value = a.value;
            comparator_name = a.comparator;
            z = z;
            
            nature      = z.get_nature_by_name  (a.name);
            future      = z.create_future       (a.name, a.value);
            comparator  = z.get_comparator      (a.name, a.value, comparator_name);
            setter      = z.get_setter          (a.name, a.value);
        } 
        catch (NotAttr e) {
            reader.set_pos(spos);
            throw new NotQuadro("");
        }
    }
    
    
    bool opEquals(const Quadro r) {
        return (
            nature == r.nature &&
            future == r.future &&
            comparator == r.comparator &&
            setter == r.setter
        );
    }


    void dump(int level=0) {
        writeln(replicate("  ", level), "Quadro("~this.name~", "~this.value~")");
    }
}


struct State {
    string name;
    Quadro[] quadros;
    
    
    void read_name(TextReader reader) {
        Name nm;        
        nm.from_string(reader);
        name = nm.s;
    }


    auto read_spaces(TextReader reader) {
        foreach (c; reader) {
            if (c == ' ') {
                continue;
            }
            else {
                return;
            }
        }
    }


    auto read_nl(TextReader reader) {
        foreach (c; reader) {
            if (c == '\n') {
                continue;
            }
            else {
                return;
            }
        }
    }


    void read_quadros(TextReader reader, Indent base_indent, Z z) {
        for (auto i = reader.pos; !reader.empty; i = reader.pos) {

            try {
                Indent indent;
                indent.from_string(reader);
                
                if (indent > base_indent) {
                    Quadro q;
                    q.from_string(reader, z);
                    quadros ~= q;
                }
                else {
                    reader.set_pos(i);
                    return;
                }
            }
            catch (NotIndent e) {
                reader.set_pos(i);
                return;
            }
            catch (NotQuadro e) {
                reader.set_pos(i);
                return;
            }
        }
    }


    void from_string(TextReader reader, Indent base_indent, Z z) {
        // read name
        // read quadros
        // indents
        auto i = reader.pos;
        
        try {
            Indent indent;
            indent.from_string(reader);
            
            if (indent > base_indent) {
                read_name(reader);
                read_spaces(reader);
                read_nl(reader);
                read_quadros(reader, indent, z);
            }
        }
        catch (NotIndent e) {
            reader.set_pos(i);
            throw new NotState("");
        }
        catch (NotName e) {
            reader.set_pos(i);
            throw new NotState("");
        }
    }


    void dump(int level=0) {
        writeln(replicate("  ", level), "State("~this.name~")");
        
        foreach(quadro; quadros) {
            quadro.dump(level+1);
        }
    }
}


struct Indent {
    size_t chars;
    
    void from_string(TextReader reader) {
        foreach (c; reader) {
            if (c == ' ') {
                chars++;
                continue;
            }
            else {
                return; // OK
            }
        }
        
        if (chars == 0)
            throw new NotIndent(""); // FAIL
    }

    
    int opCmp(Indent r) {
        if (chars < r.chars) return -1;
        if (chars > r.chars) return 1;
        return 0;
    }
}


struct Name {
    string s;
    

    void from_string(TextReader reader) {        
        auto first = reader.front;
        
        if (first.isAlpha()) {
            auto spos = reader.pos;
            reader.popFront();
            
            foreach (c; reader) {
                if (c.isAlphaNum())
                    continue;
                
                if (c == ' ') {
                    s = reader.s[spos..reader.pos];
                    return; // OK
                }
                
                if (c == '\n') {
                    s = reader.s[spos..reader.pos];
                    return; // OK
                }
                
                throw new NotName(""); // FAIL
            }

            return; // OK
        }
        
        throw new NotName(""); // FAIL
    }    
}


struct AttrName {
    string s;
    

    void from_string(TextReader reader) {
        auto first = reader.front;
        
        if (first.isAlpha() || first == '.' || first == '_') {
            auto spos = reader.pos;
            reader.popFront();
            
            foreach (c; reader) {
                if (c.isAlphaNum())
                    continue;
                if (c == '.')
                    continue;
                if (c == '_')
                    continue;
                
                if (c == ' ') {
                    s = reader.s[spos..reader.pos];
                    return; // OK
                }
                
                if (c == '\n') {
                    s = reader.s[spos..reader.pos];
                    return; // OK
                }
                
                throw new NotName(""); // FAIL
            }

            return; // OK
        }
        
        throw new NotName(""); // FAIL
    }    
}


struct On {
    string name;
    string[] state_names;
    
    
    void read_name(TextReader reader) {
        Name nm;
        nm.from_string(reader);
        name = nm.s;
    }
    
    
    void read_state_names(TextReader reader, Indent base_indent) {
        for (auto i = reader.pos; !reader.empty; i = reader.pos) {
            try {
                Indent indent; 
                indent.from_string(reader);
                
                if (indent > base_indent) {
                    Name nm; 
                    nm.from_string(reader);
                    
                    state_names ~= nm.s;
                    
                    read_spaces(reader);
                    read_nl(reader);
                }
                else {
                    reader.set_pos(i);
                    return;
                }
            }
            catch (NotIndent e) {
                reader.set_pos(i);
                return;
            }
            catch (NotName e) {
                reader.set_pos(i);
                return;
            }            
        }
    }
    
    
    auto read_spaces(TextReader reader) {
        foreach (c; reader) {
            if (c == ' ') {
                continue;
            }
            else {
                return;
            }
        }
    }


    auto read_nl(TextReader reader) {
        foreach (c; reader) {
            if (c == '\n') {
                continue;
            }
            else {
                return;
            }
        }
    }
    
    
    void from_string(TextReader reader, Indent base_indent, Z z) {
        for (auto i = reader.pos; !reader.empty; i = reader.pos) {
            try {
                Indent indent;
                indent.from_string(reader);
                
                if (indent > base_indent) {                    
                    if (reader.s[reader.pos..$].startsWith("on ")) {
                        foreach(c; "on ")
                            reader.popFront(); // skip "on "
                            
                        read_spaces(reader);
                        read_name(reader);
                        read_nl(reader);
                        read_state_names(reader, indent);
                    }
                }
                else {
                    // indent
                    reader.set_pos(i);
                    return;
                }
            }
            catch (NotIndent e) {
                reader.set_pos(i);
                return;
            }
            catch (NotName e) {
                reader.set_pos(i);
                throw new NotOn("");
            }
        }
    }    


    void dump(int level=0) {
        writeln(replicate("  ", level), "On("~this.name~")");
        
        foreach(s; state_names) {
            writeln(replicate("  ", level+1), s);
        }
    }
}


class Z : O {
    //string name; // name in O
    //State[] states; // state in O
    //On[] ons; // on in O
    
    int x, y, w, h;
    Color color;
    
    
    void* get_nature_by_name(string name) {
        if (name == "x") {
            return cast(void*)&x;
        }
        if (name == "y") {
            return cast(void*)&y;
        }
        if (name == "w") {
            return cast(void*)&w;
        }
        if (name == "h") {
            return cast(void*)&h;
        }
        if (name == "color") {
            return cast(void*)&color;
        }
        
        return null;
    }


    void* create_future(string name, string value) {
        if (name == "x") {
            auto v = new typeof(x); // create storage
            *v = to!(typeof(x))(value); // store
            return v;
        }
        
        throw new Exception("unsupported name");
    }


    Comparator get_comparator_by_type(T)(string comparator) {
        static if (is (T == string)) {
            if (comparator == "==")
                return &cmp_string;
        }
        static if (is (T == int)) {
            if (comparator == "==")
                return &cmp_int;
        }
        static if (is (T == long)) {
            if (comparator == "==")
                return &cmp_long;
        }
        
        throw new NoComparatorFound("for " ~ comparator ~ " for " ~ to!string(typeid(T)));
    }
    
    
    Comparator get_comparator(string name, string value, string comparator) {
        if (name == "x") {
            return get_comparator_by_type!(typeof(x))(comparator);
        }
            
        throw new NoComparatorFound("name, value: (" ~ name ~ ", " ~ value ~ ")");
    }
    
    
    Setter get_setter(string name, string value) {
        if (name == "x") {
            return &set_string;
        }
        
        throw new NoSetterFound("name, value: (" ~ name ~ ", " ~ value ~ ")");
    }
    
    
    bool cmp_string(void* a, void* b) {
        return *(cast(string*)a) == *(cast(string*)b);
    }
    
    
    bool cmp_int(void* a, void* b) {
        return *(cast(int*)a) == *(cast(int*)b);
    }
    
    
    bool cmp_long(void* a, void* b) {
        return *(cast(long*)a) == *(cast(long*)b);
    }
    
    
    void set_string(void* a, void* b) {
        *(cast(string*)a) = *(cast(string*)b);
    }
    
    
    void read_name(TextReader reader) {
        Name nm;
        nm.from_string(reader);
        name = nm.s;
    }
    
    
    auto read_spaces(TextReader reader) {
        foreach (c; reader) {
            if (c == ' ') {
                continue;
            }
            else {
                return;
            }
        }
    }


    auto read_nl(TextReader reader) {
        foreach (c; reader) {
            if (c == '\n') {
                continue;
            }
            else {
                return;
            }
        }
    }


    void read_states(TextReader reader, Indent base_indent) {
        for (auto i = reader.pos; !reader.empty; i = reader.pos) {
            try {
                Indent indent;
                indent.from_string(reader);
                
                if (indent > base_indent) {
                    if (reader.s[reader.pos..$].startsWith("on ")) {
                        reader.set_pos(i); // back to indent
                        On on;
                        on.from_string(reader, base_indent, this);
                        ons ~= on;
                    }
                    else {
                        reader.set_pos(i); // back to indent
                        State state;
                        state.from_string(reader, base_indent, this);
                        states ~= state;
                    }
                }
                else {
                    // indent
                    reader.set_pos(i);
                    return;
                }
            }
            catch (NotIndent e) {
                reader.set_pos(i);
                return;
            }
            catch (NotState e) {
                reader.set_pos(i);
                return;
            }
        }
    }


    void from_string(TextReader reader) {
        foreach (c; reader) {
            try {
                Indent indent;
                indent.from_string  (reader);
                read_name           (reader);
                read_spaces         (reader);
                read_nl             (reader);
                read_states         (reader, indent);
                break;
            }
            catch (NotIndent e) {
                throw new NotClass("");
            }
            catch (NotName e) {
                throw new NotClass("");
            }
        }
    }
    
    
    void dump(int level=0) {
        // name
        writeln(replicate("  ", level), "Z("~this.name~")");

        // states
        foreach(state; states)
            state.dump(level+1);
        
        // on
        foreach(on; ons)
            on.dump(level+1);
    }
}


struct Container {
    Z[] zs;


    void from_string(TextReader reader) {
        auto c = reader.front;
        
        for (auto i = reader.pos; !reader.empty; i = reader.pos) {
            c = reader.front;
            
            try {
                if (c == '\n') { // skip blank line
                    reader.popFront();
                    continue;
                } 
                if (reader.s[reader.pos..$].startsWith("//")) {
                    read_comment(reader);
                } 
                else {
                    Z z = new Z();
                    z.from_string(reader);
                    zs ~= z;
                    Registry.add(z);
                }
            } 
            catch (NotName e) {
                break;
            }
            catch (NotClass e) {
                break;
            }
            catch (NotComment e) {
                break;
            }
        }
    }
    
    
    void dump(int level=0) {
        foreach (z; zs) {
            z.dump(1);
        }
    }
}


auto parse(string text, size_t spos=0) {
    auto reader = new TextReader(text, spos);
    
    Container container;
    container.from_string(reader);
    
    container.dump();
}


auto parse_and_update(string text, size_t spos=0) {
    // parse
    // after success parse -> update
    // update checkers
    // update state masks
    
    
    // parse
    auto reader = new TextReader(text, spos);
    
    Container container;
    container.from_string(reader);
    
    container.dump();
    
    // update
    // update checkers
    foreach (z; container.zs)
        foreach (ref state; z.states)
            foreach (ref quadro; state.quadros) 
                Checkers.instance().add_checker(quadro);
    
    // update state masks
    StateMasks statemasks;
    auto l = Checkers.instance().quadros.length;
    
    foreach (z; container.zs) {
        foreach (ref state; z.states) {
            StateMask mask;
            mask.z = z;
            mask.state_name = state.name;
            mask.set.length = l;
            
            foreach (ref q; state.quadros) {
                auto i = Checkers.instance().quadros.countUntil(q);
                mask.set[i] = 1;
            }

            statemasks.masks ~= mask;
        }
    }
    
    //
    writeln("States:");
    statemasks.dump();
        
    // check
    Checkers.instance().prepare();
    Checkers.instance().check();

    //
    MatchedStates matched;
    matched.check(Checkers.instance(), statemasks);
    writeln("Matched:");
    matched.dump();

    //
    writeln("Checkers:");
    Checkers.instance().dump();    
}


// icon
//   green
//     color: green
//   on init
//     grey

