// ==============================
// CONFIG
// ==============================
const SCAN_INTERVAL = 10 * 60 * 1000; // 10 minutes
const RESULTS_DIR   = "./results";

let countdown = SCAN_INTERVAL / 1000;
let scanRunning = false;

// ==============================
// LOGGING
// ==============================
function log(message, type = "info") {
    const box = document.getElementById("log-box");
    const line = document.createElement("div");
    const time = new Date().toLocaleTimeString();
    line.className = "log-line " + type;
    line.textContent = "[" + time + "] " + message;
    box.appendChild(line);
    box.scrollTop = box.scrollHeight;
}

// ==============================
// FETCH RESULTS
// ==============================
async function fetchFile(path) {
    try {
        const res = await fetch(path);
        if (!res.ok) return null;
        return await res.text();
    } catch (e) {
        return null;
    }
}

async function loadResults() {
    log("Loading scan results...");

    // Load hosts
    const hostsData = await fetchFile(RESULTS_DIR + "/hosts.txt");
    if (!hostsData) {
        log("No hosts.txt found", "warn");
        return;
    }

    const hosts = hostsData.trim().split("\n").filter(h => h.length > 0);
    document.getElementById("host-count").textContent = hosts.length;
    log("Found " + hosts.length + " host(s)");

    const tbody = document.getElementById("hosts-body");
    tbody.innerHTML = "";

    let totalPorts = 0;

    for (const ip of hosts) {
        const portsData  = await fetchFile(RESULTS_DIR + "/ports_" + ip + ".txt");
        const nmapData   = await fetchFile(RESULTS_DIR + "/nmap_" + ip + ".txt");

        // Parse ports
        const ports = portsData ? portsData.trim() : "N/A";
        const portList = ports !== "N/A" ? ports.split(",") : [];
        totalPorts += portList.length;

        // Parse services from nmap output
        let services = "Pending";
        if (nmapData) {
            const lines = nmapData.split("\n");
            const serviceLines = lines
                .filter(l => /\d+\/tcp\s+open/.test(l))
                .map(l => l.trim().replace(/\s+/g, " "))
                .slice(0, 3);
            services = serviceLines.length > 0 ? serviceLines.join(" | ") : "No services detected";
        }

        const row = document.createElement("tr");
        row.innerHTML =
            "<td>" + ip + "</td>" +
            "<td>" + ports + "</td>" +
            "<td style='font-size:11px;color:#888'>" + services + "</td>" +
            "<td style='color:#00ff9f'>online</td>";
        tbody.appendChild(row);

        log("Loaded data for " + ip + " — ports: " + ports);
    }

    document.getElementById("port-count").textContent = totalPorts;
    document.getElementById("last-updated").textContent = "Last updated: " + new Date().toLocaleTimeString();
    log("Results loaded successfully", "done");
}

// ==============================
// RUN SCAN (calls watcher via backend)
// ==============================
async function runScan() {
    if (scanRunning) return;
    scanRunning = true;

    document.getElementById("scan-status").textContent = "Running...";
    document.getElementById("scan-now").disabled = true;
    log("Starting watcher scan...", "info");

    try {
        const res = await fetch("/run-scan", { method: "POST" });
        const data = await res.json();
        if (data.success) {
            log("Scan completed", "done");
            await loadResults();
        } else {
            log("Scan failed: " + data.error, "error");
        }
    } catch (e) {
        log("Could not reach scan server. Is server.py running?", "error");
    }

    document.getElementById("scan-status").textContent = "Idle";
    document.getElementById("scan-now").disabled = false;
    scanRunning = false;
    countdown = SCAN_INTERVAL / 1000;
}

// ==============================
// COUNTDOWN TIMER
// ==============================
function updateCountdown() {
    countdown--;
    if (countdown <= 0) {
        countdown = SCAN_INTERVAL / 1000;
        runScan();
    }
    const m = String(Math.floor(countdown / 60)).padStart(2, "0");
    const s = String(countdown % 60).padStart(2, "0");
    document.getElementById("next-scan").textContent = "Next scan in: " + m + ":" + s;
}

// ==============================
// INIT
// ==============================
loadResults();
setInterval(updateCountdown, 1000);
