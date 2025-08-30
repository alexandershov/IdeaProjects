run: export VK_ICD_FILENAMES = /Users/aershov/VulkanSDK/1.4.321.0/macOS/share/vulkan/icd.d/MoltenVK_icd.json
run: export VK_LAYER_PATH = /Users/aershov/VulkanSDK/1.4.321.0/macOS/share/vulkan/explicit_layer.d

run:
	clang++ --std=c++17 `pkg-config --cflags glfw3` `pkg-config --cflags glm` -I ~/VulkanSDK/1.4.321.0/macOS/include `pkg-config --libs glfw3` `pkg-config --libs glm` -L ~/VulkanSDK/1.4.321.0/macOS/lib/ -rpath ~/VulkanSDK/1.4.321.0/macOS/lib -lvulkan hellovulkan.cpp -o /tmp/vulkan
	/tmp/vulkan


compile-shaders:
	/Users/aershov/VulkanSDK/1.4.321.0/macOS/bin/glslc shaders/shader.vert -o shaders/vert.spv
	/Users/aershov/VulkanSDK/1.4.321.0/macOS/bin/glslc shaders/shader.frag -o shaders/frag.spv