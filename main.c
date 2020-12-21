#include "emscripten.h"

#include "gvc.h"
#include "gvcint.h"

EMSCRIPTEN_KEEPALIVE
boolean version()
{
  GVC_t *ctx = gvContext();
  return ctx->config_found;
}
