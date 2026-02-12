#include <ctype.h>
#include <emscripten.h>
#include <stdio.h>
#include <unistd.h>
#include "doomgeneric.h"
#include "doomkeys.h"

#define TARGET_FPS 60

uint32_t start_time;
int frame_count = 0;

uint32_t get_time() {
  return EM_ASM_INT({
    return performance.now() | 0;
  });
}

void DG_SleepMs(uint32_t ms) {}

uint32_t DG_GetTicksMs() {
  return get_time() - start_time;
}

void DG_Init() {
  start_time = get_time();
}

int DG_GetKey(int* pressed, unsigned char* doomKey) {
  int key_data = EM_ASM_INT({
    if (key_queue.length === 0) 
      return 0;
    let key_data = key_queue.shift();
    let key = key_data[0];
    let pressed = key_data[1];
    return (pressed << 8) | key;
  });

  if (key_data == 0)
    return 0;
  
  *pressed = key_data >> 8;
  *doomKey = key_data & 0xFF;
  return 1;
}

void DG_SetWindowTitle(const char * title) {}

int key_to_doomkey(int key) {
  if (key == 37) //left arrow
    return KEY_LEFTARROW;
  if (key == 39) //right arrow
    return KEY_RIGHTARROW;
  if (key == 38 || key == 87) //up arrow, w
    return KEY_UPARROW;
  if (key == 40 || key == 83) //down arrow, s
    return KEY_DOWNARROW;
  if (key == 65) //a
    return KEY_STRAFE_L;
  if (key == 68) //d
    return KEY_STRAFE_R;
  if (key == 27)
    return KEY_ESCAPE;
  if (key == 13 || key == 90) //enter, z
    return KEY_ENTER;
  if (key == 69) //e
    return KEY_USE;
  if (key == 32) //space
    return KEY_FIRE;
  if (key == 9)
    return KEY_TAB;
  if (key == 16)
    return KEY_RSHIFT;
  return tolower(key);
}

void DG_DrawFrame() {
  int framebuffer_len = DOOMGENERIC_RESX * DOOMGENERIC_RESY * 4;
  EM_ASM({
    update_framebuffer($0, $1);
  }, DG_ScreenBuffer, framebuffer_len);
}

void doomjs_tick() {
  int start = get_time();
  doomgeneric_Tick();
  int end = get_time();
  if (end - start == 0)
    return;
  frame_count ++;

  if (frame_count % 300 == 0) {
    int fps = 1000 / (end - start);
    if (fps > TARGET_FPS)
      fps = TARGET_FPS;
    printf("frame time: %i ms (%i fps)\n", end - start, fps);
  }
}

int main(int argc, char **argv) {
  EM_ASM({
    create_framebuffer($0, $1);
  }, DOOMGENERIC_RESX, DOOMGENERIC_RESY);

  doomgeneric_Create(argc, argv);

  EM_ASM({
    setInterval(_doomjs_tick, 1000 / $0);
  }, TARGET_FPS);
  return 0;
}