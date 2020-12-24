#include <string>

#include "emscripten.h"

#include "gvc.h"

extern gvplugin_library_t gvplugin_core_LTX_library;
extern gvplugin_library_t gvplugin_dot_layout_LTX_library;

extern int Y_invert;
extern int Nop;

static std::string errorMessages;

int vizErrorf(char *buf)
{
  errorMessages.append(buf);
  return 0;
}

EMSCRIPTEN_KEEPALIVE
std::string version(const std::string src, const std::string format, const std::string engine, const int yInvert)
{
  Y_invert = yInvert;

  auto *context = gvContext();
  gvAddLibrary(context, &gvplugin_core_LTX_library);
  gvAddLibrary(context, &gvplugin_dot_layout_LTX_library);

  agseterr(AGERR);
  agseterrf(vizErrorf);

  const auto *input = src.c_str();
  char *output = NULL;
  std::string result;
  unsigned int length;

  agreadline(1);

  Agraph_t *graph;
  while ((graph = agmemread(input)))
  {
    if (output == NULL)
    {
      gvLayout(context, graph, engine.c_str());
      gvRenderData(context, graph, format.c_str(), &output, &length);
      gvFreeLayout(context, graph);
    }

    agclose(graph);

    input = "";
  }

  result.assign(output, length);
  gvFreeRenderData(output);

  return result;
}
