#include <raylib.h>
#include <stdio.h>
#include <stdlib.h>

// player, lampposts, trees
#define NUM_LAYERS 3

#define NUM_LAMPPOSTS 10
#define NUM_TREES 8

typedef struct ColoredRectangle {
    Rectangle rectangle;
    Color color;
} ColoredRectangle;

typedef struct ColoredTriangle {
    Vector2 a;
    Vector2 b;
    Vector2 c;
    Color color;
} ColoredTriangle;

typedef struct Layer {
    // 0.0 - layer doesn't move
    // 1.0 - layer moves with the speed of the player
    // otherwise value is interpolated
    float parallax;
    // https://en.wikipedia.org/wiki/Aerial_perspective
    // passed-through to the fragment shader, used to implement aerial perspective effect
    // when further objects have less contrast with the background
    // 0.0 - atmosphere is ignored
    // 1.0 - color is ignored
    // otherwise value is interpolated
    float atmosphereCoef;
    size_t numRectangles;
    ColoredRectangle *rectangles;

    size_t numTriangles;
    ColoredTriangle *triangles;
} Layer;

float rnd() {
    return (float)rand() / (float)RAND_MAX;
}

int main() {
    int screenWidth = 800;
    int screenHeight = 600;
    InitWindow(screenWidth, screenHeight, "raylib");
    Shader shader = LoadShader(NULL, "aerial_perspective.fs");
    int atmosphereCoefLoc = GetShaderLocation(shader, "atmosphereCoef");
    SetTargetFPS(60);

    ColoredRectangle player = {
      .rectangle = {300, 480, 20, 100},
      .color = BLUE,
    };

    ColoredRectangle lampposts[NUM_LAMPPOSTS];
    for (int i = 0; i < NUM_LAMPPOSTS; i++) {
        lampposts[i].rectangle = (Rectangle){100 * (i + rnd()), 300, 30, 200};
        lampposts[i].color = YELLOW;
    }

    ColoredRectangle trees[NUM_TREES];
        for (int i = 0; i < NUM_TREES; i++) {
            trees[i].rectangle = (Rectangle){100 * (i + rnd()), 100, 60, 300};
            trees[i].color = BROWN;
        }

    Layer layers[NUM_LAYERS] = {
        // player layer
        {
            .parallax = 1.0,
            .numRectangles = 1,
            .rectangles = &player,
            .numTriangles = 0,
            .atmosphereCoef = 0.0,
        },
        // lampposts layer
        {
          .parallax = 0.5,
          .numRectangles = NUM_LAMPPOSTS,
          .rectangles = lampposts,
          .numTriangles = 0,
          .atmosphereCoef = 0.0,
        },
        // trees layer
        {
          .parallax = 0.1,
          .numRectangles = NUM_TREES,
          .rectangles = trees,
          .numTriangles = 0,
          .atmosphereCoef = 0.0,
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
        double speed = 100.0;
        double dx = 0.0;

        // handle input: check if left/right are pressed during the current frame
        if (IsKeyDown(KEY_RIGHT)) {
            dx = 1.0;
        } else if (IsKeyDown(KEY_LEFT)) {
            dx = -1.0;
        }
        for (int i = 0; i < NUM_LAYERS; i++) {
            Layer layer = layers[i];
            for (int r = 0; r < layer.numRectangles; r++) {
                layer.rectangles[r].rectangle.x += dx * dt * speed * layer.parallax;
            }
        }

        // player can change its position, so we need to update camera target as well
        camera.target = (Vector2){player.rectangle.x, player.rectangle.y - 150};


        BeginDrawing();
        ClearBackground(RAYWHITE);
        // setup camera
        BeginMode2D(camera);

        BeginShaderMode(shader);
        // Draw layers starting from the last, so earlier layers will be at the top
        for (int i = NUM_LAYERS - 1; i >= 0; i--) {
            Layer layer = layers[i];
            SetShaderValue(shader, atmosphereCoefLoc, &layer.atmosphereCoef, SHADER_UNIFORM_FLOAT);
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