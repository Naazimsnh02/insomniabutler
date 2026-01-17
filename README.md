# 💤 Insomnia Butler

**Your AI Thought Partner for Racing Minds at 2 AM**

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Serverpod](https://img.shields.io/badge/Serverpod-3.0-blueviolet?style=for-the-badge)](https://serverpod.dev)
[![Gemini](https://img.shields.io/badge/Google_Gemini-8E75B2?style=for-the-badge&logo=google-gemini&logoColor=white)](https://deepmind.google/technologies/gemini/)

---

## 🌟 Executive Summary

**Insomnia Butler** is a personalized AI companion designed to help you fall asleep when your mind won't shut off. Whether you're spiraling about tomorrow's presentation, yesterday's mistakes, or an endless to-do list, Insomnia Butler steps in to **organize your thoughts, calm your mind, and guide you to sleep.**

By combining **AI-powered thought processing**, **sleep pattern intelligence**, and **gentle accountability**, we clear your "mental RAM" so you can finally rest.

---

## 🌙 The Problem

It's 2:13 AM. You're exhausted but your brain won't stop:
- *"Did I lock the front door?"*
- *"That email I sent sounded passive-aggressive..."*
- *"I have 7 meetings tomorrow and haven't prepped."*

Traditional sleep apps offer sounds or stories, but they don't resolve the **underlying thoughts** keeping you awake. Those thoughts remain unresolved, circulating in your mind until they are properly addressed.

---

## 🛠️ The Solution: The Butler Experience

Insomnia Butler doesn't just track your sleep; it actively helps you achieve it through a structured dialogue:

1.  **Thought Capture:** Tell the Butler exactly what's on your mind.
2.  **AI Categorization:** Powered by Gemini, the Butler identifies if your worry is work-related, social anxiety, or a simple task.
3.  **Guided Intervention:**
    - **Reality Check:** "Can you fix this at 2 AM?"
    - **Reframing:** "You've handled this before."
    - **Action Capture:** Park the thought for tomorrow with an automated reminder.
4.  **Closure:** "The thought is parked. Your morning-self will handle it. It's safe to rest."
5.  **Sleep Readiness:** A visual meter shows your mental state improving as thoughts are resolved.

---

## 🏗️ System Architecture

Insomnia Butler is built on a robust, scalable architecture:

-   **Frontend (Flutter):** A beautiful, dark-themed mobile application providing a calming user experience.
-   **Backend (Serverpod 3.0):** An orchestration layer handling user sessions, analytics, and AI logic.
-   **Intelligence (Google Gemini):** A specialized LLM implementation trained in CBT-I (Cognitive Behavioral Therapy for Insomnia) principles.
-   **Database (PostgreSQL):** Storing sleep patterns, thought logs (anonymized/encrypted), and personalized insights.

---

## 🚀 Key Features

### 🧠 The Thought Clearing Engine
The star feature that guides you from a racing mind to sleep readiness. It uses Socratic questioning to help you "park" worries properly.

### 📊 Sleep Intelligence Dashboard
Don't just guess—know what works.
- **Impact Tracking:** See how much faster you fall asleep after a Butler session.
- **Pattern Detection:** Identify that you worry about work most on Sunday nights.
- **Sweet Spot:** Discover your optimal bed-time window.

### 🌅 Morning Reflection Loop
A quick check-in to correlate your 2 AM worries with your morning reality, helping train your brain to let go of late-night anxieties.

### 🚫 Gentle Distraction Blocking (Android)
Optional feature to nudge you away from doom-scrolling and toward sleep readiness.

---

## 💻 Tech Stack

| Layer | Technology |
| :--- | :--- |
| **Mobile App** | Flutter (Dart) |
| **Backend** | Serverpod 3.0 (Dart) |
| **AI Engine** | Google Gemini 1.5 Pro |
| **Database** | PostgreSQL |
| **Infrastructure** | Docker / Serverpod Cloud |

---

## ⚙️ Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Serverpod CLI](https://docs.serverpod.dev/getting-started/installing-serverpod)
- [Docker](https://www.docker.com/get-started)
- Gemini API Key

### Setup

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/your-repo/insomniabutler.git
    cd insomniabutler
    ```

2.  **Configure the Server:**
    - Navigate to `insomniabutler_server/config/`
    - Create/update `passwords.yaml` with your database and API keys.

3.  **Start the Database:**
    ```bash
    cd insomniabutler_server
    docker-compose up -d
    ```

4.  **Run the Server:**
    ```bash
    dart bin/main.dart --apply-migrations
    ```

5.  **Run the App:**
    ```bash
    cd ../insomniabutler_flutter
    flutter run
    ```

---

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Now go build something that helps people sleep. The world needs more rest. 💤**
