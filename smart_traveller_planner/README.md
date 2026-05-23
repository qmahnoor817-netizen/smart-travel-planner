# ✈️ Smart Travel Planner with Chat Feature

An all-in-one mobile application built with **Flutter** and **Firebase** that enables users to plan trips, explore destinations, manage itineraries, view real-time weather, and coordinate with travel partners through integrated group chats.

---

## 💡 Features

* **User Authentication**: Secure sign-up and login functionality powered by Firebase.


* **Trip Planning**: Create trips by defining destinations, dates, and personal notes.


* **Itinerary Management**: Manage daily plans with the ability to add, edit, or delete activities and places to visit.


* **Explore Places**: Search for cities and view attractions using third-party API integration.


* **Weather Information**: View weather forecasts for specific trip dates via API.


* **Group Chat**: Real-time messaging with trip members; one dedicated chat room per trip.


* **History & Archive**: View past trips and reuse previous plans.



---

## 🧠 Concepts & Tech Stack

* **Frontend**: Flutter (Dart)


* **Backend & Database**: Firebase (Authentication & Cloud Firestore)


* **API Integration**: REST APIs (OpenWeatherMap, GeoDB Cities, Foursquare)


* **Concepts**:
* Firebase real-time data synchronization


* Asynchronous programming (Future/Stream)


* State management for multi-user systems


* HTTP requests and JSON data handling





---

## 🚀 Getting Started

1. **Clone the repository**:
```bash
git clone <repository-url>

```



```

2.  **Setup Firebase**:
    - Create a new project in the [Firebase Console](https://console.firebase.google.com/).
    - Add your Android/iOS app to the project.
    - Download and place the `google-services.json` (Android) or `GoogleService-Info.plist` (iOS) in the correct directories.

3.  **Install dependencies**:
    ```bash
    flutter pub get

```

4. **Run the app**:
```bash

```



flutter run

```

---

## 📂 File Structure

```bash
📦Smart-Travel-Planner
 ┣ 📂 lib
 ┃ ┣ 📂 screens       # UI screens (Login, Home, Itinerary, Chat)
 ┃ ┣ 📂 services      # API and Firebase service classes
 ┃ ┣ 📂 models        # Data structures for Trips, Users, Messages
 ┃ ┗ 📄 main.dart     # Entry point
 ┣ 📄 pubspec.yaml    # Project dependencies
 ┗ 📄 README.md

```

---

## 🛠️ API Options Used

* **Weather**: OpenWeatherMap API


* **Cities**: GeoDB Cities API


* **Places**: Foursquare Places API



## 📝 Learning Outcomes

* Gain hands-on experience with **Firebase real-time features**.


* Learn to integrate **external APIs** into mobile applications.


* Build a functional **multi-user system** for collaborative planning.



## 📄 License

MIT — Feel free to use and modify for your portfolio!

---

*Made with ❤️ by Ayman & Mahnoor*