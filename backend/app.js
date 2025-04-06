const express = require("express");
const path = require("path");
const http = require("http");
const socketIo = require("socket.io");
const ioClient = require("socket.io-client");

const app = express();
const server = http.createServer(app);

// Enable CORS for WebSocket and HTTP
const io = socketIo(server, {
    cors: {
        origin: "*", // Change to frontend URL in production
        methods: ["GET", "POST"],
        credentials: true
    },
    transports: ["websocket", "polling"],
});

// Middleware
app.use(express.static(path.join(__dirname, "public"))); // Serve static files
app.use(express.json()); // Middleware to parse JSON requests
app.set("view engine", "ejs");

// Store agent's latest location
const agentLocation = {
    id: "agent123",
    latitude: 21.1702, // Default Surat location
    longitude: 72.8311
};

// Serve the tracking page
app.get("/", (req, res) => {
    res.render("index");
});

// WebSocket Connection Handling
io.on("connection", (socket) => {
    console.log(`✅ [${new Date().toLocaleTimeString()}] User connected: ${socket.id}`);

    // Send acknowledgment to the client
    socket.emit("connected", { message: "Connected to WebSocket server!" });

    // Send the latest agent location to new connections
    socket.emit("receive-location", agentLocation);

    // Listen for agent's location updates
    socket.on("send-location", (data) => {
        if (!data || typeof data.latitude !== "number" || typeof data.longitude !== "number") {
            console.error("⚠️ Invalid location data received:", data);
            return;
        }

        // Update stored agent location
        agentLocation.latitude = data.latitude;
        agentLocation.longitude = data.longitude;

        console.log(`📍 [${new Date().toLocaleTimeString()}] Updated location:`, agentLocation);

        // Broadcast updated location to all clients
        io.emit("receive-location", agentLocation);
    });

    socket.on("disconnect", () => {
        console.log(`❌ [${new Date().toLocaleTimeString()}] User disconnected: ${socket.id}`);
    });

    socket.on("error", (error) => {
        console.error(`⚠️ WebSocket Error for ${socket.id}:`, error);
    });

    socket.on("heartbeat", () => {
        socket.emit("heartbeat-response", { status: "alive" });
    });
});

// API to manually update agent location
app.post("/update-location", (req, res) => {
    const { latitude, longitude } = req.body;

    if (!latitude || !longitude || typeof latitude !== "number" || typeof longitude !== "number") {
        return res.status(400).json({ error: "Invalid location data" });
    }

    // Update stored location
    agentLocation.latitude = latitude;
    agentLocation.longitude = longitude;

    console.log(`📍 [${new Date().toLocaleTimeString()}] Manually updated location:`, agentLocation);

    // Broadcast new location to all connected clients
    io.emit("receive-location", agentLocation);

    res.json({ message: "Location updated successfully", agentLocation });
});

// Start Server
const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
    console.log(`🚀 Server running at http://localhost:${PORT}`);

    // Start the agent simulation once the server is running
    startAgentSimulation();
});

// ====== Simulated Agent to Send Latest Location ======
function startAgentSimulation() {
    const socket = ioClient("http://localhost:3000", {
        transports: ["websocket"],
        reconnection: true,
        reconnectionAttempts: 10, // Try reconnecting 10 times
        reconnectionDelay: 2000 // Wait 2 seconds before retrying
    });

    socket.on("connect", () => {
        console.log("✅ [Agent] Connected as agent123");

        // Send initial location
        socket.emit("send-location", agentLocation);

        // Send location update every 5 seconds
        setInterval(() => {
            console.log("📤 [Agent] Sending latest location:", agentLocation);
            socket.emit("send-location", agentLocation);
        }, 5000);
    });

    socket.on("disconnect", () => {
        console.log("❌ [Agent] Disconnected! Reconnecting...");
    });

    socket.on("connect_error", (err) => {
        console.error("⚠️ [Agent] Connection error:", err);
    });
}
