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

// Display photos helper function
function displayPhotos(photos) {
  console.log('Photos Array:', photos) // Debug the photos array

  photosContainer.innerHTML = '' // Clear previous photos
  photos.forEach((photoUrl) => {
    console.log('Photo URL:', photoUrl) // Debug each URL

    const img = document.createElement('img')
    img.src = photoUrl
    img.alt = 'Photo'

    photosContainer.appendChild(img)
  })
  photosSection.classList.remove('hidden')
}

// A reusable fetch for photos
function fetchAndShowPhotos() {
  fetch(
    'https://vw91j17z98.execute-api.us-west-1.amazonaws.com/dev/display-photos'
  )
    .then((response) => response.json())
    .then((data) => {
      console.log('API Response:', data) // Debug response data
      if (data.photos && Array.isArray(data.photos)) {
        displayPhotos(data.photos)
      } else {
        console.error('Invalid response structure:', data)
        alert('Failed to load photos. Please try again later.')
      }
    })
    .catch((error) => {
      console.error('Error fetching photos:', error)
      alert('Failed to load photos. Please try again later.')
    })
}

// Take Photo
photoBtn.addEventListener('click', () => {
  fetch(
    'https://vw91j17z98.execute-api.us-west-1.amazonaws.com/dev/take-photo',
    {
      method: 'POST',
    }
  )
    .then((response) => {
      if (response.ok) {
        return response.json()
      } else {
        throw new Error('Failed to invoke take-photo endpoint')
      }
    })
    .then((data) => {
      console.log('API Response:', data)
      alert('Command sent to ESP32 to take a photo!')

      // After success, wait 5 seconds, then auto display the updated photos
      setTimeout(() => {
        fetchAndShowPhotos()
      }, 1000)
    })
    .catch((error) => {
      console.error('Error invoking take-photo endpoint:', error)
      alert('Failed to send the take photo command. Please try again.')
    })
})

displayBtn.addEventListener('click', fetchAndShowPhotos)
