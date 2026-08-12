ifndef IMGUI_PATH
$(error set IMGUI_PATH equal to the checkout of https://github.com/ocornut/imgui/)
endif

run:
	c++ -std=c++11 -I"${IMGUI_PATH}" -I"${IMGUI_PATH}" -I/usr/local/include `sdl2-config --cflags` -Wall -Wformat -c "${IMGUI_PATH}/imgui.cpp" "${IMGUI_PATH}/imgui_demo.cpp" "${IMGUI_PATH}/imgui_draw.cpp" "${IMGUI_PATH}/imgui_tables.cpp" "${IMGUI_PATH}/imgui_widgets.cpp" "${IMGUI_PATH}/backends/imgui_impl_metal.mm" "${IMGUI_PATH}/backends/imgui_impl_sdl2.cpp"
	c++ -std=c++11 -I"${IMGUI_PATH}" -I"${IMGUI_PATH}/backends" -I /usr/local/include `sdl2-config --cflags` -Wall -Wformat -ObjC++ -fobjc-weak -fobjc-arc -c -o main.o main.mm
	c++ -o main main.o imgui.o imgui_demo.o imgui_draw.o imgui_tables.o imgui_widgets.o imgui_impl_sdl2.o imgui_impl_metal.o -std=c++11 -I"${IMGUI_PATH}" -I"${IMGUI_PATH}"/backends -I/usr/local/include `sdl2-config --cflags` -Wall -Wformat -framework Metal -framework MetalKit -framework Cocoa -framework IOKit -framework CoreVideo -framework QuartzCore `sdl2-config --libs` -L/usr/local/lib
	./main
