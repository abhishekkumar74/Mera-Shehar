# Firebase Daily Notification Setup Guide

This guide outlines how to send daily scheduled notifications to app users via the Firebase Console.

## Steps to Send Daily Notifications

1. Open the [Firebase Console](https://console.firebase.google.com/).
2. Select your project **Mera Shehar**.
3. In the left navigation menu, go to **Engage** $\rightarrow$ **Messaging**.
4. Click **Create first campaign** (or **New campaign**) and select **Firebase Notification messages**.
5. **Notification Text**:
   - **Title Example 1**: `Aaj ka card ready hai 🌸`
   - **Body Example 1**: `Status par lagao, dost dekhenge.`
   - **Title Example 2**: `Naya Tyohar Card 🪔`
   - **Body Example 2**: `Apne naam aur photo ke saath share karein.`
6. **Targeting**:
   - Select **Topic**.
   - Choose the topic: `daily`.
7. **Scheduling**:
   - Select **Daily** and choose the preferred local time (e.g. `08:00 AM`).
8. **Additional Options (Custom Data / Payload)**:
   - Expand the **Additional options** section.
   - Under **Custom data**, add key-value pairs to handle deep links:
     - **Key**: `route`
     - **Value**: `/home` OR `/editor/<templateId>` (e.g., `/editor/diwali_gold_01`)
   - *Note*: Only `/home` and `/editor/<templateId>` are allowed. Invalid or unrecognized routes fallback safely to `/home`.
9. Click **Review** and **Publish**.
