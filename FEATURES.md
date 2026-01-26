# 📱 Insomnia Butler - Feature & Tech Breakdown

This document provides a comprehensive breakdown of features by screen, highlighting the **Serverpod** and **Gemini** technologies powering each experience.

---

## 🚀 Intelligent Onboarding
*A cinematic introduction that validates the user's struggle and builds trust before they even sign up.*

### **1. Narrative Flow**
- **Emotional Validation**: Screens ("It's 2 AM", "Tired of trying?") that speak directly to the user's pain point.
- **Interactive Demo**: A "Try me" chat experience where the user interacts with a simulated Butler to see the Cognitive Reframing value immediately.
- **Permission Prime**: Contextual requests for Notification permissions, explaining *why* they are needed (for gentle nudges) before asking.

### **⚡ Serverpod Power**
- **User Creation**: `auth.createAccount` - Securely creates the user profile with hashed credentials.
- **Initial Setup**: `user.setupProfile` - Initializes default settings and health baselines on the PostgreSQL database.

---

## 🏠 Home Dashboard
*The central command center, dynamically adapting to the time of day.*

### **1. Daily Context & Affirmations**
- **Time-Aware Greeting**: "Good Morning" / "Good Evening" based on server time.
- **Dynamic Affirmations**: Fetched daily to provide novel motivation.
- **Sleep Readiness Score**: Visual metric synthesized from previous night's data.

### **2. Advanced Sleep Architecture**
- **Sleep Staging Graphs**: Visualizes Deep, Light, REM, and Awake periods.
- **Biometrics Display**: Resting Heart Rate (RHR), HRV, and Respiratory Rate.
- **Sleep Consistency**: Smart algorithm that compares bedtime/wake-time variance over the last 7 days.

### **3. Calendar & Trends**
- **7-Day Strip**: Swipeable weekly view.
- **Monthly Calendar**: Full historical view of sleep performance.
- **Trend Analysis**: Visual graphs showing improvement in "Sleep Latency" (time to fall asleep).

### **⚡ Serverpod Power**
- **`insights.getUserInsights`**: Aggregates huge datasets to return calculated metrics (Latency improvement, Avg Sleep) in a single optimized call.
- **`insights.getSleepTrend`**: Returns time-series data for graphing.
- **`sleepSession.getSessionForDate`**: Fetches granular session details for any selected historical date.

---

## 🤵 Insomnia Butler (Chat)
*The Core Feature: An AI-powered Cognitive Behavioral Therapy (CBT-I) companion.*

### **1. Thought Clearing Engine**
- **Therapeutic Dialogue**: Uses **Gemini** to guide users through Socratic questioning, reframing worries instead of just listening.
- **Automatic Categorization**: Detects if a thought is about *Work, Health, Finance, etc.*
- **Readiness Meter**: Real-time gauge that fills up as the user "parks" their thoughts.

### **2. Vector-Based Memory (RAG)**
- **Context Awareness**: The Butler remembers what you worried about yesterday or last week.
- **Semantic Search**: Uses **pgvector** to find relevant past advice or recurring anxiety themes.

### **3. AI Agent Actions**
The AI isn't just a chatbot; it controls the app:
- **`play_sound`**: Can start a rain soundscape automatically if the user says they need relaxing noise.
- **`set_reminder`**: Schedules system notifications for tasks so the user can let go of the mental load.
- **`block_app`**: Can add apps to the distraction blocklist via natural language commands.

### **⚡ Serverpod Power**
- **`thoughtClearing.processThought`**: The brain. Orchestrates:
  1.  Sending text to **Gemini**.
  2.  Generating embeddings for the text using **Gemini Embeddings**.
  3.  Storing embeddings in **PostgreSQL (pgvector)**.
  4.  Retrieving relevant past context via vector similarity search.
- **`thoughtClearing.getChatSessionMessages`**: Retrieves chat history.

---

## 🎵 Sounds Sanctuary
*High-fidelity audio for masking environmental noise.*

### **1. Curated Library**
- **Categories**: Nature, Melodic, White Noise, ASMR.
- **Favorites**: User-curated list of go-to sounds.
- **Glassmorphic Player**: Mini-player and full-screen controls with album art.

### **2. Smart Playback**
- **Sleep Timer**: Server-synced logic to fade out audio (15m, 30m, 1h).
- **Background Audio**: Continues playing even when the phone is locked.

### **⚡ Serverpod Power**
- **`sound.getAllSounds`**: Efficiently serves sound metadata and URLs.
- **`user.syncFavorites`**: Persists user's favorite sounds across devices.

---

## 📓 Sleep Journal
*Structured reflection for long-term pattern recognition.*

### **1. Timeline & Calendar**
- **Rich Entries**: cards showing Date, Time, Mood Emoji, and text preview.
- **Mood Tracking**: Visual log of morning mood (Angry, Happy, Groggy).

### **2. AI Insights**
- **Pattern Recognition**: "You tend to sleep 30 mins less on days you report Work Anxiety."

### **⚡ Serverpod Power**
- **`journal.getUserEntries`**: Paginated retrieval of journal history.
- **`journal.getJournalStats`**: Calculates total entries, streaks, and word counts server-side.
- **`journal.getJournalInsights`**: Periodic AI job that analyzes journal text to find correlations with sleep quality.

---

## 🚫 Distraction Blocker
*Hardware-level intervention for bedtime doom-scrolling.*

### **1. App Management**
- **Blocklist**: Select apps (TikTok, Instagram) to restrict.
- **Bedtime Window**: Define "No Entry" zones (e.g., 11 PM - 7 AM).

### **2. High-Priority Nudges**
- **Intervention**: If a blocked app is opened during bedtime, the Butler sends a high-priority notification to snap the user out of the loop.

### **⚡ Serverpod Power**
- **`auth.getUserStats`**: Tracks how many times the user successfully avoided distractions (used for gamification/streaks).
- **(Planned) Server-Side Rules**: Syncing blocklists to prevent uninstalling/bypassing on other devices.
