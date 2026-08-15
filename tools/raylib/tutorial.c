#include <raylib.h>
#include <stdio.h>

int main() {
    int screenWidth = 800;
    int screenHeight = 600;
    InitWindow(screenWidth, screenHeight, "raylib");
    SetTargetFPS(60);

    Rectangle player = {300, 300, 20, 100};
    // our setup is this:
    // player and game objects are in the world coordinates (these can be float)
    // camera looks at player and translates it into screen coordinates (these are integers)
    // y-axis in world coordinates has the same direction as in screen coordinates - downwards
    // x-axis is obviously pointing to the right
    Camera2D camera = {
        // offset is where we'll render on screen - here we render in the center of the screen
        .offset = (Vector2){screenWidth / 2.0, screenHeight / 2.0},
        // target is where the camera is looking at - here we're looking at the player
        .target = (Vector2){player.x, player.y},
        .rotation = 0.0,
        // zoom == 1.0 meaning something has size of 10 in world coordinates, then it'll be 10px on the screen
        .zoom = 1.0,
    };

    while (!WindowShouldClose()) {
        BeginDrawing();
        ClearBackground(BLACK);
        // setup camera
        BeginMode2D(camera);

        DrawRectangleRec(player, BLUE);

        EndMode2D();
        EndDrawing();
    }

    CloseWindow();
}