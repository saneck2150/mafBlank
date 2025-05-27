# Mafia Judge Blank

A lightweight Flutter application that helps a moderator (“judge”) run a classic **Mafia™** party game on a phone or tablet.

---

## ✨ Features

| Area              | Details |
|-------------------|---------|
| **Main menu**     | One-tap **“Create new game”** button that opens a clean game sheet. |
| **Voting screen** | * Round table with three voting rounds.<br>* Manual input of vote counts via compact text fields.<br>* Quick **Reset Voting** button to clear nominations and votes. |
| **Notes**         | Two text boxes at the bottom for **“Best move”** and **“Kill order”**. |
| **Logs**          | • Save the current round to an in-memory log with one tap.<br>• View the entire log in a scrollable dialog and copy it to clipboard. |
| **Architecture**  | Code split into **`pages/`** and (optionally) **`widgets/`** so each file stays small and readable. |


---

## 🚀 Getting started

1. **Prerequisites**

   * Flutter SDK 3.x  
   * Any device or emulator that runs Flutter (Android / iOS / Web)

2. **Clone and run**

   ```bash
   git clone https://github.com/<your-name>/mafia_judge.git
   cd mafia_judge
   flutter pub get          # install dependencies
   flutter run              # launch on the connected device
