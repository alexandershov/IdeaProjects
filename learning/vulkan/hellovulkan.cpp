#include <iostream>
#include <cstdlib>

// with GLFW_INCLUDE_VULKAN glfw will include vulkan headers
#define GLFW_INCLUDE_VULKAN
#include <GLFW/glfw3.h>


void checkedVk(VkResult result, const std::string& msg) {
    if (result != VK_SUCCESS) {
        std::cout << "got VkResult = " << result << "\n";
        std::cout << msg << "\n";
        std::exit(1);
    }
}

int main() {
    // init window
    glfwInit();
    glfwWindowHint(GLFW_CLIENT_API, /* don't create OpenGL context */ GLFW_NO_API);
    // not resizable window, so we don't need to deal with resize
    glfwWindowHint(GLFW_RESIZABLE, GLFW_FALSE);

    auto window = glfwCreateWindow(/* width */ 800, /* height */ 600, /* title */ "Hello Vulkan",
        /* monitor, like a display */ nullptr, /* OpenGL-specific */ nullptr);

    VkApplicationInfo appInfo{};
    // many Vulkan structure have sType member
    appInfo.sType = VK_STRUCTURE_TYPE_APPLICATION_INFO;
    appInfo.pApplicationName = "Hello Triangle";
    appInfo.applicationVersion = VK_MAKE_VERSION(1, 0, 0);
    appInfo.pEngineName = "No Engine";
    appInfo.engineVersion = VK_MAKE_VERSION(1, 0, 0);
    appInfo.apiVersion = VK_API_VERSION_1_0;

    // VkInstanceCreateInfo is used to tell which global extension & validation layers to use
    VkInstanceCreateInfo createInfo{};
    createInfo.sType = VK_STRUCTURE_TYPE_INSTANCE_CREATE_INFO;
    createInfo.pApplicationInfo = &appInfo;
    // we need an extension to interact with the window system
    uint32_t glfwExtensionCount = 0;
    const char** glfwExtensions;
    glfwExtensions = glfwGetRequiredInstanceExtensions(&glfwExtensionCount);

    // on MacOS MoltenVK requires VK_KHR_PORTABILITY_subset extension
    std::vector<const char*> requiredExtensions;

    for(uint32_t i = 0; i < glfwExtensionCount; i++) {
        requiredExtensions.emplace_back(glfwExtensions[i]);
    }
    requiredExtensions.emplace_back(VK_KHR_PORTABILITY_ENUMERATION_EXTENSION_NAME);
    createInfo.flags |= VK_INSTANCE_CREATE_ENUMERATE_PORTABILITY_BIT_KHR;
    createInfo.enabledExtensionCount = (uint32_t) requiredExtensions.size();
    createInfo.ppEnabledExtensionNames = requiredExtensions.data();
    // no validation layers for now
    createInfo.enabledLayerCount = 0;

    // create Vulkan instance, which connects our application to the Vulkan library
    VkInstance instance;
    VkResult result = vkCreateInstance(&createInfo, /* custom allocator callbacks */ nullptr, &instance);
    checkedVk(result, "failed to create an instance");

    // main loop
    while (!glfwWindowShouldClose(window)) {
        glfwPollEvents();
    }

    // deinit window
    glfwDestroyWindow(window);
    // deinit glfw
    glfwTerminate();

    std::cout << "done!\n";
}