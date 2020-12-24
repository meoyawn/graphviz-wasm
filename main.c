#include "gvc.h"

#include "emscripten.h"

extern gvplugin_library_t gvplugin_core_LTX_library;
extern gvplugin_library_t gvplugin_dot_layout_LTX_library;

extern int Y_invert;
extern int Nop;

char *errorMessage = NULL;

int vizErrorf(char *buf)
{
  errorMessage = buf;
  return 0;
}

EMSCRIPTEN_KEEPALIVE
const char *lastErr()
{
  return errorMessage;
}

EMSCRIPTEN_KEEPALIVE
const char *layout(const char *src, const char *format, const char *engine, const int yInvert)
{
  errorMessage = NULL;
  char *result = NULL;
  GVC_t *context;
  Agraph_t *graph;
  unsigned int length;

  Y_invert = yInvert;

  context = gvContext();
  gvAddLibrary(context, &gvplugin_core_LTX_library);
  gvAddLibrary(context, &gvplugin_dot_layout_LTX_library);

  agseterr(AGERR);
  agseterrf(vizErrorf);

  agreadline(1);

  while ((graph = agmemread(src)))
  {
    if (result == NULL)
    {
      gvLayout(context, graph, engine);
      gvRenderData(context, graph, format, &result, &length);
      gvFreeLayout(context, graph);
    }

    agclose(graph);

    src = "";
  }

  return result;
}
