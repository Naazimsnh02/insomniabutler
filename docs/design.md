# 🎨 Insomnia Butler - Design System

**A Glassmorphic Night-Time Companion**

---

## Table of Contents
1. [Design Philosophy](#design-philosophy)
2. [Color System](#color-system)
3. [Typography](#typography)
4. [Glassmorphic Components](#glassmorphic-components)
5. [Spacing & Layout](#spacing--layout)
6. [UI Screens & Flow](#ui-screens--flow)
7. [Onboarding Content](#onboarding-content)
8. [Image Generation Prompts](#image-generation-prompts)
9. [Animations & Interactions](#animations--interactions)

---

## Design Philosophy

**Core Principles:**
- 🌙 **Night-First Design** - Easy on the eyes at 2 AM
- 💎 **Glassmorphic Depth** - Layers that feel touchable and premium
- 🎭 **Emotional Resonance** - Calming, not clinical
- ✨ **Subtle Magic** - Micro-interactions that delight without distracting
- 🧘 **Breathing Space** - Never cluttered, always calm

**Visual Metaphor:** A serene night sky with soft glowing elements - like looking through frosted glass at distant stars.

---

## Color System

### Primary Palette

```css
/* Background Gradients */
--bg-primary: linear-gradient(180deg, #0A0E27 0%, #1A1E3E 100%);
--bg-secondary: linear-gradient(135deg, #1E2347 0%, #2A1E4F 100%);
--bg-card: linear-gradient(135deg, rgba(42, 30, 79, 0.6) 0%, rgba(30, 35, 71, 0.4) 100%);

/* Accent Colors */
--accent-primary: #A78BFA;      /* Soft Purple */
--accent-secondary: #C084FC;    /* Vibrant Purple */
--accent-tertiary: #60A5FA;     /* Sky Blue */
--accent-success: #34D399;      /* Mint Green */
--accent-warning: #FBBF24;      /* Warm Gold */

/* Glass Effects */
--glass-bg: rgba(255, 255, 255, 0.08);
--glass-border: rgba(255, 255, 255, 0.12);
--glass-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
--glass-blur: blur(16px);

/* Text Colors */
--text-primary: rgba(255, 255, 255, 0.95);
--text-secondary: rgba(255, 255, 255, 0.65);
--text-tertiary: rgba(255, 255, 255, 0.45);
--text-disabled: rgba(255, 255, 255, 0.25);

/* Semantic Colors */
--sleep-ready-low: #EF4444;     /* Red */
--sleep-ready-mid: #FBBF24;     /* Gold */
--sleep-ready-high: #34D399;    /* Green */
```

### Gradient System

```css
/* Hero Gradients */
--gradient-hero: linear-gradient(135deg, #667EEA 0%, #764BA2 50%, #F093FB 100%);
--gradient-thought: linear-gradient(135deg, #A78BFA 0%, #EC4899 100%);
--gradient-calm: linear-gradient(135deg, #6366F1 0%, #8B5CF6 100%);
--gradient-success: linear-gradient(135deg, #10B981 0%, #3B82F6 100%);

/* Shimmer Effect */
--gradient-shimmer: linear-gradient(90deg, 
  rgba(255,255,255,0) 0%, 
  rgba(255,255,255,0.1) 50%, 
  rgba(255,255,255,0) 100%);
```

---

## Typography

### Font Stack

```css
--font-primary: 'Manrope', -apple-system, BlinkMacSystemFont, sans-serif;
--font-display: 'Clash Display', 'Manrope', sans-serif;
--font-mono: 'JetBrains Mono', monospace;
```

### Type Scale

```css
/* Display */
--text-display-xl: 56px / 64px, weight: 700, letter-spacing: -0.02em;
--text-display-lg: 48px / 56px, weight: 700, letter-spacing: -0.02em;
--text-display-md: 40px / 48px, weight: 600, letter-spacing: -0.01em;

/* Headings */
--text-h1: 32px / 40px, weight: 600, letter-spacing: -0.01em;
--text-h2: 28px / 36px, weight: 600, letter-spacing: -0.01em;
--text-h3: 24px / 32px, weight: 600;
--text-h4: 20px / 28px, weight: 600;

/* Body */
--text-body-lg: 18px / 28px, weight: 400;
--text-body: 16px / 24px, weight: 400;
--text-body-sm: 14px / 20px, weight: 400;

/* Labels */
--text-label-lg: 14px / 20px, weight: 500;
--text-label: 12px / 16px, weight: 500;
--text-caption: 11px / 16px, weight: 500;
```

---

## Glassmorphic Components

### Glass Card (Base Component)

```css
.glass-card {
  background: var(--glass-bg);
  border: 1px solid var(--glass-border);
  border-radius: 24px;
  backdrop-filter: blur(16px);
  box-shadow: var(--glass-shadow);
  padding: 24px;
}

.glass-card-elevated {
  background: rgba(255, 255, 255, 0.12);
  box-shadow: 
    0 8px 32px rgba(0, 0, 0, 0.3),
    inset 0 1px 0 rgba(255, 255, 255, 0.1);
}
```

### Button Variants

```css
/* Primary Button */
.btn-primary {
  background: linear-gradient(135deg, #A78BFA 0%, #C084FC 100%);
  border-radius: 16px;
  padding: 16px 32px;
  font-weight: 600;
  box-shadow: 0 4px 24px rgba(167, 139, 250, 0.4);
}

/* Glass Button */
.btn-glass {
  background: rgba(255, 255, 255, 0.08);
  border: 1px solid rgba(255, 255, 255, 0.12);
  backdrop-filter: blur(8px);
  border-radius: 16px;
  padding: 16px 32px;
}

/* Icon Button */
.btn-icon {
  width: 48px;
  height: 48px;
  border-radius: 12px;
  background: rgba(255, 255, 255, 0.08);
  backdrop-filter: blur(8px);
}
```

### Progress Indicators

```css
/* Sleep Readiness Circle */
.sleep-meter {
  width: 200px;
  height: 200px;
  border-radius: 50%;
  background: conic-gradient(
    from 180deg,
    var(--sleep-ready-low) 0%,
    var(--sleep-ready-mid) 50%,
    var(--sleep-ready-high) 100%
  );
  padding: 8px;
  position: relative;
}

.sleep-meter-inner {
  width: 100%;
  height: 100%;
  border-radius: 50%;
  background: var(--bg-primary);
  display: flex;
  align-items: center;
  justify-content: center;
}
```

### Chat Bubble

```css
/* User Message */
.chat-bubble-user {
  background: linear-gradient(135deg, #A78BFA 0%, #C084FC 100%);
  border-radius: 20px 20px 4px 20px;
  padding: 14px 18px;
  max-width: 80%;
  align-self: flex-end;
}

/* AI Message */
.chat-bubble-ai {
  background: rgba(255, 255, 255, 0.08);
  border: 1px solid rgba(255, 255, 255, 0.12);
  backdrop-filter: blur(16px);
  border-radius: 4px 20px 20px 20px;
  padding: 14px 18px;
  max-width: 80%;
}
```

---

## Spacing & Layout

### Spacing Scale

```css
--space-xs: 4px;
--space-sm: 8px;
--space-md: 16px;
--space-lg: 24px;
--space-xl: 32px;
--space-2xl: 48px;
--space-3xl: 64px;
```

### Layout Grid

```css
--container-padding: 20px;
--section-spacing: 32px;
--card-gap: 16px;
--max-width: 440px; /* Mobile-first */
```

---

## UI Screens & Flow

### Screen Architecture

```
App Flow:
├── Onboarding (First Launch)
│   ├── Splash
│   ├── Welcome
│   ├── Problem Statement
│   ├── Solution Preview
│   ├── Permissions Request
│   └── Account Setup
│
├── Main App
│   ├── Home Dashboard
│   ├── Thought Clearing (Core Feature)
│   ├── Sleep Log
│   ├── Insights
│   └── Settings
│
└── Sleep Session Flow
    ├── Pre-Sleep Ritual
    ├── Thought Processing
    ├── Sleep Mode Active
    └── Morning Reflection
```

---

## Detailed Screen Specifications

### 1. Splash Screen

**Visual:**
- Full-screen gradient background
- Centered logo with subtle pulse animation
- App name "Insomnia Butler" fades in below
- Tagline: "Your AI Thought Partner" appears

```
Layout:
┌─────────────────────────┐
│                         │
│         [Logo]          │ ← Glassmorphic circle with moon icon
│                         │
│    Insomnia Butler      │ ← Gradient text
│  Your AI Thought Partner│ ← Subtle fade
│                         │
└─────────────────────────┘

Colors:
- Background: var(--bg-primary)
- Logo: Glass circle with soft glow
- Text: White with gradient shimmer
```

---

### 2. Onboarding Screen 1 - Welcome

**Content:**
```
[Animated Illustration: Person lying in bed, thought bubbles floating]

It's 2 AM

Your mind is racing.
Your body is exhausted.
But sleep won't come.

[CTA Button: "I know this feeling"]
```

**Visual Details:**
- Hero illustration at top 40% of screen
- Text centered with breathing animation
- Glass card container for text
- Purple gradient CTA button

---

### 3. Onboarding Screen 2 - The Problem

**Content:**
```
[Animated Illustration: Thought bubbles multiplying, clock ticking]

You've tried everything

☁️  Counting sheep
🎵  Sleep sounds
😮‍💨  Breathing exercises
📱  Closing your eyes harder

But the thoughts are still there,
unresolved, demanding attention.

[CTA Button: "There's a better way"]
```

**Visual Details:**
- Swipeable card layout
- Icons animate in sequence
- Glassmorphic checkmarks appear crossed out

---

### 4. Onboarding Screen 3 - The Solution

**Content:**
```
[Animated Illustration: AI butler organizing floating thoughts into neat boxes]

Meet Your Butler

Insomnia Butler doesn't just distract you.
It actively clears your mental clutter.

✨ Categorizes anxious thoughts
🧘 Guides cognitive reframing  
📝 Parks worries for tomorrow
💤 Helps you actually rest

[CTA Button: "Show me how"]
```

**Visual Details:**
- Lottie animation of thought organization
- Feature list with animated icons
- Progress dots at bottom

---

### 5. Onboarding Screen 4 - Demo Preview

**Content:**
```
[Interactive Demo]

Try it now

Type a worry you have right now:
[Input field: "I'm worried about..."]

[Simulated AI Response appears]
"Let's work through this together.
First - can you solve this at 2 AM?"

[Two buttons: "No" | "Yes, but..."]

[Based on answer, show closure]
"Then this is a thought for morning-you.
Let's park it properly."

Sleep Readiness: 45% → 75% ✓

[CTA Button: "I want this"]
```

**Visual Details:**
- Real-time typing simulation
- Sleep meter animates up
- Glass chat bubbles
- Haptic feedback on interactions

---

### 6. Onboarding Screen 5 - Permissions

**Content:**
```
[Icon: Shield with checkmark]

We respect your privacy

To help you sleep better, we need:

📊 Sleep tracking
   → Measure when Butler helps most

🔔 Notifications
   → Gentle reminders for sleep window

🔒 Optional: App blocking
   → Keep distractions away

Your thoughts are encrypted.
You control all data.

[CTA Button: "Grant permissions"]
[Link: "Skip for now"]
```

**Visual Details:**
- Permission cards slide in
- Toggle switches for each
- Privacy badge at bottom

---

### 7. Onboarding Screen 6 - Account Setup

**Content:**
```
[Avatar Selector]

Almost there

Choose your sleep goal:
⏰ Fall asleep faster
💤 Sleep through the night
🌅 Wake up refreshed
📈 All of the above

What time do you usually go to bed?
[Time Picker: 10:00 PM - 2:00 AM]

[CTA Button: "Start sleeping better"]
```

**Visual Details:**
- Glassmorphic cards for goals
- Multi-select with glow effect
- Circular time picker with gradient

---

### 8. Home Dashboard

**Layout:**
```
┌────────────────────────────────┐
│  [Header]                      │
│  Good Evening, Alex            │
│  Ready for bed in 2h 15m       │
│                                │
│  ┌─────────────────────────┐  │
│  │  [Tonight Card]         │  │ ← Glassmorphic hero card
│  │  Sleep Window           │  │
│  │  11:00 PM - 7:00 AM     │  │
│  │                         │  │
│  │  [Start Wind-Down] CTA  │  │
│  └─────────────────────────┘  │
│                                │
│  ┌─────────────────────────┐  │
│  │  Quick Actions          │  │
│  │  [🧘 Clear Thoughts]    │  │
│  │  [📊 Last Night]        │  │
│  │  [📈 Weekly Insights]   │  │
│  └─────────────────────────┘  │
│                                │
│  ┌─────────────────────────┐  │
│  │  Your Impact            │  │
│  │  🔥 5 Day Streak        │  │
│  │  📉 35% Faster Sleep    │  │
│  └─────────────────────────┘  │
│                                │
│  [Bottom Nav]                  │
│  🏠 Home | 💬 Butler | 📊 Stats│
└────────────────────────────────┘
```

**Visual Details:**
- Animated gradient background
- Cards have parallax scroll effect
- Streak counter pulses
- Bottom nav with glassmorphic background

---

### 9. Thought Clearing Screen (CORE FEATURE)

**Layout:**
```
┌────────────────────────────────┐
│  [Header]                      │
│  ← Back    Sleep Ready: 45%    │
│                                │
│  [Chat Container]              │
│  ┌─────────────────────────┐  │
│  │ AI: What's on your mind?│  │ ← Glass bubble
│  │     tonight?            │  │
│  └─────────────────────────┘  │
│                                │
│      ┌───────────────────┐    │
│      │ User: I'm worried │    │ ← Gradient bubble
│      │ about tomorrow's  │    │
│      │ presentation      │    │
│      └───────────────────┘    │
│                                │
│  ┌─────────────────────────┐  │
│  │ AI: I hear you. Let's   │  │
│  │ work through this.      │  │
│  │                         │  │
│  │ Can you do anything     │  │
│  │ about it right now?     │  │
│  │                         │  │
│  │ [No] [Yes, but...]      │  │ ← Pill buttons
│  └─────────────────────────┘  │
│                                │
│  ┌─────────────────────────┐  │
│  │ [Thought Category]      │  │ ← Badge
│  │ 💼 Performance Anxiety  │  │
│  └─────────────────────────┘  │
│                                │
│  [Input Field]                 │
│  Type your thoughts...  [Send] │
│                                │
│  [Sleep Readiness Meter]       │
│  ████████░░ 75%                │ ← Animated gradient bar
└────────────────────────────────┘
```

**Interaction States:**
1. AI typing indicator: Pulsing dots
2. Message sent: Fade in animation
3. Readiness increase: Number count-up animation
4. Closure reached: Confetti micro-animation

---

### 10. Sleep Log Screen

**Layout:**
```
┌────────────────────────────────┐
│  [Header]                      │
│  Last Night                    │
│  Wed, Jan 17                   │
│                                │
│  ┌─────────────────────────┐  │
│  │   [Sleep Quality]       │  │
│  │        ⭐⭐⭐⭐⭐        │  │
│  │     Very good!          │  │
│  └─────────────────────────┘  │
│                                │
│  ┌─────────────────────────┐  │
│  │   [Sleep Duration]      │  │
│  │                         │  │
│  │     [Clock Visual]      │  │ ← Glassmorphic circular chart
│  │        7h 32m           │  │
│  │                         │  │
│  │   🛏️  11:15 PM          │  │
│  │   ⏰  6:47 AM           │  │
│  └─────────────────────────┘  │
│                                │
│  ┌─────────────────────────┐  │
│  │   Time to Sleep         │  │
│  │   ⏱️  12 minutes         │  │
│  │   📉 35% faster         │  │ ← Success metric
│  └─────────────────────────┘  │
│                                │
│  ┌─────────────────────────┐  │
│  │   Butler Sessions       │  │
│  │   💬 1 session          │  │
│  │   🧘 3 thoughts cleared │  │
│  └─────────────────────────┘  │
│                                │
│  [Edit Log] [Morning Notes]    │
└────────────────────────────────┘
```

---

### 11. Insights Dashboard

**Layout:**
```
┌────────────────────────────────┐
│  [Header]                      │
│  Your Sleep Intelligence       │
│  [Week Filter: ◄ Jan 10-16 ►]  │
│                                │
│  ┌─────────────────────────┐  │
│  │  This Week's Impact     │  │
│  │  ╔═══════════════════╗  │  │
│  │  ║ You fall asleep   ║  │  │
│  │  ║   35% faster      ║  │  │ ← Hero stat
│  │  ║ after Butler      ║  │  │
│  │  ║   sessions        ║  │  │
│  │  ╚═══════════════════╝  │  │
│  │                         │  │
│  │  With Butler: 12 min    │  │
│  │  Without: 28 min        │  │
│  └─────────────────────────┘  │
│                                │
│  ┌─────────────────────────┐  │
│  │  Thought Patterns       │  │
│  │  [Donut Chart]          │  │ ← Glassmorphic chart
│  │                         │  │
│  │  💼 Work (48%)          │  │
│  │  👥 Social (31%)        │  │
│  │  📅 Planning (21%)      │  │
│  └─────────────────────────┘  │
│                                │
│  ┌─────────────────────────┐  │
│  │  💡 Insights            │  │
│  │                         │  │
│  │  You sleep best when    │  │
│  │  you process work       │  │
│  │  thoughts before 11 PM  │  │
│  │                         │  │
│  │  [Try This Schedule]    │  │
│  └─────────────────────────┘  │
│                                │
│  ┌─────────────────────────┐  │
│  │  Sleep Trend            │  │
│  │  [Line Graph - 7 days]  │  │ ← Gradient area chart
│  │  ⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯⎯  │  │
│  │   M  T  W  T  F  S  S   │  │
│  └─────────────────────────┘  │
└────────────────────────────────┘
```

---

### 12. Settings Screen

**Layout:**
```
┌────────────────────────────────┐
│  [Header]                      │
│  Settings                      │
│                                │
│  👤 Profile                    │
│  ┌─────────────────────────┐  │
│  │  Alex Thompson          │  │
│  │  alex@email.com         │  │
│  │  [Edit Profile]         │  │
│  └─────────────────────────┘  │
│                                │
│  ⏰ Sleep Schedule             │
│  ┌─────────────────────────┐  │
│  │  Bedtime: 11:00 PM      │  │
│  │  Wake: 7:00 AM          │  │
│  │  [Adjust Times]         │  │
│  └─────────────────────────┘  │
│                                │
│  🔔 Notifications              │
│  ┌─────────────────────────┐  │
│  │  Wind-down reminder     │✓ │
│  │  Morning check-in       │✓ │
│  │  Weekly insights        │✓ │
│  └─────────────────────────┘  │
│                                │
│  🔒 Privacy                    │
│  ┌─────────────────────────┐  │
│  │  Data & Security        │→ │
│  │  Export my data         │→ │
│  │  Delete account         │→ │
│  └─────────────────────────┘  │
│                                │
│  🎨 Appearance                 │
│  ┌─────────────────────────┐  │
│  │  Theme: Night (locked)  │🌙│
│  │  Glassmorphism  [████] │  │ ← Intensity slider
│  └─────────────────────────┘  │
└────────────────────────────────┘
```

---

## Onboarding Content (Complete Text)

### Screen 1: Splash
```
[Logo animation]
Insomnia Butler
Your AI Thought Partner
```

### Screen 2: Welcome
```
It's 2 AM

Your mind is racing.
Your body is exhausted.
But sleep won't come.

[Button: "I know this feeling"]
```

### Screen 3: The Problem
```
You've tried everything

☁️  Counting sheep
🎵  Sleep sounds  
😮‍💨  Breathing exercises
📱  Closing your eyes harder

But the thoughts are still there,
unresolved, demanding attention.

[Button: "There's a better way"]
```

### Screen 4: The Solution
```
Meet Your Butler

Insomnia Butler doesn't just distract you.
It actively clears your mental clutter.

✨ Categorizes anxious thoughts
🧘 Guides cognitive reframing
📝 Parks worries for tomorrow
💤 Helps you actually rest

[Button: "Show me how"]
```

### Screen 5: Interactive Demo
```
Try it now

What's worrying you tonight?

[Input field]

[After user types]

AI Butler:
"Let's work through this together.

First - can you do anything about 
this right now, at 2 AM?"

[Buttons: "No" | "Yes, but..."]

[After selection]

"Exactly. Your 2 AM brain is trying 
to solve a problem your morning-self 
is much better equipped to handle.

Let's park this thought properly."

Sleep Readiness: 45% → 75% ✓

[Button: "I want this"]
```

### Screen 6: Privacy & Permissions
```
We respect your privacy

To help you sleep better, we need:

📊 Sleep tracking
   Measure when Butler helps most

🔔 Notifications
   Gentle reminders for sleep window

🔒 Optional: App blocking
   Keep distractions away

Your thoughts are encrypted.
You control all data.
No ads. Ever.

[Button: "Grant permissions"]
[Link: "Skip for now"]
```

### Screen 7: Personalization
```
Almost there

Choose your sleep goal:

⏰ Fall asleep faster
💤 Sleep through the night
🌅 Wake up refreshed
📈 All of the above

What time do you usually go to bed?

[Time Picker]

[Button: "Start sleeping better"]
```

### Screen 8: Ready to Begin
```
[Success animation]

Your Butler is ready

We'll start learning your patterns tonight.

Remember: Your thoughts at 2 AM 
don't define you. They're just thoughts.

And now you have help clearing them.

[Button: "Take me to my dashboard"]
```

---

## Image Generation Prompts

### 1. App Logo / Icon

**Prompt:**
```
A minimalist app icon featuring a butler's silhouette (top hat and bow tie) combined with a crescent moon, rendered in a glassmorphic style with soft purple and blue gradients, transparent frosted glass effect, subtle glow, clean lines, modern, premium feel, centered composition, dark background, suitable for iOS/Android app icon
```

**Alternative Logo Prompt:**
```
Abstract representation of a peaceful mind: circular glassmorphic orb with organized geometric thought bubbles inside, purple to pink gradient, soft glow, frosted glass texture, depth layers, clean and modern, app icon style
```

---

### 2. Onboarding - Screen 1 Illustration

**Prompt:**
```
A person lying in bed at night, peaceful bedroom scene, thought bubbles floating above their head in various sizes, glassmorphic style, purple and blue gradient color palette, soft ambient lighting from moon through window, gentle and calming atmosphere, digital illustration, minimalist, modern UI style, dreamy quality
```

---

### 3. Onboarding - Screen 2 Illustration

**Prompt:**
```
Overwhelmed person in bed with many chaotic thought bubbles multiplying around their head, clock showing 2 AM glowing in background, restless energy, glassmorphic bubbles with blur effect, purple and pink gradients, modern illustration style, conveys anxiety but beautiful aesthetic, UI illustration
```

---

### 4. Onboarding - Screen 3 Illustration

**Prompt:**
```
An elegant AI butler character (abstract, friendly) organizing floating thought bubbles into neat, organized stacks or filing them away, glassmorphic elements, purple and blue gradient, magical sparkles, calm and orderly atmosphere, modern digital illustration, premium UI style, shows transformation from chaos to calm
```

---

### 5. Dashboard Hero Background

**Prompt:**
```
Serene night sky gradient background, deep purple to blue, subtle stars, soft clouds, peaceful atmosphere, glassmorphic overlay texture, dreamy quality, mobile app background, vertical composition, calming and premium feel
```

---

### 6. Thought Category Icons (Generate each)

**Work/Career Icon Prompt:**
```
Glassmorphic icon of a briefcase or laptop, purple gradient, soft glow, transparent frosted glass effect, minimalist design, rounded corners, suitable for mobile app UI, 512x512px
```

**Relationship Icon Prompt:**
```
Glassmorphic icon of two abstract human silhouettes or heart shape, blue-purple gradient, soft glow, transparent effect, minimalist modern style, app icon
```

**Health/Anxiety Icon Prompt:**
```
Glassmorphic icon of a lotus flower or peaceful meditation symbol, calming blue-green gradient, soft transparency, modern minimalist app icon style
```

**Future Planning Icon Prompt:**
```
Glassmorphic icon of a calendar or checklist, purple gradient, transparent frosted glass, soft glow, clean modern design for mobile app
```

---

### 7. Sleep Readiness Meter Background

**Prompt:**
```
Circular gradient from red (bottom) through yellow (middle) to green (top), smooth color transitions, glassmorphic overlay, soft glow, suitable for progress meter background, modern UI design
```

---

### 8. Success/Completion Illustration

**Prompt:**
```
Peaceful person sleeping contentedly in bed, gentle smile, organized thought bubbles neatly filed away or dissolving into soft sparkles, calming night scene, moon visible, glassmorphic style, purple and blue gradients, dreamy peaceful atmosphere, modern illustration for mobile app
```

---

### 9. Empty State Illustrations

**No Thoughts Yet Prompt:**
```
A clean, organized glass jar or filing cabinet that's empty but beautiful, waiting to be filled, glassmorphic style, purple gradient, soft glow, minimalist, friendly and inviting feeling, modern app illustration
```

**No Sleep Data Prompt:**
```
A peaceful bedroom at night with an empty bed waiting, soft moonlight, glassmorphic window, purple and blue tones, calm invitation to begin journey, modern UI illustration style
```

---

### 10. Premium Feature Teasers

**App Blocking Illustration Prompt:**
```
A smartphone wrapped in a gentle glassmorphic shield or protective bubble, distraction app icons bouncing off peacefully, purple gradient, soft and non-aggressive style, modern app illustration
```

**Insights Dashboard Illustration Prompt:**
```
Abstract data visualization with glassmorphic charts, graphs floating in space, purple and blue gradients, magical sparkles, shows intelligence and pattern recognition, modern premium UI illustration
```

---

## Animations & Interactions

### Micro-interactions

```javascript
// Button Press
{
  scale: 0.95,
  duration: 100ms,
  easing: 'ease-out'
}

// Card Hover (Desktop)/Long Press
{
  scale: 1.02,
  shadow: '0 12px 48px rgba(0,0,0,0.4)',
  duration: 200ms,
  easing: 'ease-in-out'
}

// Sleep Readiness Increase
{
  countUp: true,
  duration: 800ms,
  haptic: 'light',
  celebrate: confetti(if >75%)
}

// Message Sent
{
  fadeIn: true,
  slideUp: 10px,
  duration: 300ms,
  easing: 'ease-out'
}

// AI Typing Indicator
{
  dots: [...],
  bounce: sequential,
  duration: 1200ms,
  loop: true
}
```

### Page Transitions

```javascript
// Screen Transitions
{
  type: 'slide',
  direction: 'left',
  duration: 300ms,
  easing: 'cubic-bezier(0.4, 0, 0.2, 1)'
}

// Modal Appear
{
  fadeIn: true,
  scaleFrom: 0.9,
  duration: 250ms,
  backdrop: blur(8px)
}

// Bottom Sheet
{
  slideUp: true,
  duration: 350ms,
  easing: 'ease-out',
  spring: subtle
}
```

### Loading States

```javascript
// Shimmer Effect
{
  gradient: var(--gradient-shimmer),
  animation: slideX,
  duration: 1500ms,
  loop: infinite
}

// Skeleton Screens
{
  background: rgba(255,255,255,0.05),
  pulse: subtle,
  borderRadius: inherit
}
```

---

## Component Library

### GlassCard Component

```dart
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: elevated 
            ? [Color(0x1FFFFFFF), Color(0x0AFFFFFF)]
            : [Color(0x14FFFFFF), Color(0x0AFFFFFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(borderRadius ?? 24),
        border: Border.all(
          color: Color(0x1FFFFFFF),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x4D000000),
            blurRadius: 32,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: child,
      ),
    );
  }
}
```

### SleepReadinessMeter Component

```dart
class SleepReadinessMeter extends StatefulWidget {
  final int percentage; // 0-100

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      child: CustomPaint(
        painter: ReadinessPainter(percentage),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$percentage%',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  foreground: Paint()
                    ..shader = LinearGradient(
                      colors: [Color(0xFFA78BFA), Color(0xFFC084FC)],
                    ).createShader(Rect.fromLTWH(0, 0, 200, 100)),
                ),
              ),
              Text(
                'Sleep Ready',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## Accessibility Considerations

```yaml
Accessibility Features:
  - Font scaling: Support 100%-200%
  - Color contrast: WCAG AA minimum
  - Screen reader labels: All interactive elements
  - Haptic feedback: Confirm important actions
  - Reduced motion: Respect system preferences
  - Large touch targets: Minimum 44x44pt
  - Focus indicators: Clear visual states
```

---

## Implementation Checklist

### Phase 1: Foundation (Day 1)
- [ ] Set up design tokens (colors, spacing, typography)
- [ ] Create GlassCard base component
- [ ] Implement gradient backgrounds
- [ ] Build button variants
- [ ] Create splash screen

### Phase 2: Onboarding (Day 1-2)
- [ ] Implement onboarding flow (6 screens)
- [ ] Generate illustrations using prompts
- [ ] Add page transition animations
- [ ] Create interactive demo screen
- [ ] Build permission request flow

### Phase 3: Core Screens (Day 2-3)
- [ ] Home dashboard layout
- [ ] Thought clearing chat interface
- [ ] Sleep log detail view
- [ ] Insights dashboard
- [ ] Settings screen

### Phase 4: Polish (Day 3-4)
- [ ] Add micro-interactions
- [ ] Implement loading states
- [ ] Create empty states
- [ ] Add haptic feedback
- [ ] Test accessibility
- [ ] Demo mode preparation

---

## Judge Demo Script

**Opening (10 seconds):**
> "At 2 AM when your brain won't shut off, Insomnia Butler helps you actually stop thinking so you can start sleeping. Watch this."

**Demo Flow (2 minutes):**
1. Show onboarding (5 seconds per screen, fast swipe)
2. Land on interactive demo screen
3. Type: "I'm worried about tomorrow's presentation"
4. Show AI categorization and intervention
5. Display readiness increase 45% → 85%
6. Jump to insights: "Users sleep 35% faster"

**Technical Highlight (30 seconds):**
> "Behind this beautiful UI, Serverpod orchestrates all AI with safety guardrails, detects patterns in background jobs, and provides real-time analytics. This isn't just a chatbot—it's structured cognitive intervention."

**Closing (20 seconds):**
> "Real problem. Novel solution. Deep tech. Beautiful design. That's Insomnia Butler."

---

**This design system gives you everything needed to build a jaw-dropping UI that judges will remember. The glassmorphic aesthetic is on-trend, the interactions are delightful, and the focus on the core problem makes it instantly relatable. Now go make it beautiful. 💎✨**