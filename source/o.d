// o = [name, [params], [childs]]
import std.container : DList;
import std.algorithm.mutation : remove;
import std.algorithm.searching : find;
import std.algorithm.searching : countUntil, any;
import std.algorithm.mutation : fill;
import std.algorithm.iteration : filter;
import std.range : zip, lockstep, empty, take, takeOne;
import std.stdio : writeln, write;

import parser : State, On, Quadro, Z;


// [name, [state, [props]], [on state, [states]], [childs]]
class O {
    string name;
    DList!State states;
    DList!On ons;
    O parent;
    O[] childs;

    
    void add_child(O child) {
        if (child.parent) {
            auto index = child.parent.childs.countUntil(child);
            if (index != -1) 
                child.parent.childs = child.parent.childs.remove( index );
        }
        child.parent = this;
        childs ~= child;
    }
}


struct Registry {
    static O[] oi;


    static
    auto add(O o) {
        oi ~= o;
    }
    
    
    static
    auto find_by_name(string name) {
        return oi.filter!(a => a.name == name)();
    }
}


//
// color: green
// checker('eq', color, green)
// checker('eq', [object, color], green)
// checker is eq()
//   nature - future
struct CheckResult {
    byte[] set;

    
    void clear() {
        set.fill(cast(byte)0);
    }
}


struct StateMask {
    Z z;
    string state_name;
    byte[] set;
}
    

struct StateMasks {
    StateMask[] masks;
    
    
    void dump() {
        foreach (mask; masks) {
            foreach (m; mask.set) 
                write(m ? '*' : '-', " ");
                
            write(" ", mask.z.name, ".", mask.state_name);
            writeln();
        }
    }
}


class Checkers {
    Quadro[] quadros;
    CheckResult  result0; // length = rio.length
    CheckResult  result1;
    CheckResult* result;


    this() {
        result = &result0;
    }
    
    
    static
    Checkers instance() {
        static Checkers _instance = null;
        
        if (!_instance)
            _instance = new Checkers();
            
        return _instance;
    }
    
    
    bool has(Quadro quadro) {
        return quadros.find(quadro).empty == false;
    }
    
    
    void add_checker(Quadro quadro) {
        if (!has(quadro))
            quadros ~= quadro;
    }
    
    
    void prepare() {
        result0.set.length = quadros.length;
        result1.set.length = quadros.length;
        result0.clear();
        result1.clear();
    }
    
    
    void tick() {
        result = (result == &result1) ? &result0 : &result1;
    }
    

    void check() {
        foreach(ref c,ref r; lockstep(quadros, result.set)) {
            r = c.comparator(c.nature, c.future);
        }
    }

    
    bool check_state(StateMask mask) {
        foreach (r, m; lockstep(result.set, mask.set)) {
            if (m) {
                if (r)
                    continue;
                else
                    return false;
            }
        } 

        return true;
    }
    
    
    void dump() {
        // names
        foreach(q; quadros) {
            write(q.name[0], " ");
        }
        writeln();
        
        // result
        foreach(b; result.set) {
            write(b ? "*" : "-", " ");
        }
        writeln();
    }
}


struct MatchedStates {
    StateMask*[] matched;
    
    
    void check(Checkers checkers, StateMasks statemasks) {
        matched = [];
        
        foreach (ref mask; statemasks.masks) {
            if (checkers.check_state(mask)) 
                matched ~= &mask;
        }
    }
    
    
    void dump() {
        foreach (mask; matched) {
            foreach (m; mask.set) 
                write(m ? '*' : '-', " ");
                
            write(" ", mask.z.name, ".", mask.state_name);
            writeln();
        }
    }
}


alias Comparator = bool delegate(void* nature, void* future);
alias Setter = void delegate(void* nature, void* future);


struct Color {
    byte r;
    byte g;
    byte b;
    byte a;
}


class Z1 : O {
    auto add_state(string name, Quadro[] quadros) {
        auto state = State(name, quadros);
        states ~= state;
        return state;
    }
    

    auto add_on(State st, State[] states) {
        /*
        auto on = On(st, quadro);
        ons ~= on;
        return on;
        * */
    }
    
    // states
    /*
    void load() {
        state_green = State("green",
            Quadro(&color, 0x00FF00FF, &cmp_color_rgba, &set_color_rgba)
        );
        state_grey = State("grey",
            Quadro(&color, 0xCCCCCCFF, &cmp_color_rgba, &set_color_rgba)
        );
        state_yellow = State("yellow",
            Quadro(&color, 0xFFFF00FF, &cmp_color_rgba, &set_color_rgba)
        );
        state_wifi_active = State("wifi_active",
            Quadro(&(wifi.active), 0x1, &check_wifi_active, &set_wifi_active)
        );
        state_hover = State("hover",
            Quadro(&(cursor.pos.x), &x, &gt_or_eq, &none),
            Quadro(&(cursor.pos.x), &w, &lt_or_eq, &none),
            Quadro(&(cursor.pos.y), &y, &gt_or_eq, &none),
            Quadro(&(cursor.pos.y), &h, &lt_or_eq, &none)
        );
        state_click = State("click",
            Quadro(&hover, &_, &_, &none),
            Quadro(&(mouse.buttons), MASK_LEFT, &bit_and, &none)
        }
        
        // on
        on ~= On(&state_init,
            [&state_green]
        );
        on ~= On(&state_hover, 
            [&state_yellow]
        );
        on ~= On(&state_wifi_active, 
            [&state_green]
        );
        on ~= On(&state_click, 
            [&state_wifi_active]
        );
    }
    */
}

//~ O O(string name) {
    //~ auto o = Registry.get(name);
    //~ if (o) {
        //~ return o;
    //~ } else {
        //~ auto o = new O();
        //~ o.name = name;
        //~ Registry.put(o);
        //~ return o;
    //~ }
//~ }


// [point, [], []]

// [color, #ccc,
//   [point, [], []]
// ]

// [rotate, 30, 
//   [color, #ccc,
//     [point, [1,1], []]
//   ]
// ]

// rotate 30
//   color #ccc
//     point 1,1

// star
//   path 1,1, 2,2, 3,3, 4,4, 5,5

// rotate 30
//   star

// auto star = O("star");
// star.wrap(rotate);

// rotate = new Rotate(30);
// rotate = new Rotate(); rotate.angle = 30;
// new Rotate(30);
// O("rotate");
// O(Rotate);
// O(Rotate, 30);
// O(new Rotate(30));
// O!Rotate
// O!Rotate(30)

// auto star = O("star");
// star.wrap(O!Rotate(30));

// auto star = O!Star;
// star.wrap( O!Rotate(30) );
// star.add_parent( O!Rotate(30) );

// star.Rotate(30);

//~ class Star : O {
    //~ void Rotate(int angle) {};
//~ }

//~ struct O {
    //~ void Rotate(int angle) {};
//~ }

// [context, action, childs]

// star
//   on_click - detect cursor position, check pressed
//     star.do_animation()
//     star.wrap().animation()
//     star.wrap!animation()

// animation
//   star
//     path

// star.wrap!color
// color
//   star
//     path

// animation = star.wrap!animation()
// star.wrap!color
// animation
//   color
//     star
//       path

// star
//   on_click:
//     @animation

// animation
//   star.clicked

// star.clicked
//   .animation

// star x=10

// green
//   color = 0f0

// green
//   star

// on_click - is the state when cursor in area and pressed button

// all states
// checker is main func, executed each tick
//   checker check each state
//     if state nice, then execute script

// optimisation
// states collected in table
//   indexed

// let
// delet

// star
//   .open()
//
// star
//   .deopen()

// star.closed -> star.opened -> star.closed

// star
//   .opened
//     ...
//   .closed
//     ...
//   .default
//     ...
//   transitions:
//     opened -> closed
//     closed -> opened
//     ...
//   .clicked()
//     change_state()
//
//   .opened
//     w = 100     // all properties is the .opened state
//     h = 400     //   object is .opened
//     opacity = 1 //
//     visible = 1 //
//
//   .state2
//     w = 100      // also known as .opened state, because same properties
//     h = 400      //  object is .opened
//     opacity = 1  //
//     visible = 1  //
//     color = #ccc //
//

//  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32
//  1  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0
//  1  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0
// checker
// is checked - 0|1 - unchecked | checked
// is ok - 0|1 - ok|no

//  1  0  0  1  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0 - green
//  0  1  1  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0  0 - grey

// 1 - color: green
// 2 - color: grey
// 3 - wifi.active: 0
// 4 - wifi.active: 1

// icon
//   green
//     color: green
//   grey
//     color: grey
//   yellow
//     color: yellow
//   wifi_active
//     wifi.active: 1
//   on init
//     grey
//   on wifi_active
//     green
//   on hover
//     yellow
//   on click
//     wifi_active

// after hover
// detect state
//   color: yellow  -> yellow
//   wifi.active: 1 -> wifi_active 
// detect rule
//   wifi_active -> on wifi_active ->  green

// panel
//   init
//     app_button

// icon.w: by_childs | fixed | parent
// icon.h: by_childs | fixed | parent

// [scalars]
// [args xywh functions]  // tree // dependens
// [checkers]


// icon
//   green
//     color green
//   grey
//     color grey
//   yellow
//     color yellow
//   wifi_active
//     wifi.active
//   on init
//     grey
//   on wifi_active
//     green
//   on hover
//     yellow
//   on click
//     wifi_active

