# 💤 Insomnia Butler

**Your Intelligent AI Thought Partner for Racing Minds at 2 AM**

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Serverpod](https://img.shields.io/badge/Serverpod-3.0-blueviolet?style=for-the-badge)](https://serverpod.dev)
[![Gemini](https://img.shields.io/badge/Google_Gemini-8E75B2?style=for-the-badge&logo=google-gemini&logoColor=white)](https://deepmind.google/technologies/gemini/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-pgvector-336791?style=for-the-badge&logo=postgresql&logoColor=white)](https://www.postgresql.org/)

---

## 🌟 Executive Summary

**Insomnia Butler** is a premium, AI-powered companion designed to resolve the root cause of late-night wakefulness: a racing mind. Unlike traditional sleep apps that only offer passive sounds, the Butler engages in a structured, therapeutic dialogue to **organize your thoughts, provide cognitive reframing, and guide you into a restful state.**

By combining **Cognitive Behavioral Therapy (CBT-I) principles**, **Gemini Intelligence**, and **Long-term Vector Memory**, we create a personalized sanctuary that learns your patterns and helps you "park" your worries so you can finally rest.

---

## 💎 The "Deep Night" Experience

The application features a high-fidelity **Glassmorphic UI** designed for low-light environments.
- **Subtle Glows & Gradients:** A curated palette of Deep Navy, Sky Blue, and Lavender.
- **Micro-animations:** Smooth transitions and haptic feedback to reduce digital friction.
- **Adaptive Dashboard:** A dynamic home screen that shifts based on the time of day and your sleep readiness.

---

## 🚀 Key Features

### 🧠 AI Thought Clearing Engine (Core Feature)
A sophisticated chat interface powered by **Gemini** that acts as your personal cognitive coach.
- **Socratic Questioning:** Guides you to resolve worries rather than just venting.
- **Automatic Categorization:** Identifies if thoughts are related to Work, Social, Finances, or Health.
- **AI Actions:** The Butler can actively assist you by:
  - 🎵 **Playing Sleep Sounds** directly in the chat.
  - 📅 **Scheduling Reminders** for tomorrow so you can let go today.
  - 🚫 **Blocking Distracting Apps** on your device to prevent doom-scrolling.
  - 🧘 **Launching Breathing Exercises** when it detects high anxiety.
- **Context-Aware Memory:** Uses **Vector Embeddings (pgvector)** to remember your past worries and journals, providing continuity across sessions.

### 📊 Advanced Sleep Architecture Tracking
Go beyond simple "hours slept" with high-fidelity metrics:
- **Sleep Stages:** Visual breakdown of Deep, Light, REM, and Awake periods.
- **Physiological Recovery:** Track Resting Heart Rate (RHR), HRV, and Respiratory Rate.
- **Efficiency Scoring:** Dynamic calculation of your sleep quality and sleep consistency.
- **Interruptions Tracking:** Log and analyze wake-up events during the night.

### 🎵 Immersive Sleep Sounds & Ambience
A curated library of high-quality audio landscapes.
- **3D Glassmorphic Album Art:** Stunning visuals for every soundscape.
- **Pro Playback Controls:** Seamless seeking, background playback, and fade-out timers.
- **AI Suggested Audio:** The Butler suggests specific sounds based on your current mood.

### 🧘 Interactive Breathing Coach
An integrated breathing widget featuring:
- **Guided Visuals:** Expanding/contracting circles to pace your breath.
- **Customizable Cycles:** Inhale, Hold, and Exhale timings (e.g., Box Breathing).
- **Haptic Pacing:** Feel the rhythm of your breath without looking at the screen.

### 📅 Historical Intelligence & Analytics
### 📅 Historical Intelligence & Analytics
- **Monthly Calendar View:** Easily navigate through months of sleep and journal history.
- **Weekly Trend Reports:** See progress in sleep latency and consistency.
- **Mood Correlation:** Track how your morning mood correlates with your sleep architecture.

### 🚫 Smart Distraction Blocker
A robust nudging system that uses **High-Priority Notifications** to gently pull you away from blocked apps (Social Media, Games) during your scheduled bedtime.

### 💬 Session History & Context
- **Chat Archives:** Review past conversations and advice from the Butler.
- **Continuous Memory:** The AI remembers context from previous days to provide personalized support.

---

> **[📄 Click here to view the detailed Feature Breakdown per Screen (FEATURES.md)](FEATURES.md)**

---

## 💻 Tech Stack

| Layer | Technology |
| :--- | :--- |
| **Mobile App** | Flutter (Dart) with `flutter_animate` & `glass_kit` |
| **Backend** | Serverpod 3.0 (Dart) |
| **AI Intelligence** | Google Gemini |
| **Vector Search** | pgvector (PostgreSQL) for RAG |
| **Database** | PostgreSQL 18.1 |
| **Infrastructure** | AWS Fargate (ECS) + AWS RDS + ALB |

---

## ⚙️ Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Serverpod CLI](https://docs.serverpod.dev/getting-started/installing-serverpod)
- [Docker & Docker Compose](https://www.docker.com/get-started)
- Gemini API Key

### Setup

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/your-repo/insomniabutler.git
    cd insomniabutler
    ```

2.  **Configure Environment:**
    - Navigate to `insomniabutler_server/config/`
    - Update `passwords.yaml` with your `geminiApiKey` and database credentials.

3.  **Spin up Postgres with pgvector:**
    ```bash
    cd insomniabutler_server
    docker-compose up -d
    ```

4.  **Migrate & Run Server:**
    ```bash
    dart bin/main.dart --apply-migrations
    ```

5.  **Run Flutter App:**
    ```bash
    cd insomniabutler_flutter
    flutter run
    ```

---

## ☁️ Cloud Deployment (AWS)

Insomnia Butler is designed to scale on AWS using a fully automated pipeline:

1.  **Infrastructure Provisioning:**
    ```powershell
    .\deploy-aws-full.ps1 -GeminiApiKey "YOUR_KEY"
    ```
    *Creates ALB, ECS Services, RDS Instance, and ECR Repositories.*

2.  **Database Sync:**
    ```powershell
    .\run-migrations.ps1
    ```
    *Captures dynamic DNS and applies complex PostgreSQL migrations to RDS.*

---

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---
