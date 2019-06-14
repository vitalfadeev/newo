import parser : State, On, Quadro, Z;


struct Cursor {
    int x;
    int y;
}


struct Mouse {
    byte buttons; // mask: LEFT, CENTER, RIGHT
}


// checker
// mb
// 0
//
// Mouse
//   buttons

// Cursor
//   x
//   y

// Icon
//   hover
//     cursor.x > x
//     cursor.x < w
//
//   clicked
//     mouse.buttons LEFT

// reserved states
//   hover
//   clicked

void add() {
    // Z state quadro checkers
    // checkers
    //   hover
}
