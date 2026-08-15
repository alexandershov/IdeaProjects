#include <raylib.h>
#include <stdio.h>

int main() {
    InitWindow(800, 600, "raylib");
    SetTargetFPS(60);

    while (!WindowShouldClose()) {
        BeginDrawing();
        ClearBackground(BLACK);
        DrawRectangle(100, 100, 400, 300, RED);
        EndDrawing();
    }

    CloseWindow();
}