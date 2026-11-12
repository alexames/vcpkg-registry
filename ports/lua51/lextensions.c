/*
** The calls past Lua 5.1 that LuaJIT 2.1 also provides, with the meaning
** Lua 5.2 gives them, so that code written against LuaJIT builds against
** this Lua 5.1 unchanged. The port's luajit-api feature builds this file and
** declares its calls in lua.h and lauxlib.h.
** See Copyright Notice in lua.h.
*/

#include <string.h>

#define lextensions_c
#define LUA_LIB

#include "lauxlib.h"
#include "lua.h"

LUA_API lua_Number lua_tonumberx(lua_State *L, int idx, int *isnum) {
  int converts = lua_isnumber(L, idx);
  if (isnum != NULL) *isnum = converts;
  return converts ? lua_tonumber(L, idx) : 0;
}

LUA_API lua_Integer lua_tointegerx(lua_State *L, int idx, int *isnum) {
  int converts = lua_isnumber(L, idx);
  if (isnum != NULL) *isnum = converts;
  return converts ? lua_tointeger(L, idx) : 0;
}

LUALIB_API void luaL_setfuncs(lua_State *L, const luaL_Reg *l, int nup) {
  luaL_checkstack(L, nup, "too many upvalues");
  for (; l->name != NULL; l++) {
    int i;
    for (i = 0; i < nup; i++) /* copy upvalues to the top */
      lua_pushvalue(L, -nup);
    lua_pushcclosure(L, l->func, nup);
    lua_setfield(L, -(nup + 2), l->name);
  }
  lua_pop(L, nup); /* remove upvalues */
}

LUALIB_API void *luaL_testudata(lua_State *L, int ud, const char *tname) {
  void *p = lua_touserdata(L, ud);
  if (p != NULL && lua_getmetatable(L, ud)) {
    lua_getfield(L, LUA_REGISTRYINDEX, tname);
    if (!lua_rawequal(L, -1, -2)) p = NULL;
    lua_pop(L, 2);
    return p;
  }
  return NULL;
}

LUALIB_API void luaL_setmetatable(lua_State *L, const char *tname) {
  luaL_getmetatable(L, tname);
  lua_setmetatable(L, -2);
}

/* As many frames from the top of a deep stack, and from its bottom, as
** debug.traceback keeps, with "..." between them. */
#define LEVELS1 12
#define LEVELS2 10

/* Formats each frame as debug.traceback does. */
LUALIB_API void luaL_traceback(lua_State *L, lua_State *L1, const char *msg,
                               int level) {
  lua_Debug ar;
  int top = lua_gettop(L);
  int first = level;
  int firstpart = 1;
  if (msg != NULL) lua_pushfstring(L, "%s\n", msg);
  lua_pushliteral(L, "stack traceback:");
  while (lua_getstack(L1, level, &ar)) {
    if (firstpart && level - first == LEVELS1) {
      firstpart = 0;
      if (lua_getstack(L1, level + LEVELS2, &ar)) {
        lua_pushliteral(L, "\n\t...");
        while (lua_getstack(L1, level + LEVELS2, &ar)) level++;
        continue;
      }
      lua_getstack(L1, level, &ar);
    }
    level++;
    lua_getinfo(L1, "Snl", &ar);
    lua_pushfstring(L, "\n\t%s:", ar.short_src);
    if (ar.currentline > 0) lua_pushfstring(L, "%d:", ar.currentline);
    if (*ar.namewhat != '\0')
      lua_pushfstring(L, " in function " LUA_QS, ar.name);
    else if (*ar.what == 'm')
      lua_pushliteral(L, " in main chunk");
    else if (*ar.what == 'C' || *ar.what == 't')
      lua_pushliteral(L, " ?");
    else
      lua_pushfstring(L, " in function <%s:%d>", ar.short_src, ar.linedefined);
    lua_concat(L, lua_gettop(L) - top);
  }
  lua_concat(L, lua_gettop(L) - top);
}

LUALIB_API int luaL_loadbufferx(lua_State *L, const char *buff, size_t sz,
                                const char *name, const char *mode) {
  if (mode != NULL) {
    const char *kind =
        (sz > 0 && buff[0] == LUA_SIGNATURE[0]) ? "binary" : "text";
    if (strchr(mode, kind[0]) == NULL) {
      lua_pushfstring(L, "attempt to load a %s chunk (mode is '%s')", kind,
                      mode);
      return LUA_ERRSYNTAX;
    }
  }
  return luaL_loadbuffer(L, buff, sz, name);
}
