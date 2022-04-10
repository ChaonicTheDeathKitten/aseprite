-- Color Shading v2.0
-- Aseprite Script that opens a dynamic palette picker window with relevant color shading options
-- Written by Dominick John, twitter @dominickjohn
-- Contributed to by David Capello
-- Expanded and changed by Chaonic
-- https://github.com/ChaonicTheDeathKitten/aseprite/

-- Instructions:
--    Place this file into the Aseprite scripts folder (File -> Scripts -> Open Scripts Folder)
--    Run the "Color Shading" script (File -> Scripts -> Color Shading) to open the palette window.

-- Commands:
--    Base: Clicking on either base color will switch the shading palette to that saved color base.
--    "Get" Button: Updates base colors using the current foreground and background color and regenerates shading.
--    Left click: Set clicked color as foreground color.
--    Right click: Set clicked color as background color.
--    Middle click: Set clicked color as foreground color and regenerate all shades based on this new color.

function lerp(first, second, by)
  return first * (1 - by) + second * by
end

function lerpRGBInt(color1, color2, amount)
  local X1 = 1 - amount
  local X2 = color1 >> 24 & 255
  local X3 = color1 >> 16 & 255
  local X4 = color1 >> 8 & 255
  local X5 = color1 & 255
  local X6 = color2 >> 24 & 255
  local X7 = color2 >> 16 & 255
  local X8 = color2 >> 8 & 255
  local X9 = color2 & 255
  local X10 = X2 * X1 + X6 * amount
  local X11 = X3 * X1 + X7 * amount
  local X12 = X4 * X1 + X8 * amount
  local X13 = X5 * X1 + X9 * amount
  return X10 << 24 | X11 << 16 | X12 << 8 | X13
end

function colorToInt(color)
  return (color.red << 16) + (color.green << 8) + (color.blue)
end

function colorShift(color, hueShift, satShift, lightShift, shadeShift)
  local newColor = Color(color) -- Make a copy of the color so we don't modify the parameter

  -- SHIFT HUE
  newColor.hslHue = (newColor.hslHue + hueShift * 360) % 360

  -- SHIFT SATURATION
  if (satShift > 0) then
    newColor.saturation = lerp(newColor.saturation, 1, satShift)
  elseif (satShift < 0) then
    newColor.saturation = lerp(newColor.saturation, 0, -satShift)
  end

  -- SHIFT LIGHTNESS
  if (lightShift > 0) then
    newColor.lightness = lerp(newColor.lightness, 1, lightShift)
  elseif (lightShift < 0) then
    newColor.lightness = lerp(newColor.lightness, 0, -lightShift)
  end

  -- SHIFT SHADING
  local newShade = Color {red = newColor.red, green = newColor.green, blue = newColor.blue}
  local shadeInt = 0
  if (shadeShift >= 0) then
    newShade.hue = 50
    shadeInt = lerpRGBInt(colorToInt(newColor), colorToInt(newShade), shadeShift)
  elseif (shadeShift < 0) then
    newShade.hue = 215
    shadeInt = lerpRGBInt(colorToInt(newColor), colorToInt(newShade), -shadeShift)
  end
  newColor.red = shadeInt >> 16
  newColor.green = shadeInt >> 8 & 255
  newColor.blue = shadeInt & 255

  return newColor
end

function showColors(shadingColor, fg, bg, windowBounds)
  local dlg
  dlg =
    Dialog {
    title = "Color Shading Ultra"
  }

  -- CACHING
  local FGcache = app.fgColor
  if(fg ~= nil) then
    FGcache = fg
  end

  local BGcache = app.bgColor
  if(bg ~= nil) then
    BGcache = bg
  end

  -- CURRENT CORE COLOR TO GENERATE SHADING
  local C = app.fgColor
  if(shadingColor ~= nil) then
    C = shadingColor
  end

  -- SHADING COLORS
  local SH1 = colorShift(C, 0, 0.4, -0.6, -0.6)
  local SH2 = colorShift(C, 0, 0.333, -0.5, -0.5)
  local SH3 = colorShift(C, 0, 0.266, -0.4, -0.4)
  local SH4 = colorShift(C, 0, 0.2, -0.3, -0.3)
  local SH5 = colorShift(C, 0, 0.133, -0.2, -0.2)
  local SH6 = colorShift(C, 0, 0.066, -0.1, -0.1)
  local SH8 = colorShift(C, 0, 0.066, 0.1, 0.1)
  local SH9 = colorShift(C, 0, 0.133, 0.2, 0.2)
  local SH10 = colorShift(C, 0, 0.2, 0.3, 0.3)
  local SH11 = colorShift(C, 0, 0.266, 0.4, 0.4)
  local SH12 = colorShift(C, 0, 0.333, 0.5, 0.5)
  local SH13 = colorShift(C, 0, 0.4, 0.6, 0.6)

  -- SHADING COLORS SOFTLY
  local SHF1 = colorShift(C, 0, 0.3, -0.45, -0.45)
  local SHF2 = colorShift(C, 0, 0.25, -0.375, -0.375)
  local SHF3 = colorShift(C, 0, 0.2, -0.3, -0.3)
  local SHF4 = colorShift(C, 0, 0.15, -0.225, -0.225)
  local SHF5 = colorShift(C, 0, 0.1, -0.15, -0.15)
  local SHF6 = colorShift(C, 0, 0.05, -0.075, -0.075)
  local SHF8 = colorShift(C, 0, 0.05, 0.075, 0.075)
  local SHF9 = colorShift(C, 0, 0.1, 0.15, 0.15)
  local SHF10 = colorShift(C, 0, 0.15, 0.225, 0.225)
  local SHF11 = colorShift(C, 0, 0.2, 0.3, 0.3)
  local SHF12 = colorShift(C, 0, 0.25, 0.375, 0.375)
  local SHF13 = colorShift(C, 0, 0.3, 0.45, 0.45)

  -- SKIN
  local SK1 = colorShift(C, 0, 0.3, -0.45, -0.3)
  local SK2 = colorShift(C, 0, 0.25, -0.375, -0.25)
  local SK3 = colorShift(C, 0, 0.2, -0.3, -0.2)
  local SK4 = colorShift(C, 0, 0.15, -0.225, -0.15)
  local SK5 = colorShift(C, 0, 0.1, -0.15, -0.1)
  local SK6 = colorShift(C, 0, 0.05, -0.075, -0.05)
  local SK8 = colorShift(C, 0, -0.025, 0.075, 0.025)
  local SK9 = colorShift(C, 0, 0.05, 0.15, 0.05)
  local SK10 = colorShift(C, 0, 0.075, 0.225, 0.075)
  local SK11 = colorShift(C, 0, 0.1, 0.3, 0.1)
  local SK12 = colorShift(C, 0, 0.125, 0.375, 0.125)
  local SK13 = colorShift(C, 0, 0.15, 0.45, 0.15)

  -- LIGHTNESS COLORS
  local LI1 = colorShift(C, 0, 0, -0.8571, 0)
  local LI2 = colorShift(C, 0, 0, -0.7142, 0)
  local LI3 = colorShift(C, 0, 0, -0.5714, 0)
  local LI4 = colorShift(C, 0, 0, -0.4285, 0)
  local LI5 = colorShift(C, 0, 0, -0.2857, 0)
  local LI6 = colorShift(C, 0, 0, -0.1428, 0)
  local LI8 = colorShift(C, 0, 0, 0.1428, 0)
  local LI9 = colorShift(C, 0, 0, 0.2857, 0)
  local LI10 = colorShift(C, 0, 0, 0.4285, 0)
  local LI11 = colorShift(C, 0, 0, 0.5714, 0)
  local LI12 = colorShift(C, 0, 0, 0.7142, 0)
  local LI13 = colorShift(C, 0, 0, 0.8571, 0)

  -- LIGHTNESS COLORS
  local LS1 = colorShift(C, 0, 0, -0.5, 0)
  local LS2 = colorShift(C, 0, 0, -0.4166, 0)
  local LS3 = colorShift(C, 0, 0, -0.3333, 0)
  local LS4 = colorShift(C, 0, 0, -0.25, 0)
  local LS5 = colorShift(C, 0, 0, -0.1666, 0)
  local LS6 = colorShift(C, 0, 0, -0.0833, 0)
  local LS8 = colorShift(C, 0, 0, 0.0833, 0)
  local LS9 = colorShift(C, 0, 0, 0.1666, 0)
  local LS10 = colorShift(C, 0, 0, 0.25, 0)
  local LS11 = colorShift(C, 0, 0, 0.3333, 0)
  local LS12 = colorShift(C, 0, 0, 0.4166, 0)
  local LS13 = colorShift(C, 0, 0, 0.5, 0)

  -- SATURATION COLORS
  local SA1 = colorShift(C, 0, -0.8571, 0, 0)
  local SA2 = colorShift(C, 0, -0.7142, 0, 0)
  local SA3 = colorShift(C, 0, -0.5714, 0, 0)
  local SA4 = colorShift(C, 0, -0.4285, 0, 0)
  local SA5 = colorShift(C, 0, -0.2857, 0, 0)
  local SA6 = colorShift(C, 0, -0.1428, 0, 0)
  local SA8 = colorShift(C, 0, 0.1428, 0, 0)
  local SA9 = colorShift(C, 0, 0.2857, 0, 0)
  local SA10 = colorShift(C, 0, 0.4285, 0, 0)
  local SA11 = colorShift(C, 0, 0.5714, 0, 0)
  local SA12 = colorShift(C, 0, 0.7142, 0, 0)
  local SA13 = colorShift(C, 0, 0.8571, 0, 0)

  -- SOFT HUE COLORS
  local SF1 = colorShift(C, -0.0833, 0, 0, 0)
  local SF2 = colorShift(C, -0.0694, 0, 0, 0)
  local SF3 = colorShift(C, -0.0555, 0, 0, 0)
  local SF4 = colorShift(C, -0.0416, 0, 0, 0)
  local SF5 = colorShift(C, -0.0277, 0, 0, 0)
  local SF6 = colorShift(C, -0.0138, 0, 0, 0)
  local SF8 = colorShift(C, 0.0138, 0, 0, 0)
  local SF9 = colorShift(C, 0.0277, 0, 0, 0)
  local SF10 = colorShift(C, 0.0416, 0, 0, 0)
  local SF11 = colorShift(C, 0.0555, 0, 0, 0)
  local SF12 = colorShift(C, 0.0694, 0, 0, 0)
  local SF13 = colorShift(C, 0.0833, 0, 0, 0)

  -- HARD HUE COLORS
  local HH1 = colorShift(C, 0.0833, 0, 0, 0)
  local HH2 = colorShift(C, 0.1666, 0, 0, 0)
  local HH3 = colorShift(C, 0.25, 0, 0, 0)
  local HH4 = colorShift(C, 0.3333, 0, 0, 0)
  local HH5 = colorShift(C, 0.4166, 0, 0, 0)
  local HH6 = colorShift(C, 0.50, 0, 0, 0)
  local HH7 = colorShift(C, 0.5833, 0, 0, 0)
  local HH8 = colorShift(C, 0.6666, 0, 0, 0)
  local HH9 = colorShift(C, 0.75, 0, 0, 0)
  local HH10 = colorShift(C, 0.8333, 0, 0, 0)
  local HH11 = colorShift(C, 0.9166, 0, 0, 0)

  -- DIALOGUE
  dlg:
  shades {
     -- SAVED COLOR BASES
    id = "baseu",
    label = "Base",
    colors = {FGcache, BGcache},
    onclick = function(ev)
      showColors(ev.color, FGcache, BGcache, dlg.bounds)
      dlg:close()
    end
  }:button {
    -- GET BUTTON
    id = "getu",
    text = "Get",
    onclick = function()
      showColors(app.fgColor, app.fgColor, app.bgColor, dlg.bounds)
      dlg:close()
    end
  }:shades {
     -- SHADING
    id = "shau",
    label = "Shade",
    colors = {SH1, SH2, SH3, SH4, SH5, SH6, C, SH8, SH9, SH10, SH11, SH12, SH13},
    onclick = function(ev)
      if(ev.button == MouseButton.LEFT) then
        app.fgColor = ev.color
      elseif(ev.button == MouseButton.RIGHT) then
        app.bgColor = ev.color
      elseif(ev.button == MouseButton.MIDDLE) then
        app.fgColor = ev.color
        showColors(ev.color, ev.color, BGcache, dlg.bounds)
        dlg:close()
      end
    end
  }:shades {
     -- SHADING SOFTLY
    id = "shasf",
    label = "Soft Shade",
    colors = {SHF1, SHF2, SHF3, SHF4, SHF5, SHF6, C, SHF8, SHF9, SHF10, SHF11, SHF12, SHF13},
    onclick = function(ev)
      if(ev.button == MouseButton.LEFT) then
        app.fgColor = ev.color
      elseif(ev.button == MouseButton.RIGHT) then
        app.bgColor = ev.color
      elseif(ev.button == MouseButton.MIDDLE) then
        app.fgColor = ev.color
        showColors(ev.color, ev.color, BGcache, dlg.bounds)
        dlg:close()
      end
    end
  }:shades {
     -- SKIN
    id = "skin",
    label = "Skin",
    colors = {SK1, SK2, SK3, SK4, SK5, SK6, C, SK8, SK9, SK10, SK11, SK12, SK13},
    onclick = function(ev)
      if(ev.button == MouseButton.LEFT) then
        app.fgColor = ev.color
      elseif(ev.button == MouseButton.RIGHT) then
        app.bgColor = ev.color
      elseif(ev.button == MouseButton.MIDDLE) then
        app.fgColor = ev.color
        showColors(ev.color, ev.color, BGcache, dlg.bounds)
        dlg:close()
      end
    end
  }:shades {
     -- LIGHTNESS
    id = "litu",
    label = "Light",
    colors = {LI1, LI2, LI3, LI4, LI5, LI6, C, LI8, LI9, LI10, LI11, LI12, LI13},
    onclick = function(ev)
      if(ev.button == MouseButton.LEFT) then
        app.fgColor = ev.color
      elseif(ev.button == MouseButton.RIGHT) then
        app.bgColor = ev.color
      elseif(ev.button == MouseButton.MIDDLE) then
        app.fgColor = ev.color
        showColors(ev.color, ev.color, BGcache, dlg.bounds)
        dlg:close()
      end
    end
  }:shades {
     -- SOFT LIGHTNESS
    id = "lits",
    label = "Soft Light",
    colors = {LS1, LS2, LS3, LS4, LS5, LS6, C, LS8, LS9, LS10, LS11, LS12, LS13},
    onclick = function(ev)
      if(ev.button == MouseButton.LEFT) then
        app.fgColor = ev.color
      elseif(ev.button == MouseButton.RIGHT) then
        app.bgColor = ev.color
      elseif(ev.button == MouseButton.MIDDLE) then
        app.fgColor = ev.color
        showColors(ev.color, ev.color, BGcache, dlg.bounds)
        dlg:close()
      end
    end
  }:shades {
     -- SATURATION
    id = "satu",
    label = "Sat",
    colors = {SA1, SA2, SA3, SA4, SA5, SA6, C, SA8, SA9, SA10, SA11, SA12, SA13},
    onclick = function(ev)
      if(ev.button == MouseButton.LEFT) then
        app.fgColor = ev.color
      elseif(ev.button == MouseButton.RIGHT) then
        app.bgColor = ev.color
      elseif(ev.button == MouseButton.MIDDLE) then
        app.fgColor = ev.color
        showColors(ev.color, ev.color, BGcache, dlg.bounds)
        dlg:close()
      end
    end
  }:shades {
     -- SOFT HUE
    id = "shueu",
    label = "Soft Hue",
    colors = {SF1, SF2, SF3, SF4, SF5, SF6, C, SF8, SF9, SF10, SF11, SF12, SF13},
    onclick = function(ev)
      if(ev.button == MouseButton.LEFT) then
        app.fgColor = ev.color
        --showColors(SCcache, FGcache, BGcache, dlg.bounds)
      elseif(ev.button == MouseButton.RIGHT) then
        app.bgColor = ev.color
        --showColors(SCcache, FGcache, BGcache, dlg.bounds)
      elseif(ev.button == MouseButton.MIDDLE) then
        app.fgColor = ev.color
        showColors(ev.color, ev.color, BGcache, dlg.bounds)
        dlg:close()
      end
    end
  }:shades {
     -- HARD HUE
    id = "hhueu",
    label = "Hard Hue",
    colors = {C, HH1, HH2, HH3, HH4, HH5, HH6, HH7, HH8, HH9, HH10, HH11, HH12},
    onclick = function(ev)
      if(ev.button == MouseButton.LEFT) then
        app.fgColor = ev.color
        --showColors(SCcache, FGcache, BGcache, dlg.bounds)
      elseif(ev.button == MouseButton.RIGHT) then
        app.bgColor = ev.color
        --showColors(SCcache, FGcache, BGcache, dlg.bounds)
      elseif(ev.button == MouseButton.MIDDLE) then
        app.fgColor = ev.color
        showColors(ev.color, ev.color, BGcache, dlg.bounds)
        dlg:close()
      end
    end
  }
  
  dlg:show {wait = false, bounds = windowBounds}
end

-- Run the script
do
  showColors(app.fgColor)
end
