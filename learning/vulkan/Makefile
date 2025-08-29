run:
	clang++ `pkg-config --cflags glfw3` `pkg-config --cflags glm` -I ~/VulkanSDK/1.4.321.0/macOS/include `pkg-config --libs glfw3` `pkg-config --libs glm` -L ~/VulkanSDK/1.4.321.0/macOS/lib/ -rpath ~/VulkanSDK/1.4.321.0/macOS/lib -lvulkan hellovulkan.cpp -o /tmp/vulkan
	/tmp/vulkan