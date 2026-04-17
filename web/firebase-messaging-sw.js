// Import Firebase scripts
importScripts('https://www.gstatic.com/firebasejs/9.6.11/firebase-app.js');
importScripts('https://www.gstatic.com/firebasejs/9.6.11/firebase-messaging.js');

// Initialize Firebase app in the service worker
firebase.initializeApp({
  apiKey: "AIzaSyA0bLUO4JMEyZ_QiekGIxc6jWBh8Imncng",
  authDomain: "allo-secours-ec8aa.firebaseapp.com",
  projectId: "allo-secours-ec8aa",
  storageBucket: "allo-secours-ec8aa.firebasestorage.app", // identique à firebase_options.dart
  messagingSenderId: "1063798739268", // identique à firebase_options.dart
  appId: "1:1063798739268:web:fb709f462737885b2e0711"
});

// Retrieve an instance of Firebase Messaging
const messaging = firebase.messaging();
