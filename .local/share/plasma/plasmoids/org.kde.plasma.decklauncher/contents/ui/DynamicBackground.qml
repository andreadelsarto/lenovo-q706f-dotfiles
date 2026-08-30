import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid

Item {
    id: root
    anchors.fill: parent
    clip: true

    property color accentColor: "#38bdf8"
    property string bgStyle: Plasmoid.configuration.currentTheme || "obsidian_minimal"
    property bool isDashboardVisible: true
    property bool enableAnimatedFx: Plasmoid.configuration.enableAnimatedOrbs

    // Circadian Day-Night Clock Properties
    property int currentHour: 14
    property int currentMinute: 0

    Timer {
        interval: 60000
        running: root.isDashboardVisible
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            var d = new Date();
            root.currentHour = d.getHours();
            root.currentMinute = d.getMinutes();
        }
    }

    readonly property int colorAnimDuration: root.bgStyle === "circadian_daylight" ? 3000 : 220

    Behavior on accentColor { ColorAnimation { duration: root.colorAnimDuration; easing.type: Easing.OutQuad } }

    // Circadian daylight color calculations
    readonly property color circadianTop: {
        var h = root.currentHour;
        if (h >= 6 && h < 11) {
            return "#0e2a38"; // Dawn / Morning teal
        } else if (h >= 11 && h < 17) {
            return "#0a2540"; // Midday azure
        } else if (h >= 17 && h < 21) {
            return "#2c1033"; // Sunset twilight purple
        } else {
            return "#060914"; // Midnight obsidian
        }
    }

    readonly property color circadianMid: {
        var h = root.currentHour;
        if (h >= 6 && h < 11) {
            return "#13394a";
        } else if (h >= 11 && h < 17) {
            return "#143759";
        } else if (h >= 17 && h < 21) {
            return "#40183b";
        } else {
            return "#0b1122";
        }
    }

    readonly property color circadianBottom: {
        var h = root.currentHour;
        if (h >= 6 && h < 11) {
            return "#071720";
        } else if (h >= 11 && h < 17) {
            return "#061524";
        } else if (h >= 17 && h < 21) {
            return "#1a081c";
        } else {
            return "#020408";
        }
    }

    // Authentic Palette per Theme
    readonly property color themeBgTop: {
        switch(root.bgStyle) {
            case "weather_dynamic": return "#2e183b"; // Cozy Lo-Fi Twilight
            case "ocean_calm": return "#042f2e";
            case "sunset_wilderness":
            case "firewatch_poster": return "#f97316";
            case "manga_phantom":
            case "persona_phantom": return "#7a0404";
            case "circadian_daylight": return root.circadianTop;
            case "dot_matrix_8bit":
            case "gameboy_classic": return "#8fa42e";
            case "obsidian_minimal": return "#000000";
            case "synthwave_84": return "#180633";
            case "hybrid_console":
            case "switch_deck": return "#181d26";
            case "night_shift": return "#1c0f24";
            default: return Qt.tint("#0d1624", Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.40));
        }
    }

    readonly property color themeBgMid: {
        switch(root.bgStyle) {
            case "weather_dynamic": return "#1a0f26"; // Warm Mauve
            case "ocean_calm": return "#0f172a";
            case "sunset_wilderness":
            case "firewatch_poster": return "#991b1b";
            case "manga_phantom":
            case "persona_phantom": return "#380202";
            case "circadian_daylight": return root.circadianMid;
            case "dot_matrix_8bit":
            case "gameboy_classic": return "#798d24";
            case "obsidian_minimal": return "#05070a";
            case "synthwave_84": return "#0d031c";
            case "hybrid_console":
            case "switch_deck": return "#10141a";
            case "night_shift": return "#0f0714";
            default: return Qt.tint("#080c14", Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.18));
        }
    }

    readonly property color themeBgBottom: {
        switch(root.bgStyle) {
            case "weather_dynamic": return "#0c0614"; // Deep Lo-Fi Midnight
            case "ocean_calm": return "#020617";
            case "sunset_wilderness":
            case "firewatch_poster": return "#180816";
            case "manga_phantom":
            case "persona_phantom": return "#0f0101";
            case "circadian_daylight": return root.circadianBottom;
            case "dot_matrix_8bit":
            case "gameboy_classic": return "#5b6d19";
            case "obsidian_minimal": return "#000000";
            case "synthwave_84": return "#070210";
            case "hybrid_console":
            case "switch_deck": return "#0a0c10";
            case "night_shift": return "#08040a";
            default: return "#04060a";
        }
    }

    // Base Theme Canvas with Smooth Color Fade Transition
    Rectangle {
        anchors.fill: parent
        color: root.themeBgBottom

        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop {
                position: 0.0
                color: root.themeBgTop
                Behavior on color { ColorAnimation { duration: root.colorAnimDuration; easing.type: Easing.OutQuad } }
            }
            GradientStop {
                position: 0.48
                color: root.themeBgMid
                Behavior on color { ColorAnimation { duration: root.colorAnimDuration; easing.type: Easing.OutQuad } }
            }
            GradientStop {
                position: 1.0
                color: root.themeBgBottom
                Behavior on color { ColorAnimation { duration: root.colorAnimDuration; easing.type: Easing.OutQuad } }
            }
        }
    }

    // =========================================================================
    // WILDERNESS SUNSET ALPINE RIDGES & OVERLOOK (Zero CPU Static Canvas)
    // =========================================================================
    Canvas {
        id: wildernessCanvas
        anchors.fill: parent
        visible: root.bgStyle === "sunset_wilderness" || root.bgStyle === "firewatch_poster"
        renderTarget: Canvas.FramebufferObject

        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()

        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);

            var w = width;
            var h = height;

            // Warm Glowing Sun Disc on Horizon
            var sunGrad = ctx.createRadialGradient(w * 0.50, h * 0.30, 10, w * 0.50, h * 0.30, 140);
            sunGrad.addColorStop(0.0, "rgba(254, 215, 170, 0.45)");
            sunGrad.addColorStop(0.5, "rgba(249, 115, 22, 0.20)");
            sunGrad.addColorStop(1.0, "transparent");
            ctx.fillStyle = sunGrad;
            ctx.beginPath();
            ctx.arc(w * 0.50, h * 0.30, 140, 0, Math.PI * 2);
            ctx.fill();

            // Layer 1: Distant Alpine Mountain Peaks (Soft Peach / Amber)
            ctx.fillStyle = "rgba(190, 60, 35, 0.48)";
            ctx.beginPath();
            ctx.moveTo(0, h * 0.48);
            ctx.lineTo(w * 0.20, h * 0.34);
            ctx.lineTo(w * 0.50, h * 0.20); // Center High Peak
            ctx.lineTo(w * 0.78, h * 0.36);
            ctx.lineTo(w, h * 0.44);
            ctx.lineTo(w, h);
            ctx.lineTo(0, h);
            ctx.closePath();
            ctx.fill();

            // Layer 2: Mid-Range Jagged Pine Ridges (Deep Crimson / Burgundy)
            ctx.fillStyle = "rgba(125, 22, 28, 0.70)";
            ctx.beginPath();
            ctx.moveTo(0, h * 0.50);
            ctx.lineTo(w * 0.16, h * 0.44);
            ctx.lineTo(w * 0.38, h * 0.38);
            ctx.lineTo(w * 0.62, h * 0.46);
            ctx.lineTo(w * 0.85, h * 0.40);
            ctx.lineTo(w, h * 0.52);
            ctx.lineTo(w, h);
            ctx.lineTo(0, h);
            ctx.closePath();
            ctx.fill();

            // Serene Alpine Overlook Cabin on Center Ridge
            ctx.fillStyle = "#2d0814";
            var twX = w * 0.50;
            var twY = h * 0.20;
            ctx.fillRect(twX - 14, twY - 24, 28, 16); // Cabin
            ctx.fillRect(twX - 17, twY - 26, 34, 4);  // Overhang Roof
            ctx.fillRect(twX - 9, twY - 8, 4, 32);    // Pillar 1
            ctx.fillRect(twX + 5, twY - 8, 4, 32);    // Pillar 2
            ctx.fillRect(twX - 10, twY + 6, 20, 3);   // Railing

            // Layer 3: Foreground Pine Forest Canopy (Midnight Plum / Obsidian)
            ctx.fillStyle = "#150614";
            ctx.beginPath();
            ctx.moveTo(0, h * 0.60);
            for (var px = 0; px <= w; px += 24) {
                var py = h * 0.54 + Math.sin(px * 0.04) * 12 + ((px % 48 === 0) ? -14 : 0);
                ctx.lineTo(px, py);
            }
            ctx.lineTo(w, h);
            ctx.lineTo(0, h);
            ctx.closePath();
            ctx.fill();
        }
    }

    // =========================================================================
    // RETRO 8-BIT DOT-MATRIX LCD SCANLINES (Zero CPU Static Canvas)
    // =========================================================================
    Canvas {
        id: gbLcdCanvas
        anchors.fill: parent
        visible: root.bgStyle === "dot_matrix_8bit" || root.bgStyle === "gameboy_classic"
        renderTarget: Canvas.FramebufferObject

        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()

        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);

            ctx.fillStyle = "rgba(15, 56, 15, 0.12)";
            for (var y = 0; y < height; y += 4) {
                ctx.fillRect(0, y, width, 1.2);
            }
        }
    }

    // =========================================================================
    // HIGH PERFORMANCE LAZY LOADER: Only active when enableAnimatedFx is true!
    // =========================================================================
    Loader {
        id: themeLoader
        anchors.fill: parent
        active: root.isDashboardVisible && root.enableAnimatedFx
        sourceComponent: {
            if (!root.enableAnimatedFx) return null;
            switch(root.bgStyle) {
                case "ocean_calm": return oceanComponent;
                case "weather_dynamic": return weatherComponent;
                case "drops": return dropsComponent;
                case "starfield": return starfieldComponent;
                case "aurora": return auroraComponent;
                case "matrix_rain": return matrixComponent;
                case "bubbles": return bubblesComponent;
                default: return null; // Static / Circadian (0 CPU)
            }
        }
    }

    // --- 0. DYNAMIC LO-FI CHILL & CUTE WEATHER (Pastel Rain, Ghibli Fireflies & Star Sparkles) ---
    Component {
        id: weatherComponent
        Item {
            id: weatherItem
            anchors.fill: parent

            // Cozy Lo-Fi Pastel Moon / Sun Orb
            Rectangle {
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.topMargin: -40
                anchors.rightMargin: -40
                width: 280
                height: 280
                radius: 140
                opacity: 0.35
                gradient: Gradient {
                    orientation: Gradient.Vertical
                    GradientStop { position: 0.0; color: Qt.rgba(0.99, 0.82, 0.88, 0.45) } // Soft pastel pink
                    GradientStop { position: 0.5; color: Qt.rgba(0.99, 0.90, 0.54, 0.20) } // Warm pastel peach
                    GradientStop { position: 1.0; color: "transparent" }
                }

                SequentialAnimation on scale {
                    loops: Animation.Infinite
                    running: root.isDashboardVisible && root.enableAnimatedFx
                    NumberAnimation { from: 1.0; to: 1.08; duration: 6000; easing.type: Easing.InOutSine }
                    NumberAnimation { from: 1.08; to: 1.0; duration: 6000; easing.type: Easing.InOutSine }
                }
            }

            // High Efficiency Cute Lo-Fi Particle Canvas (< 1% CPU)
            Canvas {
                id: weatherCanvas
                anchors.fill: parent
                renderTarget: Canvas.FramebufferObject

                property var particles: []

                Component.onCompleted: {
                    var p = [];
                    // 16 Cute Rounded Pastel Raindrops
                    for (var r = 0; r < 16; r++) {
                        p.push({
                            type: "rain",
                            x: Math.random() * 1280,
                            y: Math.random() * 800,
                            speed: 6.5 + Math.random() * 4.5,
                            len: 16 + Math.random() * 10,
                            alpha: 0.35 + Math.random() * 0.35
                        });
                    }
                    // 12 Glowing Lo-Fi Fireflies (Floating gently with pulsating halos)
                    for (var f = 0; f < 12; f++) {
                        p.push({
                            type: "firefly",
                            x: Math.random() * 1280,
                            y: 100 + Math.random() * 650,
                            speedX: -0.4 + Math.random() * 0.8,
                            speedY: -0.3 + Math.random() * 0.6,
                            size: 3.5 + Math.random() * 3.0,
                            pulse: Math.random() * Math.PI * 2,
                            isPeach: (f % 2 === 0),
                            alpha: 0.4 + Math.random() * 0.5
                        });
                    }
                    // 8 Cute 4-Point Anime Sparkle Stars (✦)
                    for (var s = 0; s < 8; s++) {
                        p.push({
                            type: "sparkle",
                            x: Math.random() * 1280,
                            y: 50 + Math.random() * 400,
                            size: 4 + Math.random() * 4,
                            phase: Math.random() * Math.PI * 2,
                            alpha: 0.3 + Math.random() * 0.5
                        });
                    }
                    particles = p;
                }

                Timer {
                    interval: 33 // 30 FPS smooth relaxing progression
                    running: root.isDashboardVisible && root.enableAnimatedFx
                    repeat: true
                    onTriggered: {
                        if (!weatherCanvas.particles) return;
                        var w = weatherCanvas.width || 1280;
                        var h = weatherCanvas.height || 800;
                        for (var i = 0; i < weatherCanvas.particles.length; i++) {
                            var pt = weatherCanvas.particles[i];
                            if (pt.type === "rain") {
                                pt.y += pt.speed;
                                pt.x += pt.speed * 0.20;
                                if (pt.y > h + 30 || pt.x > w + 30) {
                                    pt.y = -pt.len;
                                    pt.x = Math.random() * w;
                                }
                            } else if (pt.type === "firefly") {
                                pt.x += pt.speedX;
                                pt.y += pt.speedY;
                                pt.pulse += 0.04;
                                if (pt.x < -20) pt.x = w + 20;
                                else if (pt.x > w + 20) pt.x = -20;
                                if (pt.y < 50) pt.y = h - 50;
                                else if (pt.y > h - 50) pt.y = 50;
                            } else if (pt.type === "sparkle") {
                                pt.phase += 0.035;
                            }
                        }
                        weatherCanvas.requestPaint();
                    }
                }

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.clearRect(0, 0, width, height);

                    if (!particles) return;

                    ctx.lineCap = "round";

                    for (var i = 0; i < particles.length; i++) {
                        var pt = particles[i];

                        if (pt.type === "rain") {
                            // Soft pastel cute raindrop
                            ctx.lineWidth = 2.0;
                            ctx.strokeStyle = "rgba(199, 210, 254, " + pt.alpha + ")";
                            ctx.beginPath();
                            ctx.moveTo(pt.x, pt.y);
                            ctx.lineTo(pt.x + pt.len * 0.20, pt.y + pt.len);
                            ctx.stroke();
                        } else if (pt.type === "firefly") {
                            // Glowing warm firefly orb with soft halo
                            var glowAlpha = pt.alpha * (0.5 + 0.5 * Math.sin(pt.pulse));
                            
                            // Outer Halo
                            ctx.fillStyle = pt.isPeach ? ("rgba(253, 186, 116, " + (glowAlpha * 0.35) + ")") : ("rgba(254, 240, 138, " + (glowAlpha * 0.35) + ")");
                            ctx.beginPath();
                            ctx.arc(pt.x, pt.y, pt.size * 2.2, 0, Math.PI * 2);
                            ctx.fill();

                            // Inner Core
                            ctx.fillStyle = pt.isPeach ? ("rgba(255, 237, 213, " + glowAlpha + ")") : ("rgba(255, 255, 255, " + glowAlpha + ")");
                            ctx.beginPath();
                            ctx.arc(pt.x, pt.y, pt.size * 0.8, 0, Math.PI * 2);
                            ctx.fill();
                        } else if (pt.type === "sparkle") {
                            // Cute 4-point twinkling star sparkle (✦)
                            var spAlpha = pt.alpha * (0.4 + 0.6 * Math.sin(pt.phase));
                            if (spAlpha > 0.1) {
                                var s = pt.size;
                                ctx.fillStyle = "rgba(254, 249, 195, " + spAlpha + ")";
                                ctx.beginPath();
                                ctx.moveTo(pt.x, pt.y - s);
                                ctx.quadraticCurveTo(pt.x, pt.y, pt.x + s, pt.y);
                                ctx.quadraticCurveTo(pt.x, pt.y, pt.x, pt.y + s);
                                ctx.quadraticCurveTo(pt.x, pt.y, pt.x - s, pt.y);
                                ctx.quadraticCurveTo(pt.x, pt.y, pt.x, pt.y - s);
                                ctx.fill();
                            }
                        }
                    }
                }
            }
        }
    }

    // --- 1. BUBBLES COMPONENT ---
    Component {
        id: bubblesComponent
        Item {
            anchors.fill: parent

            Repeater {
                model: [
                    { startX: 0.08, size: 260, speed: 5200, ampX: 85, op: 0.35 },
                    { startX: 0.32, size: 190, speed: 4200, ampX: 70, op: 0.40 },
                    { startX: 0.55, size: 320, speed: 5800, ampX: 105, op: 0.30 },
                    { startX: 0.76, size: 210, speed: 4600, ampX: 75, op: 0.38 },
                    { startX: 0.90, size: 250, speed: 5000, ampX: 90, op: 0.34 }
                ]

                Item {
                    width: modelData.size
                    height: modelData.size

                    property real posY: root.height + 140
                    property real phaseX: 0.0

                    x: (root.width * modelData.startX) + Math.sin(phaseX) * modelData.ampX
                    y: posY

                    NumberAnimation on posY {
                        loops: Animation.Infinite
                        running: root.isDashboardVisible && root.enableAnimatedFx
                        from: root.height + 140
                        to: -modelData.size - 100
                        duration: modelData.speed * 2.3
                    }

                    NumberAnimation on phaseX {
                        loops: Animation.Infinite
                        running: root.isDashboardVisible && root.enableAnimatedFx
                        from: 0.0
                        to: Math.PI * 2
                        duration: modelData.speed
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: width / 2
                        color: root.accentColor
                        opacity: modelData.op
                        border.color: Qt.lighter(root.accentColor, 1.8)
                        border.width: 2.5

                        Behavior on color { ColorAnimation { duration: 250; easing.type: Easing.OutCubic } }

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 4
                            radius: width / 2
                            color: "transparent"
                            border.color: Qt.tint(root.accentColor, Qt.rgba(1, 0.4, 0.8, 0.5))
                            border.width: 1.5
                        }

                        Rectangle {
                            width: parent.width * 0.32
                            height: width * 0.65
                            radius: width / 2
                            color: "#ffffff"
                            opacity: 0.75
                            rotation: -35
                            x: parent.width * 0.18
                            y: parent.height * 0.16
                        }

                        Rectangle {
                            width: parent.width * 0.16
                            height: width * 0.45
                            radius: width / 2
                            color: Qt.lighter(root.accentColor, 1.5)
                            opacity: 0.55
                            rotation: -35
                            x: parent.width * 0.68
                            y: parent.height * 0.72
                        }
                    }
                }
            }

            Repeater {
                model: 8
                Rectangle {
                    readonly property real bX: ((index * 83) % 960) / 960.0
                    readonly property real bS: (index % 4) * 4 + 8
                    readonly property int bSpeed: 3000 + (index * 400) % 3500

                    width: bS
                    height: bS
                    radius: bS / 2
                    color: (index % 2 === 0) ? "#ffffff" : root.accentColor
                    opacity: 0.60
                    border.color: "#ffffff"
                    border.width: 1

                    property real mY: root.height + 40
                    x: (root.width * bX) + Math.sin(mY * 0.05) * 20
                    y: mY

                    NumberAnimation on mY {
                        loops: Animation.Infinite
                        running: root.isDashboardVisible && root.enableAnimatedFx
                        from: root.height + 40
                        to: -60
                        duration: bSpeed
                    }
                }
            }
        }
    }

    // --- 2. DROPS COMPONENT ---
    Component {
        id: dropsComponent
        Item {
            anchors.fill: parent

            Canvas {
                id: dropsCanvas
                anchors.fill: parent
                renderTarget: Canvas.FramebufferObject
                renderStrategy: Canvas.Threaded

                property var rainDrops: []
                property var waterRipples: []

                onWidthChanged: initDrops()
                onHeightChanged: initDrops()

                function initDrops() {
                    var count = 30;
                    var arr = [];
                    for (var i = 0; i < count; i++) {
                        arr.push({
                            x: Math.random() * width,
                            y: Math.random() * -height,
                            speed: 7 + Math.random() * 8,
                            length: 12 + Math.random() * 14,
                            thickness: 1.2 + Math.random() * 1.4,
                            targetY: 140 + Math.random() * 320
                        });
                    }
                    rainDrops = arr;
                    waterRipples = [];
                }

                Component.onCompleted: initDrops()

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.clearRect(0, 0, width, height);

                    var hex = root.accentColor.toString();

                    for (var i = 0; i < rainDrops.length; i++) {
                        var d = rainDrops[i];
                        ctx.lineWidth = d.thickness;
                        ctx.beginPath();
                        ctx.moveTo(d.x, d.y);
                        ctx.lineTo(d.x, d.y + d.length);
                        ctx.stroke();

                        ctx.fillStyle = "#ffffff";
                        ctx.fillRect(d.x - 0.5, d.y + d.length - 2, d.thickness + 1, 2);

                        d.y += d.speed;

                        if (d.y >= d.targetY) {
                            if (waterRipples.length < 20) {
                                waterRipples.push({
                                    x: d.x,
                                    y: d.targetY,
                                    r: 2,
                                    maxR: 16 + Math.random() * 16,
                                    opacity: 0.85
                                });
                            }
                            d.x = Math.random() * width;
                            d.y = -Math.random() * 120;
                            d.speed = 7 + Math.random() * 8;
                            d.targetY = 140 + Math.random() * 320;
                        }
                    }

                    for (var j = waterRipples.length - 1; j >= 0; j--) {
                        var rip = waterRipples[j];
                        ctx.strokeStyle = Qt.tint(hex, Qt.rgba(1, 1, 1, rip.opacity * 0.4)).toString();
                        ctx.globalAlpha = rip.opacity;
                        ctx.lineWidth = 1.6;
                        ctx.beginPath();
                        ctx.ellipse(rip.x - rip.r, rip.y - rip.r * 0.35, rip.r * 2, rip.r * 0.7, 0, 0, Math.PI * 2);
                        ctx.stroke();
                        ctx.globalAlpha = 1.0;

                        rip.r += 1.3;
                        rip.opacity -= 0.045;
                        if (rip.opacity <= 0 || rip.r >= rip.maxR) {
                            waterRipples.splice(j, 1);
                        }
                    }
                }

                Timer {
                    interval: 45
                    running: root.isDashboardVisible && root.enableAnimatedFx && dropsCanvas.visible
                    repeat: true
                    onTriggered: dropsCanvas.requestPaint()
                }
            }
        }
    }

    // --- 3. STARFIELD COMPONENT ---
    Component {
        id: starfieldComponent
        Item {
            anchors.fill: parent

            Repeater {
                model: 20

                Rectangle {
                    id: warpStar
                    readonly property real baseX: (index * 79) % 960 / 960
                    readonly property real pSize: (index % 4) + 3
                    readonly property int starSpeed: 2200 + (index * 300) % 3000

                    width: pSize
                    height: pSize * 2.5
                    radius: pSize / 2
                    color: (index % 2 === 0) ? root.accentColor : "#ffffff"

                    Behavior on color { ColorAnimation { duration: 250; easing.type: Easing.OutCubic } }

                    property real starY: -50
                    x: (root.width * baseX)
                    y: starY

                    NumberAnimation on starY {
                        loops: Animation.Infinite
                        running: root.isDashboardVisible && root.enableAnimatedFx
                        from: -50
                        to: root.height + 50
                        duration: warpStar.starSpeed
                    }

                    opacity: 0.4 + 0.5 * Math.sin(index)
                }
            }
        }
    }

    // --- 4. COSMIC CALM OCEAN (Sinuous Smooth Ethereal GPU Sea - 0.1% CPU) ---
    Component {
        id: oceanComponent
        Item {
            id: oceanItem
            anchors.fill: parent

            // Sea Curtain 1: Emerald / Teal Wave
            Rectangle {
                anchors.top: parent.top
                anchors.topMargin: -80
                anchors.left: parent.left
                anchors.leftMargin: -120
                width: parent.width * 1.3
                height: parent.height * 0.75
                rotation: -6
                opacity: 0.45
                transformOrigin: Item.TopLeft

                gradient: Gradient {
                    orientation: Gradient.Vertical
                    GradientStop { position: 0.0; color: Qt.rgba(0.06, 0.73, 0.50, 0.50) } // #10b981
                    GradientStop { position: 0.4; color: Qt.rgba(0.02, 0.71, 0.83, 0.35) } // #06b6d4
                    GradientStop { position: 0.8; color: Qt.rgba(0.22, 0.74, 0.97, 0.10) }
                    GradientStop { position: 1.0; color: "transparent" }
                }

                SequentialAnimation on rotation {
                    loops: Animation.Infinite
                    running: root.isDashboardVisible && root.enableAnimatedFx
                    NumberAnimation { from: -6; to: 3; duration: 9000; easing.type: Easing.InOutSine }
                    NumberAnimation { from: 3; to: -6; duration: 9000; easing.type: Easing.InOutSine }
                }

                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    running: root.isDashboardVisible && root.enableAnimatedFx
                    NumberAnimation { from: 0.35; to: 0.60; duration: 6500; easing.type: Easing.InOutSine }
                    NumberAnimation { from: 0.60; to: 0.35; duration: 6500; easing.type: Easing.InOutSine }
                }

                SequentialAnimation on scale {
                    loops: Animation.Infinite
                    running: root.isDashboardVisible && root.enableAnimatedFx
                    NumberAnimation { from: 1.0; to: 1.15; duration: 8000; easing.type: Easing.InOutSine }
                    NumberAnimation { from: 1.15; to: 1.0; duration: 8000; easing.type: Easing.InOutSine }
                }
            }

            // Sea Curtain 2: Amethyst Purple / Deep Ocean Wave
            Rectangle {
                anchors.top: parent.top
                anchors.topMargin: -60
                anchors.right: parent.right
                anchors.rightMargin: -100
                width: parent.width * 1.25
                height: parent.height * 0.80
                rotation: 8
                opacity: 0.40
                transformOrigin: Item.TopRight

                gradient: Gradient {
                    orientation: Gradient.Vertical
                    GradientStop { position: 0.0; color: Qt.rgba(0.66, 0.33, 0.97, 0.50) } // #a855f7
                    GradientStop { position: 0.45; color: Qt.rgba(0.93, 0.28, 0.60, 0.30) } // #ec4899
                    GradientStop { position: 0.85; color: Qt.rgba(0.55, 0.36, 0.96, 0.08) }
                    GradientStop { position: 1.0; color: "transparent" }
                }

                SequentialAnimation on rotation {
                    loops: Animation.Infinite
                    running: root.isDashboardVisible && root.enableAnimatedFx
                    NumberAnimation { from: 8; to: -2; duration: 11000; easing.type: Easing.InOutSine }
                    NumberAnimation { from: -2; to: 8; duration: 11000; easing.type: Easing.InOutSine }
                }

                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    running: root.isDashboardVisible && root.enableAnimatedFx
                    NumberAnimation { from: 0.28; to: 0.52; duration: 7500; easing.type: Easing.InOutSine }
                    NumberAnimation { from: 0.52; to: 0.28; duration: 7500; easing.type: Easing.InOutSine }
                }
            }

            // Sea Curtain 3: Accent Color Dynamic Sea Ribbon
            Rectangle {
                anchors.top: parent.top
                anchors.topMargin: -40
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width * 1.1
                height: parent.height * 0.70
                rotation: -1
                opacity: 0.32

                gradient: Gradient {
                    orientation: Gradient.Vertical
                    GradientStop { position: 0.0; color: Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.45) }
                    GradientStop { position: 0.5; color: Qt.rgba(0.22, 0.74, 0.97, 0.20) }
                    GradientStop { position: 1.0; color: "transparent" }
                }

                SequentialAnimation on rotation {
                    loops: Animation.Infinite
                    running: root.isDashboardVisible && root.enableAnimatedFx
                    NumberAnimation { from: -3; to: 4; duration: 13000; easing.type: Easing.InOutSine }
                    NumberAnimation { from: 4; to: -3; duration: 13000; easing.type: Easing.InOutSine }
                }

                SequentialAnimation on opacity {
                    loops: Animation.Infinite
                    running: root.isDashboardVisible && root.enableAnimatedFx
                    NumberAnimation { from: 0.20; to: 0.45; duration: 8500; easing.type: Easing.InOutSine }
                    NumberAnimation { from: 0.45; to: 0.20; duration: 8500; easing.type: Easing.InOutSine }
                }
            }
        }
    }

    // --- 5. AUTHENTIC AURORA BOREALIS (Undulating Sinusoidal Wave Ribbons - Optimized CPU) ---
    Component {
        id: auroraComponent
        Item {
            id: auroraItem
            anchors.fill: parent

            Canvas {
                id: auroraCanvas
                anchors.fill: parent
                renderTarget: Canvas.FramebufferObject
                renderStrategy: Canvas.Threaded

                property real wavePhase: 0.0

                Timer {
                    interval: 33 // 30 FPS smooth sinusoidal progression
                    running: root.isDashboardVisible && root.enableAnimatedFx && auroraItem.visible
                    repeat: true
                    onTriggered: {
                        auroraCanvas.wavePhase += 0.025;
                        if (auroraCanvas.wavePhase > Math.PI * 200) auroraCanvas.wavePhase = 0;
                        auroraCanvas.requestPaint();
                    }
                }

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.clearRect(0, 0, width, height);

                    var w = width || 1280;
                    var phase = wavePhase;

                    // Wave Ribbon 1: Luminous Emerald / Cyan Wave
                    ctx.beginPath();
                    ctx.moveTo(0, 0);
                    for (var x = 0; x <= w; x += 45) {
                        var y = 135 + Math.sin((x / 140.0) + phase) * 45 + Math.cos((x / 240.0) + (2 * phase)) * 25;
                        ctx.lineTo(x, y);
                    }
                    ctx.lineTo(w, 0);
                    ctx.closePath();

                    var grad1 = ctx.createLinearGradient(0, 0, 0, 250);
                    grad1.addColorStop(0.0, "rgba(34, 197, 94, 0.42)");
                    grad1.addColorStop(0.5, "rgba(6, 182, 212, 0.25)");
                    grad1.addColorStop(1.0, "rgba(0, 0, 0, 0.0)");
                    ctx.fillStyle = grad1;
                    ctx.fill();

                    // Wave Ribbon 2: Deep Amethyst Violet / Pink Wave
                    ctx.beginPath();
                    ctx.moveTo(0, 0);
                    for (var x2 = 0; x2 <= w; x2 += 45) {
                        var y2 = 185 + Math.sin((x2 / 180.0) - phase) * 50 + Math.sin((x2 / 110.0) + (2 * phase)) * 30;
                        ctx.lineTo(x2, y2);
                    }
                    ctx.lineTo(w, 0);
                    ctx.closePath();

                    var grad2 = ctx.createLinearGradient(0, 0, 0, 320);
                    grad2.addColorStop(0.0, "rgba(168, 85, 247, 0.38)");
                    grad2.addColorStop(0.5, "rgba(56, 189, 248, 0.20)");
                    grad2.addColorStop(1.0, "rgba(0, 0, 0, 0.0)");
                    ctx.fillStyle = grad2;
                    ctx.fill();
                }
            }
        }
    }

    // --- 5. MATRIX COMPONENT (cmatrix Code Rain) ---
    Component {
        id: matrixComponent
        Item {
            anchors.fill: parent

            Canvas {
                id: matrixCanvas
                anchors.fill: parent
                renderTarget: Canvas.FramebufferObject
                renderStrategy: Canvas.Threaded

                readonly property var glyphList: "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZPLASMAKDE".split("")
                readonly property int colWidth: 22
                property var streamPositions: []

                onWidthChanged: initMatrix()
                onHeightChanged: initMatrix()

                function initMatrix() {
                    var totalCols = Math.max(10, Math.floor(width / colWidth));
                    var arr = [];
                    for (var i = 0; i < totalCols; i++) {
                        arr.push(Math.floor(Math.random() * -25));
                    }
                    streamPositions = arr;
                }

                Component.onCompleted: initMatrix()

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.fillStyle = "rgba(8, 12, 20, 0.18)";
                    ctx.fillRect(0, 0, width, height);

                    ctx.font = "bold 14px monospace";
                    var hexColor = root.accentColor.toString();

                    for (var i = 0; i < streamPositions.length; i++) {
                        var randChar = glyphList[Math.floor(Math.random() * glyphList.length)];
                        var xPos = i * colWidth;
                        var yPos = streamPositions[i] * 18;

                        if (yPos > 0 && yPos < height + 30) {
                            ctx.fillStyle = "#ffffff";
                            ctx.fillText(randChar, xPos, yPos);

                            ctx.fillStyle = hexColor;
                            ctx.fillText(glyphList[Math.floor(Math.random() * glyphList.length)], xPos, yPos - 18);
                        }

                        if (yPos > height && Math.random() > 0.975) {
                            streamPositions[i] = 0;
                        }
                        streamPositions[i]++;
                    }
                }

                Timer {
                    interval: 50
                    running: root.isDashboardVisible && root.enableAnimatedFx && matrixCanvas.visible
                    repeat: true
                    onTriggered: matrixCanvas.requestPaint()
                }
            }
        }
    }
}
