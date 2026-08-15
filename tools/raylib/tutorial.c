#include <raylib.h>
#include <stdio.h>

// player, lampposts, trees
#define NUM_LAYERS 3

#define NUM_LAMPPOSTS 3
#define NUM_TREES 5

typedef struct ColoredRectangle {
    Rectangle rectangle;
    Color color;
} ColoredRectangle;

typedef struct Layer {
    // 1.0 - layer moves with the speed of the player
    // 0.0 - layer doesn't move
    // otherwise value is interpolated
    float parallax;
    size_t numRectangles;
    ColoredRectangle *rectangles;
} Layer;

int main() {
    int screenWidth = 800;
    int screenHeight = 600;
    InitWindow(screenWidth, screenHeight, "raylib");
    Shader shader = LoadShader(NULL, "aerial_perspective.fs");
    float colorMulComponent = 1.0;
    Vector4 colorMul = {colorMulComponent, colorMulComponent, colorMulComponent, 1.0};
    int colorMulLoc = GetShaderLocation(shader, "colorMul");
    SetTargetFPS(60);

    ColoredRectangle player = {
      .rectangle = {300, 300, 20, 100},
      .color = BLUE,
    };
    Layer layers[NUM_LAYERS] = {
        // player layer
        {
            .parallax = 1.0,
            .numRectangles = 1,
            .rectangles = &player,
        },
    };
    // our setup is this:
    // player and game objects are in the world coordinates (these can be float)
    // camera looks at player and translates it into screen coordinates (these are integers)
    // y-axis in world coordinates has the same direction as in screen coordinates - downwards
    // x-axis is obviously pointing to the right
    Camera2D camera = {
        // offset is where we'll render on screen - here we render in the center of the screen
        .offset = (Vector2){screenWidth / 2.0, screenHeight / 2.0},
        // target is where the camera is looking at - here we're looking at the player
        .target = (Vector2){player.rectangle.x, player.rectangle.y},
        .rotation = 0.0,
        // zoom == 1.0 meaning something has size of 10 in world coordinates, then it'll be 10px on the screen
        .zoom = 1.0,
    };

    while (!WindowShouldClose()) {
        // time since the rendering of the last frame
        double dt = GetFrameTime();

        // 50 world coordinates per second == 50px per second, because zoom == 1.0
        double speed = 50.0;
        double dx = 0.0;

        // handle input: check if left/right are pressed during the current frame
        if (IsKeyDown(KEY_RIGHT)) {
            dx = 1.0;
        } else if (IsKeyDown(KEY_LEFT)) {
            dx = -1.0;
        }
        for (int i =0; i < NUM_LAYERS; i++) {
            Layer layer = layers[i];
            for (int r = 0; r < layer.numRectangles; r++) {
                layer.rectangles[r].rectangle.x += dx * dt * layer.parallax;
            }
        }

        // player can change its position, so we need to update camera target as well
        camera.target = (Vector2){player.rectangle.x, player.rectangle.y};


        BeginDrawing();
        ClearBackground(RAYWHITE);
        // setup camera
        BeginMode2D(camera);

        BeginShaderMode(shader);
        SetShaderValue(shader, colorMulLoc, &colorMul, SHADER_UNIFORM_VEC4);
        for (int i = 0; i < NUM_LAYERS; i++) {
            Layer layer = layers[i];
            for (int r = 0; r < layer.numRectangles; r++) {
                DrawRectangleRec(layer.rectangles[r].rectangle, layer.rectangles[r].color);
            }
        }
        EndShaderMode();

        EndMode2D();
        EndDrawing();
    }

    UnloadShader(shader);
    CloseWindow();
}