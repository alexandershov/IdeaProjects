#include <box2d/box2d.h>
#include <raylib.h>

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
    groundBodyDef.position = (b2Vec2){50.0f, -9.0f};
    b2BodyId groundId = b2CreateBody(worldId, &groundBodyDef);

    double groundHalfWidth = 50.0;
    double groundHalfHeight = 10.0;
    // create geometry with half-width == 50 meters and half-height == 10 meters
    b2Polygon groundBox = b2MakeBox(groundHalfWidth, groundHalfHeight);
    b2ShapeDef groundShapeDef = b2DefaultShapeDef();
    b2CreatePolygonShape(groundId, &groundShapeDef, &groundBox);

    // create dynamic body
    b2BodyDef bodyDef = b2DefaultBodyDef();
    // dynamic body is a part of physics simulation
    bodyDef.type = b2_dynamicBody;
    bodyDef.position = (b2Vec2){10.0f, 10.0f};
    // rotation 0.5f radians
    bodyDef.rotation = b2MakeRot(0.5f);
    b2BodyId bodyId = b2CreateBody(worldId, &bodyDef);

    double boxHalfWidth = 2.0f;
    double boxHalfHeight = 1.0f;
    // now add shape to our dynamic body
    b2Polygon dynamicBox = b2MakeBox(boxHalfWidth, boxHalfHeight);
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

    // raylib window
    int RL_WIDTH = 800;
    int RL_HEIGHT = 600;
    InitWindow(RL_WIDTH, RL_HEIGHT, "raylib+box2D");

    SetTargetFPS(60);
    double toSimulate = 0.0;
    while (!WindowShouldClose()) {
        // GetFrameTime() is time since the last frame was drawn
        toSimulate += GetFrameTime();
        while (toSimulate > timeStep) {
            b2World_Step(worldId, timeStep, subStepCount);
            toSimulate -= timeStep;
        }
        b2Vec2 position = b2Body_GetPosition(bodyId);
        float rotationRad = b2Rot_GetAngle(b2Body_GetRotation(bodyId));

        BeginDrawing();
        ClearBackground(BLACK);

        // default raylib coordinate system is based on pixels
        // top-level corner is (0, 0), y axis goes down, x axis goes to the right
        int scale = 50;

        // render dynamic body
        Rectangle rectangle = {position.x * scale, RL_HEIGHT - position.y * scale, boxHalfWidth * scale * 2, boxHalfHeight * 2 * scale};
        DrawRectanglePro(rectangle, (Vector2){rectangle.width / 2.0, rectangle.height / 2.0}, -RAD2DEG * rotationRad, RED);

        // render ground
        Vector2 groundTopLeft = {(groundBodyDef.position.x - groundHalfWidth) * scale, RL_HEIGHT - (groundBodyDef.position.y + groundHalfHeight) * scale};
        DrawRectangle(groundTopLeft.x, groundTopLeft.y, groundHalfWidth * scale * 2, groundHalfHeight * 2 * scale, BLUE);
        EndDrawing();
    }

    // destroys everything that world contains
    b2DestroyWorld(worldId);
    printf("done!\n");
}