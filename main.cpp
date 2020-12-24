#include <string>
#include "gvc.h"

#include "emscripten.h"

extern gvplugin_library_t gvplugin_core_LTX_library;
extern gvplugin_library_t gvplugin_dot_layout_LTX_library;

extern int Y_invert;
extern int Nop;

static std::string errorMessages;

int appendErr(char *buf)
{
  errorMessages.append(buf);
  return 0;
}

EMSCRIPTEN_KEEPALIVE
std::string lastErr()
{
  if (agreseterrors() == 0)
    return "";

  std::string str(errorMessages);
  errorMessages.clear();
  return str;
}

EMSCRIPTEN_KEEPALIVE
std::string layout(const std::string src, const std::string format, const std::string engine, const int yInvert)
{
  Y_invert = yInvert;

  auto *context = gvContext();
  gvAddLibrary(context, &gvplugin_core_LTX_library);
  gvAddLibrary(context, &gvplugin_dot_layout_LTX_library);

  agseterr(AGERR);
  agseterrf(appendErr);

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

// EMSCRIPTEN_BINDINGS(graphviz)
// {
//   emscripten::function("layout", &layout);
//   emscripten::function("error", &vizLastErrorMessage);
// }
