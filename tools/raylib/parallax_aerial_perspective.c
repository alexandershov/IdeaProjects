#include <raylib.h>
#include <rlgl.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>

// player, lampposts, trees, mountains1, mountains2, mountains3
#define NUM_LAYERS 6

#define NUM_LAMPPOSTS 10
#define NUM_TREES 8
#define NUM_LINES 100000
#define NUM_MOUNTAINS 40

#define MAX_L_SYSTEM_STACK_SIZE 100

typedef struct ColoredRectangle {
    Rectangle rectangle;
    Color color;
} ColoredRectangle;

typedef struct ColoredLine {
    Vector2 start;
    Vector2 end;
    float thick;
    Color color;
} ColoredLine;

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
    // if we'll have several layers moving with the different speed, then we'll have an illusion of depth
    // this is called parallax effect
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

    size_t numLines;
    ColoredLine *lines;
} Layer;

typedef struct LSystemInfo {
    Vector2 position;
    float angle;
} LSystemInfo;

// repl = "F[−F]F[+F][F]"
// repl.replace("F", repl).replace("F", repl).replace("F", repl)
char *L_SYSTEM = "F[-F]F[+F][F][-F[-F]F[+F][F]]F[-F]F[+F][F][+F[-F]F[+F][F]][F[-F]F[+F][F]][-F[-F]F[+F][F][-F[-F]F[+F][F]]F[-F]F[+F][F][+F[-F]F[+F][F]][F[-F]F[+F][F]]]F[-F]F[+F][F][-F[-F]F[+F][F]]F[-F]F[+F][F][+F[-F]F[+F][F]][F[-F]F[+F][F]][+F[-F]F[+F][F][-F[-F]F[+F][F]]F[-F]F[+F][F][+F[-F]F[+F][F]][F[-F]F[+F][F]]][F[-F]F[+F][F][-F[-F]F[+F][F]]F[-F]F[+F][F][+F[-F]F[+F][F]][F[-F]F[+F][F]]][-F[-F]F[+F][F][-F[-F]F[+F][F]]F[-F]F[+F][F][+F[-F]F[+F][F]][F[-F]F[+F][F]][-F[-F]F[+F][F][-F[-F]F[+F][F]]F[-F]F[+F][F][+F[-F]F[+F][F]][F[-F]F[+F][F]]]F[-F]F[+F][F][-F[-F]F[+F][F]]F[-F]F[+F][F][+F[-F]F[+F][F]][F[-F]F[+F][F]][+F[-F]F[+F][F][-F[-F]F[+F][F]]F[-F]F[+F][F][+F[-F]F[+F][F]][F[-F]F[+F][F]]][F[-F]F[+F][F][-F[-F]F[+F][F]]F[-F]F[+F][F][+F[-F]F[+F][F]][F[-F]F[+F][F]]]]F[-F]F[+F][F][-F[-F]F[+F][F]]F[-F]F[+F][F][+F[-F]F[+F][F]][F[-F]F[+F][F]][-F[-F]F[+F][F][-F[-F]F[+F][F]]F[-F]F[+F][F][+F[-F]F[+F][F]][F[-F]F[+F][F]]]F[-F]F[+F][F][-F[-F]F[+F][F]]F[-F]F[+F][F][+F[-F]F[+F][F]][F[-F]F[+F][F]][+F[-F]F[+F][F][-F[-F]F[+F][F]]F[-F]F[+F][F][+F[-F]F[+F][F]][F[-F]F[+F][F]]][F[-F]F[+F][F][-F[-F]F[+F][F]]F[-F]F[+F][F][+F[-F]F[+F][F]][F[-F]F[+F][F]]][+F[-F]F[+F][F][-F[-F]F[+F][F]]F[-F]F[+F][F][+F[-F]F[+F][F]][F[-F]F[+F][F]][-F[-F]F[+F][F][-F[-F]F[+F][F]]F[-F]F[+F][F][+F[-F]F[+F][F]][F[-F]F[+F][F]]]F[-F]F[+F][F][-F[-F]F[+F][F]]F[-F]F[+F][F][+F[-F]F[+F][F]][F[-F]F[+F][F]][+F[-F]F[+F][F][-F[-F]F[+F][F]]F[-F]F[+F][F][+F[-F]F[+F][F]][F[-F]F[+F][F]]][F[-F]F[+F][F][-F[-F]F[+F][F]]F[-F]F[+F][F][+F[-F]F[+F][F]][F[-F]F[+F][F]]]][F[-F]F[+F][F][-F[-F]F[+F][F]]F[-F]F[+F][F][+F[-F]F[+F][F]][F[-F]F[+F][F]][-F[-F]F[+F][F][-F[-F]F[+F][F]]F[-F]F[+F][F][+F[-F]F[+F][F]][F[-F]F[+F][F]]]F[-F]F[+F][F][-F[-F]F[+F][F]]F[-F]F[+F][F][+F[-F]F[+F][F]][F[-F]F[+F][F]][+F[-F]F[+F][F][-F[-F]F[+F][F]]F[-F]F[+F][F][+F[-F]F[+F][F]][F[-F]F[+F][F]]][F[-F]F[+F][F][-F[-F]F[+F][F]]F[-F]F[+F][F][+F[-F]F[+F][F]][F[-F]F[+F][F]]]]";

float rnd() {
    return (float)rand() / (float)RAND_MAX;
}

void fillMountains(ColoredTriangle triangles[NUM_MOUNTAINS], float height) {
    int xOffset = -500;
    for (int i = 0; i < NUM_MOUNTAINS; i++) {
        int width = 600 * (1 + rnd());
        int step = 50 * (1 + rnd());
        int base = 200;
        ColoredTriangle t = {
            // a is the most left point
            .a = (Vector2){xOffset + i * step, base},
            // b is the highest point
            .b = (Vector2){xOffset + i * step + width * (0.5 + (rnd() / 2.5) - 0.2), base - height * (1 + rnd() / 10.0)},
            // c is the most right point
            .c = (Vector2){xOffset + i * step + width, base},
            .color = BLUE,
        };
        triangles[i] = t;
    }
}

Vector2 pointAtAngle(Vector2 start, float radius, float angle) {
    return (Vector2){
        .x = start.x + radius * cosf(angle),
        .y = start.y + radius * sinf(angle),
    };
}

size_t fillTreeRec(ColoredLine *line, size_t maxLines, size_t i, Vector2 start, float length, float thick, float angle) {
    // this is fractal-like generation: tree is a trunk and two trees at angles
    // so every part of tree has the same characteristics as the larger
    // recursion is the natural way to implement fractals
    if (length < 2) {
        return 0;
    }
    if (i >= maxLines) {
        // no space for 1 new line
        return 0;
    }
    Vector2 myEnd = pointAtAngle(start, length, angle);
    ColoredLine curLine = {
        .start = start,
        .end = myEnd,
        .thick = thick,
        .color = BROWN,
    };
    line[i] = curLine;
    size_t leftSize = fillTreeRec(line, maxLines, i + 1, myEnd, length * (0.6 + rnd() / 5), thick * 0.8, angle - DEG2RAD * (30 + 10 * rnd()));
    size_t rightSize = fillTreeRec(line, maxLines, i + 1 + leftSize, myEnd, length * (0.6 + rnd() / 5), thick * 0.8, angle + DEG2RAD * (30 + 10 * rnd()));
    size_t result = leftSize + rightSize + 1;
    if (rnd() > 0.7) {
        size_t middleSize = fillTreeRec(line, maxLines, i + result, myEnd, length * (0.6 + rnd() / 5), thick * 0.8, angle - DEG2RAD * (8 + 10 * rnd()));
        result += middleSize;
    }
    return result;
}

size_t fillTree(ColoredLine *line, size_t maxLines, size_t i, Vector2 start, float length) {
    // generate a new tree at the given position
    // tree can consist out of maxLines but not more
    // it's expected that caller has allocated `maxLines` items starting at *line pointer

    // raylib y axis goes downwards, so initial angle is negative
    return fillTreeRec(line, maxLines, i, start, length, 10, -DEG2RAD * 90);
}

size_t fillTreeLSystem(ColoredLine *line, size_t maxLines, Vector2 start, char *lSystem) {
    // generate a new tree using L-System
    // L-System alphabet:
    // F move forward by length
    // [ save stack
    // ] pop stack
    // - rotate 30 degrees clockwise
    // + rotate 30 degrees counter-clockwise
    float rotation = DEG2RAD * 30;
    char *cur = lSystem;
    size_t numLines = 0;
    LSystemInfo stack[MAX_L_SYSTEM_STACK_SIZE];
    int stackPointer = -1;
    Vector2 position = start;
    float angle = DEG2RAD * (-90);
    float length = 10;
    while (*cur != '\0') {
        char c = *cur;
        switch (c) {
            case 'F': {
                line[numLines++] = (ColoredLine){
                    .start = position,
                    .end = pointAtAngle(position, length, angle),
                    .thick = 3,
                    .color = BROWN
                };
                position = pointAtAngle(position, length, angle);
                break;
            }
            case '[': {
                if (stackPointer == MAX_L_SYSTEM_STACK_SIZE - 1) {
                    printf("L_SYSTEM_STACK_SIZE overflow, stackPointer = %d\n", stackPointer);
                } else {
                    stackPointer++;
                    stack[stackPointer] = (LSystemInfo){.position = position, .angle = angle};
                }
                break;
            }
            case ']': {
                if (stackPointer < 0) {
                    printf("L_SYSTEM_STACK_SIZE underflow, stackPointer = %d\n", stackPointer);
                } else {
                    position = stack[stackPointer].position;
                    angle = stack[stackPointer].angle;
                    stackPointer--;
                }
                break;
            }
            case '-': {
                angle += rotation;
                break;
            }
            case '+': {
                angle -= rotation;
                break;
            }
        }
        cur++;
    }
    return numLines;
}

int main() {
    int screenWidth = 800;
    int screenHeight = 600;
    InitWindow(screenWidth, screenHeight, "parallax & aerial perspective");
    Shader shader = LoadShader(NULL, "aerial_perspective.fs");
    int atmosphereCoefLoc = GetShaderLocation(shader, "atmosphereCoef");
    int atmosphereLoc = GetShaderLocation(shader, "atmosphere");
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

    ColoredLine lines[NUM_LINES];
    size_t linesOffset = 0;
    for (int i = 0; i < NUM_TREES; i++) {
        Vector2 start = {400 * i, 290 + 30 * rnd()};
        if (rnd() < 0.5) {
            linesOffset += fillTree(lines, NUM_LINES, linesOffset, start, 80 * (1 + rnd() / 10));
        } else {
            linesOffset += fillTreeLSystem(lines + linesOffset, NUM_LINES, start, L_SYSTEM);
        }
    }

    // mountains1 is the closest layer, mountains3 is the furthest layer
    ColoredTriangle mountains1[NUM_MOUNTAINS];
    ColoredTriangle mountains2[NUM_MOUNTAINS];
    ColoredTriangle mountains3[NUM_MOUNTAINS];
    fillMountains(mountains1, 100);
    fillMountains(mountains2, 120);
    fillMountains(mountains3, 140);

    Layer layers[NUM_LAYERS] = {
        // player layer
        {
            .parallax = 1.0,
            .numRectangles = 1,
            .rectangles = &player,
            .numTriangles = 0,
            .numLines = 0,
            .atmosphereCoef = 0.0,
        },
        // lampposts layer
        {
          .parallax = 0.5,
          .numRectangles = NUM_LAMPPOSTS,
          .rectangles = lampposts,
          .numTriangles = 0,
          .numLines = 0,
          .atmosphereCoef = 0.0,
        },
        // trees layer
        {
          .parallax = 0.1,
          .numRectangles = 0,
          .numTriangles = 0,
          .numLines = linesOffset,
          .lines = lines,
          .atmosphereCoef = 0.0,
        },
        // mountain layers - don't participate in parallax; have aerial perspective
        {
          .parallax = 0.0,
          .numRectangles = 0,
          .numTriangles = NUM_MOUNTAINS,
          .numLines = 0,
          .atmosphereCoef = 0.5,
          .triangles = mountains1,
        },
        {
          .parallax = 0.0,
          .numRectangles = 0,
          .numTriangles = NUM_MOUNTAINS,
          .numLines = 0,
          .atmosphereCoef = 0.7,
          .triangles = mountains2,
        },
        {
          .parallax = 0.0,
          .numRectangles = 0,
          .numTriangles = NUM_MOUNTAINS,
          .numLines = 0,
          .atmosphereCoef = 0.9,
          .triangles = mountains3,
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
            for (int ln = 0; ln < layer.numLines; ln++) {
                layer.lines[ln].start.x += dx * dt * speed * layer.parallax;
                layer.lines[ln].end.x += dx * dt * speed * layer.parallax;
            }
        }

        // player can change its position, so we need to update camera target as well
        camera.target = (Vector2){player.rectangle.x, player.rectangle.y - 150};


        BeginDrawing();
        Vector4 atmosphereNormalized = {0.65, 0.78, 0.88, 1.0};
        ClearBackground(ColorFromNormalized(atmosphereNormalized));
        // setup camera
        BeginMode2D(camera);

        BeginShaderMode(shader);
        SetShaderValue(shader, atmosphereLoc, &atmosphereNormalized, SHADER_UNIFORM_VEC4);
        // Draw layers starting from the last, so earlier layers will be at the top
        for (int i = NUM_LAYERS - 1; i >= 0; i--) {
            Layer layer = layers[i];
            SetShaderValue(shader, atmosphereCoefLoc, &layer.atmosphereCoef, SHADER_UNIFORM_FLOAT);
            for (int r = 0; r < layer.numRectangles; r++) {
                DrawRectangleRec(layer.rectangles[r].rectangle, layer.rectangles[r].color);
            }
            for (int t = 0; t < layer.numTriangles; t++) {
                DrawTriangle(
                    // we need to pass vertexes in counter clockwise order to render triangle correctly
                    layer.triangles[t].a,
                    layer.triangles[t].c,
                    layer.triangles[t].b,
                    layer.triangles[t].color
                );
            }
            for (int ln = 0; ln < layer.numLines; ln++) {
                ColoredLine line = layer.lines[ln];
                DrawLineEx(line.start, line.end, line.thick, line.color);
            }
            // we need to draw current batch, otherwise raylib will batch all of our draw cals
            // with the same uniform value for the atmosphereCoef
            rlDrawRenderBatchActive();
        }
        EndShaderMode();

        EndMode2D();
        EndDrawing();
    }

    UnloadShader(shader);
    CloseWindow();
}