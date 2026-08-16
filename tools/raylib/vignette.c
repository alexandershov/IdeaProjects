#include <raylib.h>
#include <stdio.h>

int main() {
    // screen aspect ratio matches vignette.jpeg aspect ratio
    int screenWidth = 904;
    int screenHeight = 600;
    InitWindow(screenWidth, screenHeight, "vignette");
    Shader shader = LoadShader(NULL, "vignette.fs");
    SetTargetFPS(60);

    Texture2D texture = LoadTexture("vignette.png");

    while (!WindowShouldClose()) {
        BeginDrawing();
        ClearBackground(RAYWHITE);
        BeginShaderMode(shader);

        Rectangle src = {
            0,
            0,
            (float)texture.width,
            (float)texture.height
        };
        Rectangle dst = {
            0,
            0,
            (float)GetScreenWidth(),
            (float)GetScreenHeight()
        };
        DrawTexturePro(
          texture, src, dst /* src, dst define mapping between texture & window */,
          (Vector2){0, 0} /* draw texture at (0, 0) */,
          0.0f /* rotation */,
          WHITE /* WHITE means - don't modify texture color */);

        EndShaderMode();
        EndDrawing();
    }

    UnloadTexture(texture);
    UnloadShader(shader);
    CloseWindow();
}