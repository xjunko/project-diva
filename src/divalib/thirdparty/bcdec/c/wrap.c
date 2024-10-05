// no fuckin clue how to do this in v, so c it is

#include "bcdec.h"

#define MIN(a, b) (((a) < (b)) ? (a) : (b))
#define MAX(a, b) (((a) > (b)) ? (a) : (b))

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

char* jnko_decode_ycbcr(char* luminance, char* chroma, int w, int h,
                        int channels, int chroma_channels) {
  // chroma is always half the size of luminance, so resize it to match
  // luminance.
  char* chroma_resized = (char*)malloc(w * h * chroma_channels);
  char* final_pixels = (char*)malloc(w * h * 4);

  stbir_resize_uint8_linear(chroma, w / 2, h / 2, 0, chroma_resized, w, h, 0,
                            chroma_channels);

  // // copy chroma to final pixels
  // // 2 channels to 4 channels
  // for (int i = 0; i < w; i++) {
  //   for (int j = 0; j < h; j++) {
  //     final_pixels[(j * w + i) * 4] = chroma_resized[(j * w + i) * 2];
  //     final_pixels[(j * w + i) * 4 + 1] = chroma_resized[(j * w + i) * 2];
  //     final_pixels[(j * w + i) * 4 + 2] = chroma_resized[(j * w + i) * 2 +
  //     1]; final_pixels[(j * w + i) * 4 + 3] = 255;
  //   }
  // }

  for (int i = 0; i < w; i++) {
    for (int j = 0; j < h; j++) {
      float* chroma_pixel =
          (float*)(chroma_resized + (j * w + i) * chroma_channels);

      float luminance_r =
          ((char)(luminance[(j * w + i) * channels]) + 128.0f) / 255.0f;
      float chroma_r =
          ((char)(chroma_resized[(j * w + i) * 2]) + 128.0) / 255.0f;
      float chroma_g =
          ((char)(chroma_resized[(j * w + i) * 2 + 1]) + 128.0f) / 255.0f;

      // printf("%f %f %f \n", luminance_r, chroma_r, chroma_g);

      const float r =
          MIN(1.0f, MAX(0.0f, luminance_r + 1.5748f * chroma_g)) * 255.0f;
      const float g = MIN(1.0f, MAX(0.0f, luminance_r - 0.1873f * chroma_r -
                                              0.4681f * chroma_g)) *
                      255.0f;
      const float b =
          MIN(1.0f, MAX(0.0f, luminance_r + 1.8556f * chroma_r)) * 255.0f;
      const float a =
          MIN(1.0f, MAX(0.0f, ((char)(luminance[(j * w + i) * channels + 1]) +
                               255.0f) /
                                  255.0f)) *
          255.0f;

      final_pixels[(j * w + i) * 4 + 0] = r;
      final_pixels[(j * w + i) * 4 + 1] = g;
      final_pixels[(j * w + i) * 4 + 2] = b;
      final_pixels[(j * w + i) * 4 + 3] = a;
    }
  }

  return final_pixels;
}