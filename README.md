
# EcoBuddy - Pet-Based Trash Recognition App

## 🌟 Project Overview

EcoBuddy is an innovative Android application that combines the charm of a virtual pet (similar to Pou) with environmental consciousness through AI-powered trash recognition. Using Google Vision API, the app helps users properly identify and dispose of waste while nurturing a virtual companion that grows and learns with sustainable habits.

## 🎯 Core Features

### 1. **AI-Powered Trash Recognition**
- **Google Vision API Integration**: Real-time object detection and classification
- **Trash Type Identification**: Plastic, glass, metal, organic, electronic waste, etc.
- **Disposal Guidelines**: Proper recycling and disposal instructions
- **Environmental Impact**: Shows the environmental benefit of proper disposal

### 2. **Virtual Pet System**
- **Pet Growth**: Pet evolves based on user's eco-friendly actions
- **Personality Development**: Pet's traits change based on user behavior
- **Interactive Animations**: Touch, feed, and play with your pet
- **Customization**: Unlock new accessories, colors, and environments

### 3. **Gamification & Engagement**
- **Daily Activities**: Trash scanning challenges, eco-tips, green habits
- **Achievement System**: Badges for recycling milestones, streak counters
- **Mini-Games**: Sorting games, environmental quizzes, pet care activities
- **Lead6 oyerboards**: Community challenges and eco-competitions

### 4. **Learning & Progress**
- **Knowledge Base**: Growing database of disposal methods
- **Habit Tracking**: Monitor recycling behavior and environmental impact
- **Educational Content**: Tips for sustainable living
- **Progress Analytics**: Visual representation of environmental contributions

---

## 🛠️ Technical Requirements & Implementation Plan

### Phase 1: Project Setup & Core Architecture

#### **Current Project Analysis**
- ✅ **Framework**: Jetpack Compose with Material 3
- ✅ **Language**: Kotlin
- ✅ **Min SDK**: 24 (Android 7.0)
- ✅ **Target SDK**: 35 (Android 15)
- ✅ **Build Tool**: Gradle with Kotlin DSL

#### **Required Dependencies to Add**
```kotlin
// Camera & Image Processing
implementation("androidx.camera:camera-core:1.3.1")
implementation("androidx.camera:camera-camera2:1.3.1")
implementation("androidx.camera:camera-lifecycle:1.3.1")
implementation("androidx.camera:camera-view:1.3.1")

// Google ML Kit & Vision
implementation("com.google.mlkit:vision-common:17.3.0")
implementation("com.google.mlkit:object-detection:17.0.1")
implementation("com.google.mlkit:image-labeling:17.0.8")

// Networking & Image Loading
implementation("com.squareup.retrofit2:retrofit:2.9.0")
implementation("com.squareup.retrofit2:converter-gson:2.9.0")
implementation("io.coil-kt:coil-compose:2.5.0")

// Database
implementation("androidx.room:room-runtime:2.6.1")
implementation("androidx.room:room-ktx:2.6.1")
kapt("androidx.room:room-compiler:2.6.1")

// Animation & UI
implementation("com.airbnb.android:lottie-compose:6.2.0")
implementation("androidx.compose.animation:animation:1.5.8")

// Preferences & Storage
implementation("androidx.datastore:datastore-preferences:1.0.0")
```

### Phase 2: Google Vision API Setup

#### **API Key Configuration**
1. **Google Cloud Console Setup**
    - Create new project or use existing
    - Enable Vision API and ML Kit
    - Generate API key with proper restrictions

2. **API Key Security**
    - Store in `local.properties` (not in version control)
    - Use BuildConfig for secure access
    - Implement API key rotation strategy

3. **Why Google Vision API?**
    - ML Kit is limited to common objects and basic trash types. For comprehensive trash recognition, Google Vision API offers a much larger dataset and better accuracy for rare or region-specific trash items.
    - As a solo developer, leveraging Google Vision API allows you to tap into Google's resources without building your own massive dataset.
    - **Note:** API usage may incur costs. Consider batching requests and providing offline fallback for common trash types.

4. **API Integration Steps**
    - Add API key to `local.properties` (never commit to git)
    - Use Retrofit or OkHttp for network requests to Vision API
    - Parse results and map to local trash categories
    - Show user-friendly disposal instructions based on API response
    - Log unknown items for future improvement

5. **Testing Google Vision API**
    - Create a test suite with sample trash images
    - Validate API accuracy and response times
    - Document edge cases and fallback logic

---

## 📚 Comprehensive Planning & Feature Breakdown

This README is the master plan for EcoBuddy. Every feature, dependency, and design decision will be documented here to ensure consistency and clarity throughout development.

---

## 🐾 Free Pet Creation Options

Since the pet will be custom-made for this app and must be fun for children, here are free or low-cost options for creating your pet:

1. **LottieFiles (https://lottiefiles.com/)**
    - Free library of animated characters (search for "pet" or "creature")
    - You can customize colors and accessories
    - Download as JSON for use in Compose

2. **Pixabay & OpenGameArt (https://opengameart.org/)**
    - Free 2D sprites and character art
    - Some assets are public domain or CC0
    - Can be animated using Android's built-in tools

3. **Canva (https://www.canva.com/)**
    - Free online design tool
    - Create simple pet illustrations and export as PNG/SVG

4. **Blender (https://blender.org/)**
    - Free 3D modeling and animation tool
    - Export 2D sprite sheets or simple animations

5. **Krita (https://krita.org/)**
    - Free digital painting tool for custom character art

6. **Lottie Editor (https://lottiefiles.com/editor)**
    - Edit and animate Lottie files for free

7. **Procreate (iPad, paid but affordable)**
    - Draw and export custom pet art

**Recommendation:** Start with LottieFiles for animated pets, or Canva/Krita for static art. You can always upgrade to custom animations later.

---

### 🧒 Gamification & Child Engagement

- Pet starts as a "lost creature" found by the user, surrounded by trash
- Narrative: Help the pet clean its home and grow by scanning and disposing of trash
- Pet reacts emotionally to user actions (happy, sad, excited)
- Unlock new environments and accessories as the pet grows
- Daily eco-challenges and fun facts
- Mini-games: Trash sorting, pet care, environmental quizzes
- Achievements: "First Clean-Up", "Eco Hero", "Pet Evolution"
- Visual progress: Pet and home get cleaner and more vibrant

---

## 📋 Development Roadmap

### **Week 1-2: Foundation** ✅ **COMPLETED**
- ✅ Set up project dependencies
- ✅ Implement basic UI architecture with Jetpack Compose
- ✅ Create database schema and Room setup
- ✅ Design app navigation structure

### **Week 3-4: Pet System** ✅ **COMPLETED**
- ✅ Research and choose pet animation approach (Lottie + placeholder animations)
- ✅ Implement basic pet display and interactions
- ✅ Create pet state management system (Repository + ViewModel)
- ✅ Design pet evolution mechanics (XP, levels, stages)

**Status: Pet System is 100% complete!**
- ✅ PetViewModel with full state management
- ✅ Interactive pet display with custom painting animations
- ✅ Pet care actions (feed, play, pet, clean)
- ✅ Evolution stages and progress tracking
- ✅ Happiness and XP systems
- ✅ Pet persistence and state management

### **Week 5-6: Camera & Recognition** ✅ **COMPLETED**
- ✅ Integrate CameraX for image capture
- ✅ Set up Google Vision API integration with billing
- ✅ Create trash classification system
- ✅ Build comprehensive disposal instruction database (20+ trash types)

### **Week 7-8: Core Features** 🚧 **IN PROGRESS**
- ✅ Implement scanning workflow
- ✅ Connect pet growth to user actions
- 🔄 **NEXT**: Create achievement system
- 🔄 **NEXT**: Add daily activities and challenges

### **Week 9-10: Game Features**
- [ ] Develop mini-games
- [ ] Implement progress tracking
- [ ] Add social features (optional)
- [ ] Polish UI/UX

### **Week 11-12: Testing & Refinement**
- [ ] Comprehensive testing on multiple devices
- [ ] Performance optimization
- [ ] User feedback integration
- [ ] Final polish and bug fixes

---

## 🔑 Critical Decisions to Make

### **1. Pet Animation Approach**
- **Question**: Should we use Lottie animations, custom Android animations, or create 3D models?
- **Recommendation**: Start with Lottie for MVP, evaluate custom solutions later

### **2. Recognition Technology**
- **Question**: ML Kit (offline) vs Google Cloud Vision (online) vs custom model?
- **Recommendation**: Begin with ML Kit, add Cloud Vision for edge cases

### **3. Pet Design & Personality**
- **Question**: What type of creature? How many species? Customization depth?
- **Ideas**: Eco-themed creatures (tree sprites, recycling robots, nature guardians)

### **4. Monetization Strategy**
- **Options**: Freemium with premium pets, cosmetic purchases, ad-supported
- **Consideration**: Keep core environmental features free

### **5. Data Privacy**
- **Question**: Store images locally or cloud? User data handling?
- **Recommendation**: Local storage for privacy, optional cloud backup

---

## 🧪 Testing Strategy

### **Unit Tests**
- Pet state management logic
- Trash classification algorithms
- Achievement progression calculations
- Database operations

### **Integration Tests**
- Camera capture workflow
- ML Kit integration
- Pet animation triggers
- User progress persistence

### **UI Tests**
- Navigation flow
- Camera permissions
- Scanning workflow
- Mini-game interactions

### **Performance Tests**
- Image processing speed
- Animation frame rates
- Database query optimization
- Memory usage monitoring

---

## 📱 Device Requirements

### **Minimum Requirements**
- Android 7.0 (API level 24)
- 3GB RAM
- Camera with autofocus
- 2GB available storage

### **Recommended Requirements**
- Android 10+ (API level 29)
- 4GB+ RAM
- Good camera quality for better recognition
- 4GB+ available storage

---

## 🚀 Getting Started

### **Prerequisites**
- Android Studio Arctic Fox or later
- Android SDK 35
- Kotlin 1.9+
- Google Play Services

### **Setup Instructions**
1. Clone the repository
2. Open in Android Studio
3. Add your Google Vision API key to `local.properties`
4. Sync Gradle dependencies
5. Run on device or emulator with camera

---

## 🤝 Next Steps Discussion

---

## 📋 Project Specifications & Decisions

### 🐾 Pet Character & Story
- **Pet Type**: Custom animal-like creature
- **Default Name**: "Bud" (user can rename at app start)
- **Discovery**: Pet found in a recycling bin
- **Backstory**: *Bud is a magical eco-spirit that was born from the collective wish of discarded items to find their proper homes. When trash is properly sorted and disposed of, Bud grows stronger and happier. When waste is neglected or incorrectly handled, Bud becomes weak and sad. The user's mission is to help Bud learn about proper waste management while nurturing their friendship.*
- **Evolution Stages**: Baby → Child → Adult (unlocks new environments and challenges)
- **Emotional States**: Happy (correct actions), Sad (wrong actions/neglect), Excited, Sleepy, etc.

### 🎯 Target Audience & Education
- **Primary Age**: ~10 years old
- **Educational Goal**: Teach recycling and proper waste management through empathy with the pet
- **Parental Controls**: Required for subscription upgrades (scanning limits)
- **Content Complexity**: Age-appropriate environmental education with fun facts
- **Language**: English only (initially)
- **Accessibility**: No audio instructions needed

### 💰 Business Model & Monetization
- **Model**: Freemium
- **Free Tier**: Limited daily scans with Google Vision API
- **Premium Features**: Unlimited scans
- **No Advertisements**: Clean experience for children
- **Budget**: $10/month for Google Vision API (rely on free tier as much as possible)

### 🛠️ Technical Architecture
- **Data Storage**: Primarily local storage
- **Image Handling**: Delete photos after analysis (privacy compliance)
- **Network Requirement**: Online connection required for scanning feature
- **Cross-Device Sync**: Nice-to-have feature for future implementation
- **Analytics**: Simple in-game event tracking (with privacy compliance)
- **Privacy**: Full COPPA compliance for children

### 🎮 Game Mechanics & Progression
- **Pet Growth**: XP-based progression system
- **Happiness System**: Higher happiness = higher XP gain
- **Neglect Consequences**: If unused for days, user must clean digital waste around pet
- **Scanning Accuracy**: Consequences for incorrect trash identification
- **Main Activity**: Pet care is primary, scanning is progression feature
- **Offline Features**: Some pet care features work offline, scanning requires internet

### 🏆 Achievement & Challenge System
- **Total Achievements**: 100 achievements planned
- **Special Unlocks**: Some achievements unlock exclusive customizations (not purchasable)
- **Challenge Types**: Daily, weekly, and monthly challenges
- **Milestone Rewards**: To be determined during development

### 📚 Educational Content Strategy
- **Scope**: Both general environmental facts and specific waste disposal
- **Regional Flexibility**: Disposal instructions general enough for multiple regions
- **Learning Approach**: Pet learns alongside user, occasionally teaches
- **Fun Facts**: Include recycling processes and environmental impact explanations
- **Waste Management**: Include information about proper disposal methods

### 🎯 Mini-Games & Activities
- **Approach**: Educational and fun combined
- **Selection**: To be determined (open to suggestions)
- **Integration**: Support main learning objectives

### 🔒 Safety & Content Filtering
- **Inappropriate Content**: Google Vision API will handle detection
- **Content Safety**: Automatic filtering for non-waste related images
- **Privacy Protection**: No image storage, immediate deletion after analysis

---

## 🎨 Pet Creation Platform Options & Recommendations

Based on your willingness to learn or commission work, here are the best platforms for creating your custom pet:

### **Option 1: Commission Professional Work**
**Recommended Platforms to Find Artists:**
- **Fiverr**: $50-200 for custom pet design + basic animations
- **Upwork**: $100-500 for professional character design
- **ArtStation**: Higher-end professional artists
- **Reddit** (r/HungryArtists): Indie artists, often more affordable

**What to Request:**
- Character design sheets (front, side, back views)
- Emotional state variations (happy, sad, excited, sleepy)
- Evolution stages (baby, child, adult)
- Basic animation frames or Lottie-compatible files

### **Option 2: Learn and Create Yourself**
**Recommended Tools & Learning Path:**

1. **Procreate (iPad) - $12.99**
    - **Best for**: Hand-drawn, organic pet designs
    - **Learning Time**: 1-2 weeks for basics
    - **Export**: PNG sequences for Android animation

2. **Adobe After Effects (Subscription)**
    - **Best for**: Professional animations exported as Lottie files
    - **Learning Time**: 1-2 months for character animation
    - **Export**: JSON files directly usable in Compose

3. **Krita (Free)**
    - **Best for**: Free alternative to Procreate/Photoshop
    - **Learning Time**: 2-3 weeks for digital art basics
    - **Export**: PNG sprites for custom Android animations

4. **Blender (Free)**
    - **Best for**: 3D pet that can be rendered as 2D sprites
    - **Learning Time**: 2-3 months for character modeling
    - **Export**: Rendered PNG sequences

### **Option 3: Hybrid Approach (Recommended)**
1. **Commission the initial design** ($50-100 on Fiverr)
    - Get professional character design sheets
    - Request source files (PSD, AI, or Sketch)

2. **Learn basic animation yourself**
    - Use the commissioned design as base
    - Create simple state changes and basic animations
    - Expand animations as you learn

### **Implementation in Android:**
```kotlin
// For Lottie animations (easiest)
implementation("com.airbnb.android:lottie-compose:6.2.0")

@Composable
fun PetView(petState: PetState) {
    val animationFile = when(petState) {
        PetState.HAPPY -> "pet_happy.json"
        PetState.SAD -> "pet_sad.json"
        // etc.
    }
    
    LottieAnimation(
        composition = rememberLottieComposition(
            LottieCompositionSpec.Asset(animationFile)
        ).value,
        isPlaying = true,
        iterations = LottieConstants.IterateForever
    )
}
```

### **My Recommendation for You:**
1. **Start with Fiverr commission** for pet design ($50-100)
2. **Use Lottie animations** for easy implementation
3. **Learn Procreate or Krita** for future customizations and accessories
4. **Plan for 2-3 evolution stages** initially

Would you like me to help you create a brief for commissioning the pet design, or would you prefer to explore the self-learning route first?

---

**This README now serves as your complete project specification. Update it as features are implemented or requirements change!**
