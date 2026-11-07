# 🎓 FAHEM (فاهم) — Integrated Digital Educational Platform

[![Flutter](https://img.shields.io/badge/Frontend-Flutter-02569B?logo=flutter)](https://flutter.dev/)
[![Firebase](https://img.shields.io/badge/Backend-Firebase-FFCA28?logo=firebase)](https://firebase.google.com/)
[![Dart](https://img.shields.io/badge/Language-Dart-0175C2?logo=dart)](https://dart.dev/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

**FAHEM** is an integrated cross-platform digital learning ecosystem engineered to revolutionize Egyptian curriculum education[cite: 24]. Designed to bridge the gap between **Students**, **Teachers**, and **Parents**, FAHEM provides role-based interactive mobile interfaces, real-time progress analytics, video lecture streaming, auto-graded assessments, and secure subscription management[cite: 18, 19, 24].



## 🌟 Key Features

### 👨‍🎓 Student Module
* **Interactive Learning Map:** Map-style interactive curriculum progression by grade and term[cite: 18, 24].
* **Video Lecture Player & Downloads:** High-quality video streaming with offline summary PDF downloads[cite: 18, 24].
* **Auto-Graded Quizzes:** Timed interactive quizzes with instant performance feedback[cite: 18, 24].
* **AI Tutor Chat:** Real-time AI assistant for instant concept explanation and Q&A support[cite: 18].
* **Gamification & Achievements:** XP points, badges, avatars, and competitive leaderboards[cite: 18, 24].

### 👪 Parent Module
* **Multi-Child Hub:** Single account oversight linking multiple children across grades[cite: 18, 24].
* **Real-time Analytics:** Visual reports tracking study hours, attendance logs, and quiz trends[cite: 18, 24].
* **Subscription Management:** Direct payment integration (Fawry / Credit Card / Vodafone Cash)[cite: 18, 24].
* **Direct Teacher Communication:** In-app messaging channel with registered subject teachers[cite: 18].

### 👨‍🏫 Teacher Module
* **Content Management System:** Dedicated tools to upload video lessons, attachments, and metadata[cite: 19, 24].
* **Question Bank & Quiz Creator:** Flexible UI to design quizzes and define auto-grading rules[cite: 19, 24].
* **Class Performance Analytics:** Aggregated analytics identifying class weaknesses and average scores[cite: 19].
* **Financial Oversight & Withdrawals:** Track earnings with transparent 70% Teacher / 30% Platform split[cite: 20, 24].

### 🛠️ Administrator Panel
* **User Lifecycle Verification:** Verify, activate, or suspend accounts for all roles[cite: 19, 24].
* **Content Moderation:** Quality review pipeline for uploaded videos before student release[cite: 19, 24].
* **Platform Profit Metrics:** Complete financial overview, active subscriptions, and withdrawal log approvals[cite: 19, 20, 24].

---

## 🛠️ Tech Stack & Infrastructure

* **Frontend:** Flutter SDK (Cross-platform for Android & iOS)[cite: 24]
* **State Management:** BLoC / Cubit Pattern
* **Backend Services:** Firebase Authentication, Cloud Firestore[cite: 20, 24]
* **Media & Video Hosting:** Cloudinary Video API Integration[cite: 24]
* **Security & OTP:** EmailJS Integration for OTP Verification[cite: 20, 24]
* **Software Estimation:** 206 Function Points (~11.3K LOC)[cite: 24]

---

## 📐 System Architecture & ERD Schema

### System Context Diagram


🎓 FAHEM Educational Platform 


👨‍🎓 Student            👪 Parent           👨‍🏫 Teacher  



### Firestore Database Schema (ERD Summary)
* **`USERS`**: Base authentication documents (`uid`, `role`, `isActive`, `otp_code`)[cite: 20].
* **`STUDENTS`**: Academic profile (`stage`, `term`, `linkCode`, `unlockedPackages`)[cite: 20].
* **`PARENTS`**: Family linking array (`linkedStudents`)[cite: 20].
* **`TEACHERS`**: Financials & subject assignments (`availableBalance`, `averageScore`)[cite: 20].
* **`SUBJECTS_CONTENT` -> `UNIT` -> `LESSON`**: Structured course data[cite: 20].
* **`STUDENT_PROGRESS`**: Real-time video & quiz metrics tracking[cite: 20].
* **`TRANSACTIONS`**: Revenue-split logs (`totalAmountPaid`, `platformProfit`, `teachersProfit`)[cite: 20].


## 🚀 Getting Started

### Prerequisites
* Flutter SDK (`>=3.0.0`)
* Dart SDK (`>=3.0.0`)
* Android Studio / VS Code with Flutter extensions
* Active Firebase project configuration

### Installation

1. **Clone the repository:**

   git clone [https://github.com/abanoubmalak/fahem_elearning_platforme.git](https://github.com/abanoubmalak/fahem_elearning_platforme.git)
   cd fahem_elearning_platforme


2. **Install dependencies:**
flutter pub get



3. **Configure Firebase:**
Add your `google-services.json` for Android and `GoogleService-Info.plist` for iOS into their respective directories.
4. **Run the app:**

flutter run



## 📈 Economic Feasibility & Impact

* **Return on Investment (ROI):** ≈ 217% over 3 years.


* **Net Present Value (NPV):** ~880,631 EGP positive NPV.


* **Payback Period:** Reached within 1.2 years.





## 👨‍💻 Developer & Team

* **Abanoub Malak Ramzy Hakim** — *Lead Mobile Application Developer (Flutter & Architecture)*


* Developed as a Bachelor's Graduation Project at **Minia University - Faculty of Science (IT Department)**.





## 📄 License

This project is licensed under the MIT License - see the [LICENSE](https://www.google.com/search?q=LICENSE) file for details.
