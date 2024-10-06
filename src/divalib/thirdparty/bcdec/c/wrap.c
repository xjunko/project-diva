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
  char* final_pixels = (char*)malloc(w * h * 4 * sizeof(unsigned char));

  if (final_pixels == NULL) {
    printf("[NATIVE] Failed to allocate memory for decoding ycbcr!\n");
    return NULL;
  }

  for (int y = 0; y < h; ++y) {
    for (int x = 0; x < w; ++x) {
      unsigned char Y = (unsigned char)luminance[(y * w + x) * 2];

      int chroma_x = x / 2;
      int chroma_y = y / 2;

      unsigned char Cb =
          (unsigned char)chroma[(chroma_y * (w / 2) + chroma_x) * 2];
      unsigned char Cr =
          (unsigned char)chroma[(chroma_y * (w / 2) + chroma_x) * 2 + 1];

      float R = Y + 1.402f * (Cr - 128);
      float G = Y - 0.344136f * (Cb - 128) - 0.714136f * (Cr - 128);
      float B = Y + 1.772f * (Cb - 128);

      final_pixels[(y * w + x) * 4 + 0] =
          (unsigned char)fminf(fmaxf(R, 0), 255);
      final_pixels[(y * w + x) * 4 + 1] =
          (unsigned char)fminf(fmaxf(G, 0), 255);
      final_pixels[(y * w + x) * 4 + 2] =
          (unsigned char)fminf(fmaxf(B, 0), 255);
      final_pixels[(y * w + x) * 4 + 3] =
          (unsigned char)luminance[(y * w + x) * 2 + 1];
    }
  }

  return final_pixels;
}

// Alternative shorter version but resizes the chroma
// char* jnko_decode_ycbcr(char* luminance, char* chroma, int w, int h,
//                         int channels, int chroma_channels) {
//   char* chroma_resized = (char*)malloc(w * h * chroma_channels);
//   char* final_pixels = (char*)malloc(w * h * 4 * sizeof(float));

//   stbir_resize_uint8_linear(chroma, w / 2, h / 2, 0, chroma_resized, w, h, 0,
//                             chroma_channels);

//   for (int i = 0; i < w * h; ++i) {
//     unsigned char Y = (unsigned char)luminance[i * 2];

//     unsigned char Cb = (unsigned char)chroma_resized[i * 2];
//     unsigned char Cr = (unsigned char)chroma_resized[i * 2 + 1];

//     float R = Y + 1.402f * (Cr - 128);
//     float G = Y - 0.344136f * (Cb - 128) - 0.714136f * (Cr - 128);
//     float B = Y + 1.772f * (Cb - 128);

//     final_pixels[i * 4 + 0] = (unsigned char)fminf(fmaxf(R, 0), 255);
//     final_pixels[i * 4 + 1] = (unsigned char)fminf(fmaxf(G, 0), 255);
//     final_pixels[i * 4 + 2] = (unsigned char)fminf(fmaxf(B, 0), 255);
//     final_pixels[i * 4 + 3] = (unsigned char)luminance[i * 2 + 1];
//   }

//   return final_pixels;
// }
