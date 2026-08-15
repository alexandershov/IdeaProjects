#include <raylib.h>
#include <stdio.h>

int main() {
    int screenWidth = 800;
    int screenHeight = 600;
    InitWindow(screenWidth, screenHeight, "raylib");
    Shader shader = LoadShader(NULL, "aerial_perspective.fs");
    float colorMulComponent = 0.6;
    Vector4 colorMul = {colorMulComponent, colorMulComponent, colorMulComponent, 1.0};
    int colorMulLoc = GetShaderLocation(shader, "colorMul");
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
        // time since the rendering of the last frame
        double dt = GetFrameTime();

        // 50 world coordinates per second == 50px per second, because zoom == 1.0
        double speed = 50.0;

        // handle input: check if left/right are pressed during the current frame
        if (IsKeyDown(KEY_RIGHT)) {
            player.x += speed * dt;
        } else if (IsKeyDown(KEY_LEFT)) {
            player.x -= speed * dt;
        }
        // player can change its position, so we need to update camera target as well
        camera.target = (Vector2){player.x, player.y};


        BeginDrawing();
        ClearBackground(RAYWHITE);
        // setup camera
        BeginMode2D(camera);

        BeginShaderMode(shader);
        SetShaderValue(shader, colorMulLoc, &colorMul, SHADER_UNIFORM_VEC4);
        DrawRectangleRec(player, BLUE);
        EndShaderMode();

        EndMode2D();
        EndDrawing();
    }

    UnloadShader(shader);
    CloseWindow();
}