# muse assets

Public UI dependencies and media for Muse. Main gameplay source, license keys,
enrollment credentials, and the Discord backend are not published here.

`ui/drawing.lua` adapts the drawing helper from
https://github.com/alex541-juju/juju/blob/main/customapi.lua.
Embedded font payloads were replaced with native Roblox fonts.

`ui/juju.lua` adapts the original Juju menu shell with native controls,
manual configs and visible-row gallery previews for Muse.
Juju sources and hit sounds originate from https://github.com/alex541-juju/juju.
Hosting these derivatives does not transfer original authorship or grant an
additional license. The upstream repository does not declare a code license.

`images/` contains the existing Muse intro and menu-logo artwork plus the
small UI pixel texture. `menusounds/` and `particles/` retain the media URLs
referenced by the original Muse source; `sounds/juju/` contains its Juju hit sounds.
Dependencies are pinned by commit in the private gameplay source.
