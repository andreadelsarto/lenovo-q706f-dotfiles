# 🎨 NebulaDeck — Theming & Customization Guide

Welcome to the **NebulaDeck** theming guide! This document explains how themes work in the launcher and how you can create custom visual themes, tailor-made tile geometries (such as *Manga Comic* tilted panels or *Wilderness Sunset* vertical poster cover-flows), animated background shaders, and color palettes.

---

## 🏛️ 1. Architecture Overview

**NebulaDeck** is built natively with **QtQuick / QML (Qt 6 & KDE Plasma 6)**. Unlike web/CSS-based launchers, QML executes directly on the GPU SceneGraph, allowing real-time 120 FPS sub-pixel transformations, shaders, rotations, and custom vector geometries.

The theming system is organized across three primary visual layers:

```
┌────────────────────────────────────────────────────────┐
│  1. Top Layer: Header & Quick Status Bar               │
│     (Clock, Wi-Fi, Real Battery, Live FPS & RAM Badge) │
├────────────────────────────────────────────────────────┤
│  2. Mid Layer: Hero Carousel & Application Grid        │
│     (Tile Geometries: Standard, Persona Tilt, Posters) │
├────────────────────────────────────────────────────────┤
│  3. Base Layer: Dynamic Background Engine              │
│     (Gradients, Canvas Shaders, Day/Night Cycles)      │
└────────────────────────────────────────────────────────┘
```

---

## 🎭 2. Anatomy of a Theme

Each theme in NebulaDeck defines:
1. **Identifier (`id`)**: Unique string key (e.g., `"manga_phantom"`, `"sunset_wilderness"`, `"dot_matrix_8bit"`, `"obsidian_minimal"`).
2. **Background Mode (`DynamicBackground.qml`)**: 
   - Static / Procedural Canvas (e.g. Retro 8-Bit Scanlines, Wilderness Sunset alpine ridge silhouettes).
   - Animated GPU Particles (e.g. Glass Bubbles, Rain Drops, Starfield Warp, Nordic Aurora, Lo-Fi Weather).
   - Circadian Clock Fade (Minute-by-minute organic daylight cycle).
3. **Tile Geometry & Framing (`HeroCarousel.qml` & `AppGrid.qml`)**:
   - Standard 16:9 rounded rectangles (`radius: 18`).
   - **Manga Comic Panel**: Angled tilt (`rotation: -3.5° / +2.8°`), jet-black outer matting, white inner ink stroke, and background black slash ribbon.
   - **Vertical Poster Cover-Flow**: Portrait cards (`180x260px`, `2:3 aspect ratio`), dimmed unselected cards (`opacity: 0.35`), glowing white border on active selection.
4. **Color Palette & Accent**:
   - `themeBgTop`, `themeBgMid`, `themeBgBottom` gradient stops.
   - Dynamic `accentColor` reacting immediately to user scrolling (220ms transition).

---

## 🛠️ 3. How to Create a New Theme (Step-by-Step)

### Step 1: Register your Theme in `i18n.js`
Open `contents/ui/i18n.js` and add your localized title and subtitle:
```javascript
"it": {
    "theme_mytheme": "Cyberpunk 2077",
    "theme_mytheme_desc": "Neon Glitch & Angled Cards",
    ...
},
"en": {
    "theme_mytheme": "Cyberpunk 2077",
    "theme_mytheme_desc": "Neon Glitch & Angled Cards",
    ...
}
```

---

### Step 2: Add Theme Option in `SettingsDrawer.qml`
Open `contents/ui/SettingsDrawer.qml` and insert your theme entry in the `themes` category model:
```qml
{ 
    id: "cyberpunk_2077", 
    icon: "games-config-theme", 
    nameKey: "theme_mytheme", 
    descKey: "theme_mytheme_desc", 
    color: "#fcee0a" 
}
```

---

### Step 3: Define Background Colors in `DynamicBackground.qml`
Open `contents/ui/DynamicBackground.qml` and add your top, mid, and bottom gradient colors:
```qml
readonly property color themeBgTop: {
    switch(root.bgStyle) {
        case "cyberpunk_2077": return "#1a0022";
        ...
    }
}

readonly property color themeBgMid: {
    switch(root.bgStyle) {
        case "cyberpunk_2077": return "#0d0014";
        ...
    }
}

readonly property color themeBgBottom: {
    switch(root.bgStyle) {
        case "cyberpunk_2077": return "#050008";
        ...
    }
}
```

---

### Step 4: Customize Tile Geometry & Proportions in `HeroCarousel.qml`
You can dynamically alter card width, rotation, border style, and aspect ratio:

```qml
readonly property bool isCyberpunk: (Plasmoid.configuration.currentTheme === "cyberpunk_2077")

// Dynamic dimensions
width: isCyberpunk ? 200 : 380
height: isCyberpunk ? 270 : 240

// Dynamic rotation / skew
rotation: isCyberpunk ? (isSelected ? -4.0 : 2.0) : 0.0

// Custom border & clipping
Rectangle {
    radius: isCyberpunk ? 0 : 18
    border.color: isCyberpunk ? (isSelected ? "#fcee0a" : "#00f0ff") : model.accentColor
    border.width: isCyberpunk ? 3 : 1
}
```

---

## 🎨 4. Built-in Theme Showcase

| Theme ID | Style / Inspiration | Visual Highlights |
| :--- | :--- | :--- |
| **`firewatch_poster`** | *Firewatch / Scenic Horizon* | Vertical 2:3 poster cover-flow, lookout tower sunset mountain silhouette canvas, dimmed inactive cards |
| **`persona_phantom`** | *Persona 5 / Manga Pop* | Angled comic rotation (-3.5°), jet-black outer matting, white inner ink stroke, background slash ribbon |
| **`circadian_daylight`**| *Living Ambient OS* | Dynamic morning teal ➔ midday azure ➔ sunset purple ➔ midnight obsidian fade (0% CPU) |
| **`obsidian_minimal`**  | *Pure OLED Dark Mode* | Pitch-black backgrounds (`#000000`), maximum battery conservation and stark white typography |
| **`synthwave_84`**      | *Outrun & Retro Wave* | Neon magenta/cyan glow, dark purple backdrop, retro electronic aesthetic |
| **`switch_deck`**       | *Nintendo Switch OLED*| Clean Joy-Con cyan/red accents with glassmorphic dark container cards |
| **`gameboy_classic`**   | *Nintendo GameBoy DMG* | Retro pea-soup green palette (`#8bac0f`) with authentic LCD scanline canvas overlay |
| **`bubbles`**           | *Steam Deck Glass UI* | Floating chromatic glass orbs with GPU alpha blending |
| **`aurora`**            | *Nordic Lights* | Ambient waving multi-color gradient lights |
| **`matrix_rain`**       | *Cyber Terminal* | Emerald green code stream with dark matrix backdrop |

---

## 🚀 5. Advanced: Writing Custom Shaders & Canvas Overlays

To add a custom procedural background canvas (such as stars, mountain silhouettes, geometric patterns, or scanlines) at **0% continuous CPU usage**, use QML's `Canvas` with `Canvas.FramebufferObject`:

```qml
Canvas {
    id: myCustomCanvas
    anchors.fill: parent
    visible: root.bgStyle === "my_theme"
    renderTarget: Canvas.FramebufferObject

    onPaint: {
        var ctx = getContext("2d");
        ctx.clearRect(0, 0, width, height);
        
        // Draw custom shapes or gradients once
        ctx.fillStyle = "#ff0055";
        ctx.beginPath();
        ctx.arc(width * 0.5, height * 0.5, 100, 0, 2 * Math.PI);
        ctx.fill();
    }
}
```

---

## 💡 Best Practices for Handheld Devices
1. **Always use sub-pixel text outline protection** (`style: Text.Outline; styleColor: "#050811"`) to guarantee 100% legibility over any custom background animations.
2. **Keep static overlays cached** via `Canvas.FramebufferObject` to avoid unnecessary redraws on battery.
3. **Test responsive touch scaling**: Ensure interactive card targets maintain a minimum of `44x44px` for touchscreens and gamepad navigation.
