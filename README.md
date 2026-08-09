# 📊 Sublytics - Subscription & Expense Tracker - UIKit

## 📱 About the Project

**Sublytics** is a native iOS application built with **UIKit** designed to help users track, analyze, and manage recurring subscriptions and expense schedules efficiently.

## 🛠 Tech Stack

- Swift 6
- UIKit Framework
- MVVM Architecture + Protocol-Oriented Programming
- Concurrency
- Firebase Authentication
- Cloud Firestore
- Dependency Injection
- Local Persistence

## ✨ Features

- Total monthly/annual spend calculation and category percentage breakdown chart
- Forecasted monthly expenses, payment timeline, and top 3 highest costs
- Full real-time CRUD with filtering by status and category
- Automatic section for subscriptions renewing within 10 days
- Anonymous login on launch with optional Google Sign-In linking
- Profile management, sign-out, and account deletion
- Saved search history, onboarding flags, and session state

## 🧠 Architecture

## 🧠 Architecture

- **MVVM:** Clear decoupling of UIKit views, state, and business logic
- **Protocol-Driven:** Swappable Mock and Real service implementations
- **Modern Concurrency:** Swift `async/await` for async workflows
- **Real-Time Data & Auth:** Live Firestore and Firebase Auth state listeners
- **State Management:** In-memory Data Manager and local session caching
