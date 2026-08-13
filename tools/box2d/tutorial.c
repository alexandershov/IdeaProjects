#include <box2d/box2d.h>

#include <stdio.h>

int main() {
    b2WorldDef worldDef = b2DefaultWorldDef();
    // positive y axis is up, gravity is down, as usual
    worldDef.gravity = (b2Vec2){0.0f, -10.0f};
    // b2*Id are opaque ids in box2D
    // the way you create box2D entities is:
    // you create a definition (*Def)
    // *Def() function contains some defaults
    // you can redefine them
    // and then you create box2D entity passing a pointer to the definition
    // box2D will copy definition, so it's okay to have definition on the stack
    b2WorldId worldId = b2CreateWorld(&worldDef);
    printf("done!\n");
}