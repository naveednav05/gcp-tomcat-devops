
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Naveed | Cloud & DevOps Engineer</title>

    <style>
        :root {
            --bg: #070b14;
            --panel: rgba(17, 25, 43, 0.82);
            --cyan: #00f5ff;
            --purple: #a855f7;
            --green: #39ff88;
            --text: #e8f1ff;
            --muted: #8b9bb4;
            --border: rgba(0, 245, 255, 0.19);
        }

        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        html {
            scroll-behavior: smooth;
        }

        body {
            min-height: 100vh;
            background:
                radial-gradient(ellipse at 15% 10%,
                    rgba(0, 245, 255, 0.10), transparent 40%),
                radial-gradient(ellipse at 85% 50%,
                    rgba(168, 85, 247, 0.10), transparent 42%),
                var(--bg);
            color: var(--text);
            font-family: "Segoe UI", Arial, sans-serif;
            overflow-x: hidden;
        }

        #particles {
            position: fixed;
            inset: 0;
            width: 100%;
            height: 100%;
            pointer-events: none;
            z-index: 0;
        }

        .container {
            position: relative;
            z-index: 1;
            max-width: 1120px;
            width: 90%;
            margin: auto;
        }

        nav {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 26px 0;
            border-bottom: 1px solid rgba(255,255,255,0.07);
        }

        .logo {
            font-size: 19px;
            font-weight: 800;
            letter-spacing: 1px;
        }

        .logo span {
            color: var(--cyan);
            text-shadow: 0 0 15px rgba(0,245,255,.65);
        }

        .nav-status {
            display: flex;
            align-items: center;
            gap: 9px;
            color: var(--green);
            font-size: 12px;
            letter-spacing: 1px;
        }

        .dot {
            width: 8px;
            height: 8px;
            border-radius: 50%;
            background: var(--green);
            box-shadow: 0 0 12px var(--green);
            animation: pulse 1.8s infinite;
        }

        .hero {
            text-align: center;
            padding: 86px 0 55px;
        }

        .eyebrow {
            display: inline-block;
            color: var(--cyan);
            border: 1px solid var(--border);
            background: rgba(0,245,255,.05);
            border-radius: 30px;
            padding: 9px 17px;
            font-size: 11px;
            letter-spacing: 2px;
            margin-bottom: 27px;
        }

        h1 {
            font-size: clamp(42px, 8vw, 82px);
            line-height: 1.1;
            letter-spacing: -3px;
            margin-bottom: 18px;
        }

        .gradient-text {
            background: linear-gradient(100deg,
                #00f5ff 10%, #7c9cff 48%, #c084fc 90%);
            -webkit-background-clip: text;
            background-clip: text;
            color: transparent;
            filter: drop-shadow(0 0 22px rgba(0,245,255,.15));
        }

        .subtitle {
            color: var(--muted);
            font-size: clamp(15px, 2vw, 19px);
            line-height: 1.8;
            max-width: 680px;
            margin: 0 auto 28px;
        }

        .buttons {
            display: flex;
            justify-content: center;
            gap: 14px;
            flex-wrap: wrap;
            margin-top: 30px;
        }

        .btn {
            padding: 13px 21px;
            border-radius: 9px;
            font-size: 13px;
            font-weight: 700;
            cursor: pointer;
            transition: .25s;
            text-decoration: none;
        }

        .btn-primary {
            color: #041016;
            background: var(--cyan);
            border: 1px solid var(--cyan);
            box-shadow: 0 0 24px rgba(0,245,255,.19);
        }

        .btn-secondary {
            color: var(--text);
            background: rgba(255,255,255,.035);
            border: 1px solid rgba(255,255,255,.14);
        }

        .btn:hover {
            transform: translateY(-3px);
            box-shadow: 0 0 28px rgba(0,245,255,.3);
        }

        .section-title {
            text-align: center;
            margin: 25px 0 27px;
            font-size: 23px;
        }

        .section-title span {
            color: var(--cyan);
        }

        .grid {
            display: grid;
            grid-template-columns: repeat(3, minmax(0, 1fr));
            gap: 18px;
        }

        .card {
            position: relative;
            overflow: hidden;
            background: var(--panel);
            border: 1px solid var(--border);
            border-radius: 15px;
            padding: 25px;
            backdrop-filter: blur(12px);
            transition: transform .25s, border-color .25s;
        }

        .card::before {
            content: "";
            position: absolute;
            top: 0;
            left: 18px;
            right: 18px;
            height: 1px;
            background: linear-gradient(90deg,
                transparent, var(--cyan), transparent);
            opacity: .6;
        }

        .card:hover {
            transform: translateY(-5px);
            border-color: rgba(0,245,255,.6);
        }

        .card-icon {
            font-size: 28px;
            margin-bottom: 16px;
        }

        .card h3 {
            font-size: 16px;
            margin-bottom: 9px;
        }

        .card p {
            color: var(--muted);
            font-size: 13px;
            line-height: 1.8;
        }

        .tags {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            margin-top: 17px;
        }

        .tag {
            font-size: 10px;
            padding: 6px 9px;
            border-radius: 5px;
            color: var(--cyan);
            background: rgba(0,245,255,.07);
            border: 1px solid rgba(0,245,255,.13);
        }

        .pipeline {
            margin-top: 75px;
        }

        .pipeline-flow {
            display: flex;
            align-items: center;
            justify-content: center;
            flex-wrap: wrap;
            gap: 12px;
            padding: 30px 15px;
            background: rgba(17,25,43,.58);
            border: 1px solid rgba(255,255,255,.08);
            border-radius: 15px;
        }

        .stage {
            padding: 12px 15px;
            border: 1px solid rgba(168,85,247,.4);
            background: rgba(168,85,247,.07);
            border-radius: 8px;
            font-size: 12px;
            text-align: center;
        }

        .stage small {
            display: block;
            color: var(--muted);
            margin-top: 5px;
        }

        .arrow {
            color: var(--cyan);
            font-size: 20px;
        }

        .terminal {
            margin-top: 65px;
            border: 1px solid rgba(0,245,255,.23);
            border-radius: 13px;
            overflow: hidden;
            background: rgba(3,7,15,.88);
            box-shadow: 0 0 40px rgba(0,245,255,.045);
        }

        .terminal-header {
            display: flex;
            align-items: center;
            gap: 7px;
            padding: 13px 17px;
            background: rgba(255,255,255,.035);
            border-bottom: 1px solid rgba(255,255,255,.07);
            color: var(--muted);
            font-size: 12px;
        }

        .terminal-dot {
            width: 9px;
            height: 9px;
            border-radius: 50%;
        }

        .terminal-body {
            padding: 22px;
            font-family: Consolas, "Courier New", monospace;
            font-size: 12px;
            line-height: 2;
            overflow-wrap: anywhere;
        }

        .prompt { color: var(--green); }
        .command { color: var(--cyan); }
        .output { color: #a6b6ce; }
        .success { color: var(--green); }

        .cursor {
            display: inline-block;
            width: 7px;
            height: 14px;
            background: var(--cyan);
            vertical-align: middle;
            animation: blink 1s steps(2) infinite;
        }

        .footer {
            text-align: center;
            color: var(--muted);
            font-size: 12px;
            padding: 42px 0 28px;
            margin-top: 55px;
            border-top: 1px solid rgba(255,255,255,.07);
        }

        .footer span { color: var(--cyan); }

        @keyframes pulse {
            50% { opacity: .35; box-shadow: 0 0 3px var(--green); }
        }

        @keyframes blink {
            to { visibility: hidden; }
        }

        @media (max-width: 760px) {
            .grid { grid-template-columns: repeat(2, minmax(0, 1fr)); }
            .hero { padding-top: 65px; }
            h1 { letter-spacing: -1.5px; }
        }

        @media (max-width: 500px) {
            .grid { grid-template-columns: 1fr; }
            .hero { padding-top: 50px; }
            .card { padding: 22px; }
            .pipeline-flow { flex-direction: column; }
            .arrow { transform: rotate(90deg); }
            nav { gap: 12px; }
            .logo { font-size: 16px; }
            .nav-status { font-size: 10px; }
        }

        @media (prefers-reduced-motion: reduce) {
            *, *::before, *::after {
                animation-duration: .01ms !important;
                transition-duration: .01ms !important;
                scroll-behavior: auto !important;
            }
        }
    </style>
</head>

<body>
<canvas id="particles" aria-hidden="true"></canvas>

<div class="container">

    <nav>
        <div class="logo">NAVEED<span>.UAT</span></div>
        <div class="nav-status">
            <span class="dot"></span>
            <span>APPLICATION ONLINE</span>
        </div>
    </nav>

    <section class="hero">
        <div class="eyebrow">CLOUD ENGINEERING / DEVOPS</div>

        <h1>
            Hi, I'm <span class="gradient-text">Naveed.</span>
        </h1>

        <p class="subtitle">
            Building reliable, scalable and automated cloud infrastructure.
            From CI/CD pipelines to Kubernetes deployments —
            turning code into production.
        </p>

        <div class="buttons">
            <a href="#expertise" class="btn btn-primary">
                Explore My Stack ↘
            </a>
            <button class="btn btn-secondary" id="terminalBtn" type="button">
                Run System Check
            </button>
        </div>
    </section>

    <section id="expertise">
        <h2 class="section-title">My <span>Technology Stack</span></h2>

        <div class="grid">
            <article class="card">
                <div class="card-icon">☁️</div>
                <h3>Cloud Engineering</h3>
                <p>Cloud infrastructure, container platforms and production deployments.</p>
                <div class="tags">
                    <span class="tag">GCP</span>
                    <span class="tag">AWS</span>
                    <span class="tag">GKE</span>
                </div>
            </article>

            <article class="card">
                <div class="card-icon">♾️</div>
                <h3>CI/CD Automation</h3>
                <p>Automated build, artifact management, image publishing and release pipelines.</p>
                <div class="tags">
                    <span class="tag">Jenkins</span>
                    <span class="tag">GitHub</span>
                    <span class="tag">Maven</span>
                </div>
            </article>

            <article class="card">
                <div class="card-icon">🐳</div>
                <h3>Containers</h3>
                <p>Container image creation, versioning, deployment and orchestration.</p>
                <div class="tags">
                    <span class="tag">Docker</span>
                    <span class="tag">Kubernetes</span>
                    <span class="tag">Tomcat</span>
                </div>
            </article>

            <article class="card">
                <div class="card-icon">🚀</div>
                <h3>GitOps & Delivery</h3>
                <p>Declarative deployments, Git-based configuration and release reconciliation.</p>
                <div class="tags">
                    <span class="tag">Argo CD</span>
                    <span class="tag">Helm</span>
                    <span class="tag">GitOps</span>
                </div>
            </article>

            <article class="card">
                <div class="card-icon">⚙️</div>
                <h3>Infrastructure as Code</h3>
                <p>Automating infrastructure provisioning and configuration management.</p>
                <div class="tags">
                    <span class="tag">Terraform</span>
                    <span class="tag">Ansible</span>
                    <span class="tag">Linux</span>
                </div>
            </article>

            <article class="card">
                <div class="card-icon">📊</div>
                <h3>Observability</h3>
                <p>Monitoring workloads, investigating logs and improving reliability.</p>
                <div class="tags">
                    <span class="tag">Prometheus</span>
                    <span class="tag">Grafana</span>
                    <span class="tag">Splunk</span>
                </div>
            </article>
        </div>
    </section>

    <section class="pipeline">
        <h2 class="section-title">My <span>Deployment Pipeline</span></h2>

        <div class="pipeline-flow">
            <div class="stage">01 · SOURCE<small>GitHub</small></div>
            <span class="arrow">→</span>
            <div class="stage">02 · BUILD<small>Jenkins + Maven</small></div>
            <span class="arrow">→</span>
            <div class="stage">03 · PACKAGE<small>WAR Artifact</small></div>
            <span class="arrow">→</span>
            <div class="stage">04 · CONTAINER<small>Docker Image</small></div>
            <span class="arrow">→</span>
            <div class="stage">05 · DEPLOY<small>Argo CD + GKE</small></div>
        </div>
    </section>

    <section class="terminal" id="terminal">
        <div class="terminal-header">
            <span class="terminal-dot" style="background:#ff5f57"></span>
            <span class="terminal-dot" style="background:#febc2e"></span>
            <span class="terminal-dot" style="background:#28c840"></span>
            <span style="margin-left:8px">naveed@cloud-platform:~</span>
        </div>

        <div class="terminal-body" id="terminalOutput" aria-live="polite">
            <div class="prompt">$ <span class="command">kubectl get deployment</span></div>
            <div class="output">NAME              READY   STATUS</div>
            <div class="output">myapp             1/1     Running</div>
            <div class="prompt">$ <span class="command">echo $PLATFORM</span></div>
            <div class="success">Google Kubernetes Engine (GKE)</div>
            <div class="prompt">$ <span class="command">echo $MISSION</span></div>
            <div class="success">Automate. Deploy. Scale. Repeat.</div>
            <div class="prompt">$ <span class="cursor"></span></div>
        </div>
    </section>

    <footer class="footer">
        <p>Designed & deployed by <span>Naveed Ibrahim</span></p>
        <p style="margin-top:9px">
            CI: Jenkins &nbsp;|&nbsp; CD: Argo CD &nbsp;|&nbsp; Runtime: Tomcat on GKE
        </p>
        <p style="margin-top:12px">© <span id="year"></span> · Built for the cloud.</p>
    </footer>

</div>

<script>
    // Dynamic footer year
    document.getElementById("year").textContent =
        new Date().getFullYear();

    // Lightweight animated background particles
    (function () {
        const canvas = document.getElementById("particles");
        const ctx = canvas.getContext("2d");
        if (!ctx) return;

        let width, height, particles = [];
        let frame = 0;
        const reduceMotion = window.matchMedia(
            "(prefers-reduced-motion: reduce)"
        ).matches;

        function resize() {
            const dpr = Math.min(window.devicePixelRatio || 1, 2);
            width = window.innerWidth;
            height = window.innerHeight;
            canvas.width = width * dpr;
            canvas.height = height * dpr;
            canvas.style.width = width + "px";
            canvas.style.height = height + "px";
            ctx.setTransform(dpr, 0, 0, dpr, 0, 0);

            const count = Math.min(65, Math.floor(width / 18));
            particles = Array.from({ length: count }, () => ({
                x: Math.random() * width,
                y: Math.random() * height,
                r: Math.random() * 1.5 + 0.4,
                speed: Math.random() * 0.25 + 0.08
            }));
        }

        function draw() {
            ctx.clearRect(0, 0, width, height);

            particles.forEach((p, i) => {
                if (!reduceMotion) {
                    p.y -= p.speed;
                    if (p.y < 0) {
                        p.y = height;
                        p.x = Math.random() * width;
                    }
                }

                ctx.beginPath();
                ctx.arc(p.x, p.y, p.r, 0, Math.PI * 2);
                ctx.fillStyle = i % 3 === 0
                    ? "rgba(168,85,247,0.65)"
                    : "rgba(0,245,255,0.55)";
                ctx.fill();
            });

            if (!reduceMotion) {
                frame = requestAnimationFrame(draw);
            }
        }

        window.addEventListener("resize", resize);
        resize();
        draw();

        window.addEventListener("pagehide", () => {
            cancelAnimationFrame(frame);
        });
    })();

    // Interactive simulated system check
    document.getElementById("terminalBtn").addEventListener("click", function () {
        const output = document.getElementById("terminalOutput");

        output.innerHTML = `
            <div class="prompt">$ <span class="command">./system-check.sh</span></div>
            <div class="success">[OK] Application interface loaded</div>
            <div class="success">[OK] JavaScript is operational</div>
            <div class="success">[OK] Deployment dashboard rendered</div>
            <div class="output">[INFO] Runtime: Tomcat / Kubernetes target</div>
            <div class="success">[OK] Demo system check completed</div>
            <div class="prompt">$ <span class="cursor"></span></div>
        `;

        document.getElementById("terminal").scrollIntoView({
            behavior: "smooth",
            block: "center"
        });
    });
</script>

</body>
</html>
