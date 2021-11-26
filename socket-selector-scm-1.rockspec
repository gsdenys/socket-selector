package = "socket-selector"
version = "scm-1"
source = {
   url = "*** please add URL for source tarball, zip or repository here ***"
}
description = {
   summary = "Select socket according the environment.",
   detailed = "Select socket according the environment. This socket can be NGX, CQueue or Lua socket",
   homepage = "*** please enter a project homepage ***",
   license = "*** please specify a license ***"
}
dependencies = {
   "lua >= 5.1",
   "power-table >= 1.0.1-1",
}
build = {
   type = "builtin",
   modules = {
      ['selector'] = "src/selector.lua",

      ['selector.ngx'] = "src/socket/ngx.lua",
      ['selector.cqueues'] = "src/socket/cqueues.lua",
      ['selector.lua'] = "src/socket/lua.lua",
      
      ['selector.env'] = "src/environment.lua"
   }
}
