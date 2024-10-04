// no fuckin clue how to do this in v, so c it is

#include "bcdec.h"

char* jnko_dxt1(char* src, int w, int h) {
  char* dst = (char*)malloc(w * h * 4);
  char* dst_ptr = dst;

  for (int i = 0; i < h; i += 4) {
    for (int j = 0; j < w; j += 4) {
      dst_ptr = dst + (i * w + j) * 4;
      bcdec_bc1(src, dst_ptr, w * 4);
      src += 8;
    }
  }

  return dst;
}

char* jnko_dxt3(char* src, int w, int h) {
  char* dst = (char*)malloc(w * h * 4);
  char* dst_ptr = dst;

  for (int i = 0; i < h; i += 4) {
    for (int j = 0; j < w; j += 4) {
      dst_ptr = dst + (i * w + j) * 4;
      bcdec_bc2(src, dst_ptr, w * 4);
      src += 16;
    }
  }

  return dst;
}

char* jnko_dxt5(char* src, int w, int h) {
  char* dst = (char*)malloc(w * h * 4);
  char* dst_ptr = dst;

  for (int i = 0; i < h; i += 4) {
    for (int j = 0; j < w; j += 4) {
      dst_ptr = dst + (i * w + j) * 4;
      bcdec_bc3(src, dst_ptr, w * 4);
      src += 16;
    }
  }

  return dst;
}

char* jnko_ati1(char* src, int w, int h) {
  char* dst = (char*)malloc(w * h);
  char* dst_ptr = dst;

  for (int i = 0; i < h; i += 4) {
    for (int j = 0; j < w; j += 4) {
      dst_ptr = dst + (i * w + j);
      bcdec_bc4(src, dst_ptr, w);
      src += 8;
    }
  }

  return dst;
}

char* jnko_ati2(char* src, int w, int h) {
  char* dst = (char*)malloc(w * h * 2);
  char* dst_ptr = dst;

  for (int i = 0; i < h; i += 4) {
    for (int j = 0; j < w; j += 4) {
      dst_ptr = dst + (i * w + j) * 2;
      bcdec_bc5(src, dst_ptr, w * 2);
      src += 16;
    }
  }

  return dst;
}