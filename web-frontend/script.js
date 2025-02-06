// Predefined password
let PASSWORD

// Fetch config and password
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
const photoBtn = document.getElementById('photo-btn')
const displayBtn = document.getElementById('display-btn')
const motionBtn = document.getElementById('motion-btn')
const motionStatusSection = document.getElementById('motion-status-section')
const motionStatusText = document.getElementById('motion-status-text')
const photosSection = document.getElementById('photos-section')
const photosContainer = document.getElementById('photos-container')

// Cache to track the last three motion-detection photos
let motionPhotoCache = []

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
  photosContainer.innerHTML = '' // Clear previous photos
  photos.forEach((photoUrl) => {
    console.log('Photo URL:', photoUrl)
    const img = document.createElement('img')
    img.src = photoUrl
    img.alt = 'Photo'
    photosContainer.appendChild(img)
  })
  photosSection.classList.remove('hidden')
}

// Fetch and display photos
function fetchAndShowPhotos(folder = 'manual-capture-images') {
  fetch(
    `https://vw91j17z98.execute-api.us-west-1.amazonaws.com/dev/display-photos/${folder}`
  )
    .then((response) => response.json())
    .then((data) => {
      if (data.photos && Array.isArray(data.photos)) {
        if (folder === 'motion-detection-images') {
          checkForMotionUpdates(data.photos)
        } else {
          displayPhotos(data.photos)
        }
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
// Extracts the filename from the S3 presigned URL
function extractFilename(url) {
  const parts = url.split('/')
  return parts[parts.length - 1].split('?')[0] // Remove query parameters
}

// Check for new motion-detection photos
function checkForMotionUpdates(photos) {
  const newPhotoFilenames = photos.map(extractFilename)
  const cachedPhotoFilenames = motionPhotoCache.map(extractFilename)

  if (
    JSON.stringify(newPhotoFilenames) !== JSON.stringify(cachedPhotoFilenames)
  ) {
    motionPhotoCache = photos.slice(0, 3) // Store the latest 3 presigned URLs
    displayPhotos(motionPhotoCache) // Display new photos
    motionStatusText.textContent = 'Motion detected!'
  }
}

// Take photo
photoBtn.addEventListener('click', () => {
  fetch(
    'https://vw91j17z98.execute-api.us-west-1.amazonaws.com/dev/iot-message/take_picture',
    {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
    }
  )
    .then((response) => {
      if (response.ok) return response.json()
      else throw new Error('Failed to invoke take-photo endpoint')
    })
    .then((data) => {
      alert('Command sent to ESP32 to take a photo!')
      setTimeout(() => fetchAndShowPhotos(), 1000) // Fetch updated photos
    })
    .catch((error) => {
      console.error('Error invoking take-photo endpoint:', error)
      alert('Failed to send the take photo command. Please try again.')
    })
})

// Define variables to track the polling interval and timeout
let motionPollingInterval = null
let motionPollingTimeout = null

motionBtn.addEventListener('click', () => {
  // Clear any existing polling interval and timeout to ensure only one is running
  if (motionPollingInterval) {
    clearInterval(motionPollingInterval)
    motionPollingInterval = null
  }
  if (motionPollingTimeout) {
    clearTimeout(motionPollingTimeout)
    motionPollingTimeout = null
  }

  fetch(
    'https://vw91j17z98.execute-api.us-west-1.amazonaws.com/dev/iot-message/motion_detection',
    {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
    }
  )
    .then((response) => {
      if (response.ok) return response.json()
      else throw new Error('Failed to invoke motion-detection endpoint')
    })
    .then(() => {
      motionStatusText.textContent = 'Motion detection initializing...'
      motionStatusSection.classList.remove('hidden')

      // Wait 8 seconds for initialization
      setTimeout(() => {
        motionStatusText.textContent = 'Motion detection active.'

        // Start polling for new motion-detection photos every 3 seconds
        motionPollingInterval = setInterval(() => {
          fetchAndShowPhotos('motion-detection-images')
        }, 3000)

        // Set a timeout to stop polling after 2 minutes (120,000 ms)
        motionPollingTimeout = setTimeout(() => {
          clearInterval(motionPollingInterval)
          motionPollingInterval = null
          motionStatusText.textContent = 'Motion detection stopped.'
        }, 120000)
      }, 8000)
    })
    .catch((error) => {
      console.error('Error invoking motion-detection endpoint:', error)
      alert('Failed to start motion detection. Please try again.')
    })
})

// Display manual photos
displayBtn.addEventListener('click', () => fetchAndShowPhotos())
