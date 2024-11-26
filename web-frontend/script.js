// Predefined password
let password;
fetch("config.json")
    .then((response) => response.json())
    .then((config) => {
        PASSWORD = config.password;
    });

// DOM elements
const authSection = document.getElementById("auth-section");
const mainSection = document.getElementById("main-section");
const passwordInput = document.getElementById("password-input");
const loginBtn = document.getElementById("login-btn");
const errorMessage = document.getElementById("error-message");
const statusIndicator = document.getElementById("status-indicator");
const connectBtn = document.getElementById("connect-btn");
const photoBtn = document.getElementById("photo-btn");
const displayBtn = document.getElementById("display-btn");
const photosSection = document.getElementById("photos-section");
const photosContainer = document.getElementById("photos-container");

// Handle login
loginBtn.addEventListener("click", () => {
    if (passwordInput.value === PASSWORD) {
        authSection.classList.add("hidden");
        mainSection.classList.remove("hidden");
    } else {
        errorMessage.classList.remove("hidden");
    }
});

// Mock API calls (replace with real API calls later)
function updateStatus(connected) {
    statusIndicator.textContent = connected ? "Connected" : "Disconnected";
    statusIndicator.style.color = connected ? "green" : "red";
}

function displayPhotos(photos) {
    photosContainer.innerHTML = ""; // Clear previous photos
    photos.forEach((photo) => {
        const img = document.createElement("img");
        img.src = photo.url;
        photosContainer.appendChild(img);
    });
    photosSection.classList.remove("hidden");
}

// Connect ESP32
connectBtn.addEventListener("click", () => {
    // Mock connection logic
    updateStatus(true);
});

// Take Photo
photoBtn.addEventListener("click", () => {
    // Mock photo-taking logic
    alert("Photo taken!");
});

// Display Photos
displayBtn.addEventListener("click", () => {
    // Mock photos
    const mockPhotos = [
        { url: "https://via.placeholder.com/100" },
        { url: "https://via.placeholder.com/100" },
        { url: "https://via.placeholder.com/100" },
        { url: "https://via.placeholder.com/100" },
        { url: "https://via.placeholder.com/100" },
    ];
    displayPhotos(mockPhotos);
});
