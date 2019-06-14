import std.stdio;
import parser : parse, parse_and_update;


void main()
{
    string text = "
Star
  green
    x 0
    x 1
  grey
    x 0
    x 0
  hover
    cursor.x > x
    cursor.x < w
  on click
    green

Icon
  green
    x 1
    x 2
  grey
    x 3
    x 4
  yellow
    x 5
    x 6
    ";
    parse_and_update(text, 0);
}


// cursor.x > x
// cursor.x < w
//
// SELECT *
//   FROM storage
//  WHERE 
//        name = "cursor"
//    and x > arg.x
//    and x < arg.w

// phase 1
//   parse
//   get names
//
// phase 2
//   create objects
//
// phase 3
//   add checkers

// init
//   comparator
//   setter

// Icon
//   clicked
//     cursor
//       .x > x
//       .x < w
//     color green

