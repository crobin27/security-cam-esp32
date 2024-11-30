// Predefined password
let PASSWORD

// Fetch config and password (optional if you want to load it dynamically)
fetch('config.json')
  .then((response) => response.json())
  .then((config) => {
    PASSWORD = config.password
  })
  .catch((error) => {
    console.error('Error loading config:', error)
  })

// DOM elements
const authSection = document.getElementById('auth-section')
const mainSection = document.getElementById('main-section')
const passwordInput = document.getElementById('password-input')
const loginBtn = document.getElementById('login-btn')
const errorMessage = document.getElementById('error-message')
const statusIndicator = document.getElementById('status-indicator')
const connectBtn = document.getElementById('connect-btn')
const photoBtn = document.getElementById('photo-btn')
const displayBtn = document.getElementById('display-btn')
const photosSection = document.getElementById('photos-section')
const photosContainer = document.getElementById('photos-container')

// Handle login
loginBtn.addEventListener('click', () => {
  if (passwordInput.value === PASSWORD) {
    authSection.classList.add('hidden')
    mainSection.classList.remove('hidden')
  } else {
    errorMessage.classList.remove('hidden')
  }
})

// Update connection status
function updateStatus(connected) {
  statusIndicator.textContent = connected ? 'Connected' : 'Disconnected'
  statusIndicator.style.color = connected ? 'green' : 'red'
}
function displayPhotos(photos) {
  console.log('Photos Array:', photos) // Debug the photos array

  photosContainer.innerHTML = '' // Clear previous photos
  photos.forEach((photoUrl) => {
    console.log('Photo URL:', photoUrl) // Debug each URL

    const img = document.createElement('img')
    img.src = photoUrl // Use the photo URL directly
    img.alt = 'Photo'
    img.style.width = '150px'
    img.style.margin = '10px'

    photosContainer.appendChild(img)
  })
  photosSection.classList.remove('hidden')
}

// Connect ESP32
connectBtn.addEventListener('click', () => {
  updateStatus(true)
  alert('Connected to ESP32!')
})

// Take Photo
photoBtn.addEventListener('click', () => {
  alert('Photo taken! (mock implementation)')
})

displayBtn.addEventListener('click', () => {
  fetch(
    'https://vprq5nsol6.execute-api.us-west-1.amazonaws.com/dev/display-photos'
  )
    .then((response) => response.json())
    .then((data) => {
      console.log('API Response:', data) // Debug response data
      if (data.photos && Array.isArray(data.photos)) {
        displayPhotos(data.photos) // Pass the photos array to displayPhotos
      } else {
        console.error('Invalid response structure:', data)
        alert('Failed to load photos. Please try again later.')
      }
    })
    .catch((error) => {
      console.error('Error fetching photos:', error)
      alert('Failed to load photos. Please try again later.')
    })
})
