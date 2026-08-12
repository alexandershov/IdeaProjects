// based on https://github.com/ocornut/imgui/blob/master/examples/example_sdl2_metal/main.mm

#include "imgui.h"
#include "imgui_impl_sdl2.h"
#include "imgui_impl_metal.h"
#include <stdio.h>          // printf, fprintf
#include <SDL.h>

#import <Metal/Metal.h>
// QuartzCore is apple's library for rendering (mostly 2d stuff)
#import <QuartzCore/QuartzCore.h>

int main(int, char**)
{
    if (SDL_Init(SDL_INIT_VIDEO | SDL_INIT_TIMER | SDL_INIT_GAMECONTROLLER) != 0)
    {
        printf("Error: SDL_Init(): %s\n", SDL_GetError());
        return 1;
    }

    // From 2.0.18: Enable native IME.
#ifdef SDL_HINT_IME_SHOW_UI
    SDL_SetHint(SDL_HINT_IME_SHOW_UI, "1");
#endif

    // Create SDL window graphics context
    float main_scale = ImGui_ImplSDL2_GetContentScaleForDisplay(0);
    int window_flags = SDL_WINDOW_RESIZABLE | SDL_WINDOW_ALLOW_HIGHDPI;
    SDL_Window* window = SDL_CreateWindow("Dear ImGui SDL2+Metal example", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, (int)(1280 * main_scale), (int)(800 * main_scale), window_flags);
    if (window == nullptr)
    {
        printf("Error: SDL_CreateWindow(): %s\n", SDL_GetError());
        return 1;
    }

    // Create Metal device _before_ creating the view/layer
    id<MTLDevice> metalDevice = MTLCreateSystemDefaultDevice();
    if (!metalDevice)
    {
        printf("Error: failed to create Metal device.\n");
        SDL_DestroyWindow(window);
        SDL_Quit();
        return 1;
    }
    SDL_MetalView view = SDL_Metal_CreateView(window);
    CAMetalLayer* layer = (__bridge CAMetalLayer*)SDL_Metal_GetLayer(view);
    layer.device = metalDevice;
    layer.pixelFormat = MTLPixelFormatBGRA8Unorm;

    id<MTLCommandQueue> commandQueue = [layer.device newCommandQueue];
    MTLRenderPassDescriptor* renderPassDescriptor = [MTLRenderPassDescriptor new];

    // Setup Dear ImGui context
    IMGUI_CHECKVERSION();
    ImGui::CreateContext();
    ImGuiIO& io = ImGui::GetIO(); (void)io;
    io.ConfigFlags |= ImGuiConfigFlags_NavEnableKeyboard;     // Enable Keyboard Controls

    // Setup Dear ImGui style
    ImGui::StyleColorsLight();

    // Setup scaling
    ImGuiStyle& style = ImGui::GetStyle();
    style.ScaleAllSizes(main_scale);        // Bake a fixed style scale. (until we have a solution for dynamic style scaling, changing this requires resetting Style + calling this again)
    style.FontScaleDpi = main_scale;        // Set initial font scale. (in docking branch: using io.ConfigDpiScaleFonts=true automatically overrides this for every window depending on the current monitor)

    // Setup Platform/Renderer backends
    ImGui_ImplMetal_Init(layer.device);
    ImGui_ImplSDL2_InitForMetal(window);

    // Our state
    float float_value = 0.0;
    bool bool_value = false;
    float clear_color[4] = { 0.45f, 0.55f, 0.60f, 1.00f };

    // Main loop
    bool done = false;
    while (!done)
    {
        @autoreleasepool
        {
            SDL_Event event;
            while (SDL_PollEvent(&event))
            {
                ImGui_ImplSDL2_ProcessEvent(&event);
                if (event.type == SDL_QUIT)
                    done = true;
                if (event.type == SDL_WINDOWEVENT && event.window.event == SDL_WINDOWEVENT_CLOSE && event.window.windowID == SDL_GetWindowID(window))
                    done = true;
            }

            int width, height;
            SDL_GetWindowSizeInPixels(window, &width, &height);

	    // Metal stuff
            layer.drawableSize = CGSizeMake(width, height);
            id<CAMetalDrawable> drawable = [layer nextDrawable];

            id<MTLCommandBuffer> commandBuffer = [commandQueue commandBuffer];
            renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(clear_color[0] * clear_color[3], clear_color[1] * clear_color[3], clear_color[2] * clear_color[3], clear_color[3]);
            renderPassDescriptor.colorAttachments[0].texture = drawable.texture;
            renderPassDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
            renderPassDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
            id <MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
            [renderEncoder pushDebugGroup:@"ImGui demo"];

            // Start the Dear ImGui frame
            ImGui_ImplMetal_NewFrame(renderPassDescriptor);
            ImGui_ImplSDL2_NewFrame();
            ImGui::NewFrame();
	    // this is core functionality of ImGui, without Metal/SDL ceremonies
	    ImGui::SliderFloat("value", &float_value, -50.0, 50.0);
	    // ImGui::Text supports sprintf-style formatting
	    ImGui::Text("value = %f", float_value);
	    
	    // notice how if Button feels like magic: you directly manipulate float_value and it will get rendered the next frame
	    // in all widgets that use it
	    // so float_value is the source of truth.
	    // with retained mode UI you'd need to propagate float_value to all the widges somehow.
	    // note, that this means that we need to store our state outside of frame, which is kinda logical
	    // because our state lifetime is bigger than lifetime of a frame
	    // ImGui::Button will return true if button received click on this frame
	    if (ImGui::Button("Add"))
	      float_value++;
	    ImGui::Checkbox("show Sub", &bool_value);
	    if (bool_value)
		if (ImGui::Button("Sub"))
		  float_value--;
	    // ImGui::End();

            // Rendering
            ImGui::Render();
            ImDrawData* draw_data = ImGui::GetDrawData();
            ImGui_ImplMetal_RenderDrawData(draw_data, commandBuffer, renderEncoder);

            [renderEncoder popDebugGroup];
            [renderEncoder endEncoding];

            [commandBuffer presentDrawable:drawable];
            [commandBuffer commit];
        }
    }

    // Cleanup
    ImGui_ImplMetal_Shutdown();
    ImGui_ImplSDL2_Shutdown();
    ImGui::DestroyContext();

    SDL_DestroyWindow(window);
    SDL_Quit();

    return 0;
}
