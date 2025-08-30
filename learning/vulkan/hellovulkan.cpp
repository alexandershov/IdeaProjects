#include <set>
#include <iostream>
#include <optional>
#include <cstdlib>

// with GLFW_INCLUDE_VULKAN glfw will include vulkan headers
#define GLFW_INCLUDE_VULKAN
#include <GLFW/glfw3.h>

// for VK_KHR_PORTABILITY_SUBSET_EXTENSION_NAME
#include <vulkan/vulkan_beta.h>


void checkedVk(VkResult result, const std::string& msg) {
    if (result != VK_SUCCESS) {
        std::cout << "got VkResult = " << result << "\n";
        std::cout << msg << "\n";
        std::exit(1);
    }
}

bool isDeviceSuitable(VkPhysicalDevice device) {
    // basic device properties, like name, type, and supported Vulkan version
    VkPhysicalDeviceProperties deviceProperties;
    vkGetPhysicalDeviceProperties(device, &deviceProperties);

    // more advanced features
    VkPhysicalDeviceFeatures deviceFeatures;
    vkGetPhysicalDeviceFeatures(device, &deviceFeatures);

    return true;
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

    // By default Vulkan do almost no error checking. You're getting VkResult, but that's about it.
    // To debug your application you can use validation layers
    // they allow you to hook your validation functions into Vulkan API
    // Vulkan SDK comes with the standard validation layer VK_LAYER_KHRONOS_validation
    std::vector<const char*> validationLayers = {
        "VK_LAYER_KHRONOS_validation"
    };

    bool enableValidationLayers = true;

    uint32_t layerCount;
    vkEnumerateInstanceLayerProperties(&layerCount, nullptr);

    std::vector<VkLayerProperties> availableLayers(layerCount);
    vkEnumerateInstanceLayerProperties(&layerCount, availableLayers.data());

    for (const char* layerName : validationLayers) {
        bool layerFound = false;

        for (const auto& layerProperties : availableLayers) {
            if (strcmp(layerName, layerProperties.layerName) == 0) {
                layerFound = true;
                break;
            }
        }
        if (!layerFound) {
            std::cout << "layer " << layerName << " not found" << "\n";
            exit(1);
        }
    }

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

    // VK_KHR_GET_PHYSICAL_DEVICE_PROPERTIES_2_EXTENSION_NAME is required to enable VK_KHR_PORTABILITY_SUBSET_EXTENSION_NAME
    requiredExtensions.emplace_back(VK_KHR_GET_PHYSICAL_DEVICE_PROPERTIES_2_EXTENSION_NAME);

    // the following will print:
    // requiredExtension = VK_KHR_surface
    // requiredExtension = VK_EXT_metal_surface
    // requiredExtension = VK_KHR_portability_enumeration
    // requiredExtension = VK_KHR_get_physical_device_properties2

    // VK_KHR_surface is an extension that allows Vulkan to render stuff on abstract surface
    for (const auto& extension: requiredExtensions) {
        std::cout << "requiredExtension = " << extension << "\n";
    }
    createInfo.flags |= VK_INSTANCE_CREATE_ENUMERATE_PORTABILITY_BIT_KHR;
    createInfo.enabledExtensionCount = (uint32_t) requiredExtensions.size();
    createInfo.ppEnabledExtensionNames = requiredExtensions.data();

    // add validation layer
    createInfo.enabledLayerCount = static_cast<uint32_t>(validationLayers.size());
    createInfo.ppEnabledLayerNames = validationLayers.data();

    // create Vulkan instance, which connects our application to the Vulkan library
    VkInstance instance;
    VkResult result = vkCreateInstance(&createInfo, /* custom allocator callbacks */ nullptr, &instance);
    checkedVk(result, "failed to create an instance");

    // Surface is used to render stuff
    VkSurfaceKHR surface;
    result = glfwCreateWindowSurface(instance, window, /* custom allocator */ nullptr, &surface);
    checkedVk(result, "can't create window surface");

    // query the number of physical devices (aka graphics cards) your system has
    // that's quite a popular pattern in Vulkan: first you query number of entities
    // and then you get the entities themselves
    uint32_t deviceCount = 0;
    vkEnumeratePhysicalDevices(instance, &deviceCount, nullptr);

    VkPhysicalDevice physicalDevice = VK_NULL_HANDLE;

    // hold all PhysicalDevices
    std::vector<VkPhysicalDevice> devices(deviceCount);
    vkEnumeratePhysicalDevices(instance, &deviceCount, devices.data());

    std::cout << "got " << deviceCount << " physical devices\n";

    if (deviceCount == 0) {
        std::cout << "no physical devices, exiting";
        exit(1);
   }

   for (const auto& device: devices) {
       if (isDeviceSuitable(device)) {
           physicalDevice = device;
           break;
       }
   }

   if (physicalDevice == VK_NULL_HANDLE) {
       std::cout << "no suitable physical device, exiting\n";
       exit(1);
   }

    // getting surface parameters
    VkSurfaceCapabilitiesKHR surfaceCapabilities;
    std::vector<VkSurfaceFormatKHR> surfaceFormats;
    std::vector<VkPresentModeKHR> surfacePresentModes;

    vkGetPhysicalDeviceSurfaceCapabilitiesKHR(physicalDevice, surface, &surfaceCapabilities);

    // familiar idiom: get count & array
    uint32_t surfaceFormatCount;
    vkGetPhysicalDeviceSurfaceFormatsKHR(physicalDevice, surface, &surfaceFormatCount, nullptr);

    if (surfaceFormatCount != 0) {
        surfaceFormats.resize(surfaceFormatCount);
        vkGetPhysicalDeviceSurfaceFormatsKHR(physicalDevice, surface, &surfaceFormatCount, surfaceFormats.data());
    }

    uint32_t surfacePresentModeCount;
    vkGetPhysicalDeviceSurfacePresentModesKHR(physicalDevice, surface, &surfacePresentModeCount, nullptr);

    if (surfacePresentModeCount != 0) {
        surfacePresentModes.resize(surfacePresentModeCount);
        vkGetPhysicalDeviceSurfacePresentModesKHR(physicalDevice, surface, &surfacePresentModeCount, surfacePresentModes.data());
    }

    if (surfaceFormats.empty() || surfacePresentModes.empty()) {
        std::cout << "no suitable surface, exiting\n";
        exit(1);
    }

    VkSurfaceFormatKHR surfaceFormat = surfaceFormats[0];
    for (const auto& availableFormat : surfaceFormats) {
        // 32 bit rgba
        if (availableFormat.format == VK_FORMAT_B8G8R8A8_SRGB && availableFormat.colorSpace == VK_COLOR_SPACE_SRGB_NONLINEAR_KHR) {
            surfaceFormat = availableFormat;
            std::cout << "chosen suitable surface format: VK_FORMAT_B8G8R8A8_SRGB!\n";
            break;
        }
    }

    // Every interaction with GPU goes through the queues
    // there are different types of queues for different types of interactions
    // Now we're checking that our device supports graphics commands queue
    uint32_t queueFamilyCount = 0;
    vkGetPhysicalDeviceQueueFamilyProperties(physicalDevice, &queueFamilyCount, nullptr);

    std::vector<VkQueueFamilyProperties> queueFamilies(queueFamilyCount);
    vkGetPhysicalDeviceQueueFamilyProperties(physicalDevice, &queueFamilyCount, queueFamilies.data());

    // picking the queue that support graphics
    std::optional<uint32_t> graphicsFamily;
    // picking the queue that supports presentation on a surface
    std::optional<uint32_t> presentFamily;
    uint32_t i = 0;
    for (const auto& queueFamily : queueFamilies) {
        if (queueFamily.queueFlags & VK_QUEUE_GRAPHICS_BIT) {
            graphicsFamily = i;
        }
        VkBool32 presentSupport = false;
        vkGetPhysicalDeviceSurfaceSupportKHR(physicalDevice, i, surface, &presentSupport);
        if (presentSupport) {
            presentFamily = i;
        }
        i++;
    }

    if (!graphicsFamily.has_value()) {
        std::cout << "no graphics queue found, exiting\n";
        exit(1);
    }

    if (!presentFamily.has_value()) {
            std::cout << "no present queue found, exiting\n";
            exit(1);
        }

    // Now we need create logical device to interact with the physical device
    // Logical device requires us to specify queues that it needs
    std::vector<VkDeviceQueueCreateInfo> queueCreateInfos;
    std::set<uint32_t> uniqueQueueFamilies = {graphicsFamily.value(), presentFamily.value()};

    float queuePriority = 1.0f;
    for (uint32_t queueFamily : uniqueQueueFamilies) {
        VkDeviceQueueCreateInfo queueCreateInfo{};
        queueCreateInfo.sType = VK_STRUCTURE_TYPE_DEVICE_QUEUE_CREATE_INFO;
        queueCreateInfo.queueFamilyIndex = queueFamily;
        queueCreateInfo.queueCount = 1;
        queueCreateInfo.pQueuePriorities = &queuePriority;
        queueCreateInfos.push_back(queueCreateInfo);
    }


    // now we need to specify set of device features we're using
    // we don't need any for now, so we'll use the default
    VkPhysicalDeviceFeatures deviceFeatures{};

    // now we can pass queue & features info to logical device create info
    VkDeviceCreateInfo deviceCreateInfo{};
    deviceCreateInfo.sType = VK_STRUCTURE_TYPE_DEVICE_CREATE_INFO;

    deviceCreateInfo.pQueueCreateInfos = queueCreateInfos.data();
    deviceCreateInfo.queueCreateInfoCount = queueCreateInfos.size();
    deviceCreateInfo.pEnabledFeatures = &deviceFeatures;

    // we need it on Mac
    std::vector<const char*> deviceProperties{
        VK_KHR_PORTABILITY_SUBSET_EXTENSION_NAME,
        // shortcut: we should check that this extension is available
        VK_KHR_SWAPCHAIN_EXTENSION_NAME,
    };
    deviceCreateInfo.enabledExtensionCount = deviceProperties.size();
    deviceCreateInfo.ppEnabledExtensionNames = deviceProperties.data();
    deviceCreateInfo.enabledLayerCount = static_cast<uint32_t>(validationLayers.size());
    deviceCreateInfo.ppEnabledLayerNames = validationLayers.data();

    VkDevice device;
    result = vkCreateDevice(physicalDevice, &deviceCreateInfo, nullptr, &device);
    checkedVk(result, "can't create logical device");

    std::cout << "created logical device\n";

    VkQueue graphicsQueue;
    // get graphics queue handle
    vkGetDeviceQueue(device, graphicsFamily.value(), 0, &graphicsQueue);

    VkQueue presentQueue;
    // get present queue handle
    vkGetDeviceQueue(device, presentFamily.value(), 0, &presentQueue);


    // main loop
    while (!glfwWindowShouldClose(window)) {
        glfwPollEvents();
    }

    // Start of destroying everything
    vkDestroyDevice(device, nullptr);

    vkDestroySurfaceKHR(instance, surface, nullptr);
    vkDestroyInstance(instance, nullptr);

    // deinit window
    glfwDestroyWindow(window);
    // deinit glfw
    glfwTerminate();

    std::cout << "done!\n";
}