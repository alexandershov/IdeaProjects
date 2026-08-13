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

    // create static body to represent the ground
    // by default b2DefaultBodyDef creates a static body (that's not part of physics simulation)
    b2BodyDef groundBodyDef = b2DefaultBodyDef();
    groundBodyDef.position = (b2Vec2){0.0f, -10.0f};
    b2BodyId groundId = b2CreateBody(worldId, &groundBodyDef);

    // create geometry with half-width == 50 meters and half-height == 10 meters
    b2Polygon groundBox = b2MakeBox(50.0f, 10.0f);
    b2ShapeDef groundShapeDef = b2DefaultShapeDef();
    b2CreatePolygonShape(groundId, &groundShapeDef, &groundBox);

    // create dynamic body
    b2BodyDef bodyDef = b2DefaultBodyDef();
    // dynamic body is a part of physics simulation
    bodyDef.type = b2_dynamicBody;
    bodyDef.position = (b2Vec2){0.0f, 4.0f};
    b2BodyId bodyId = b2CreateBody(worldId, &bodyDef);

    // now add shape to our dynamic body
    b2Polygon dynamicBox = b2MakeBox(1.0f, 1.0f);
    b2ShapeDef shapeDef = b2DefaultShapeDef();
    // setting some physics parameters
    shapeDef.density = 1.0f;
    shapeDef.material.friction = 0.3f;
    b2CreatePolygonShape(bodyId, &shapeDef, &dynamicBox);

    // that was it for initialization, not it's time to actually simulate physics
    // simulate physics 60 times a second with a fixed step
    float timeStep = 1.0f / 60.0f;

    // subStepCount=4 will split each 1/60th step into 4 steps
    // so we'll do 4x times more work, but we'll get more accurate results
    int subStepCount = 4;

    // simulate 1.5s of time (90 * 1/60)
    for (int i = 0; i < 90; i++) {
        b2World_Step(worldId, timeStep, subStepCount);
        b2Vec2 position = b2Body_GetPosition(bodyId);
        b2Rot rotation = b2Body_GetRotation(bodyId);
        printf("position = (%4.2f, %4.2f), rotation = %4.2f\n", position.x, position.y, b2Rot_GetAngle(rotation));
    }

    // destroys everything that world contains
    b2DestroyWorld(worldId);
    printf("done!\n");
}