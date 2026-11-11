# Blood Donation App

A Flutter mobile application that connects blood donors with blood banks and helps manage donation appointments in a simple and accessible way.

The app is designed for two main user types:

- Donors: create an account, manage their profile, schedule donation appointments, and receive blood-request notifications.
- Blood banks: search for eligible donors by blood type and city, then send urgent blood alerts to matching donors.

## Overview

This project is a full-stack mobile app built with Flutter and Firebase. It uses Firebase Authentication for account management and Firestore for storing donor data, appointment records, and donor notifications.

The app allows users to:

- sign up and log in securely
- store personal details such as name, city, and blood type
- view their donation-related information
- book a donation appointment within the allowed time window
- check appointment-related status
- receive notifications from hospitals or blood banks
- help blood banks quickly identify eligible donors

## Main Features

### Donor features

- User registration and login
- Personal donor profile with blood type and city
- Home screen with donation guidance and quick actions
- Appointment booking with a calendar and time-slot selection
- Prevents multiple donations within a short time window
- Notification center for donation alerts
- Donation information section explaining what to expect during the process

### Blood bank features

- Blood bank login and dashboard
- Filter donors by blood type and city
- Count the number of eligible donors matching a request
- Send blood alert notifications to matching donors
- Hospital field included when sending alerts

## Project Structure

- lib/main.dart: app entry point and route logic
- lib/models/donor.dart: donor data model
- lib/services/authentication_service.dart: Firebase authentication and donor data access
- lib/screens/: screen modules for login, registration, donor dashboard, blood bank dashboard, appointments, status, and notifications
- lib/widgets/: reusable UI components such as custom buttons and text fields
- assets/: app images and icons
- android/, ios/, linux/: platform configuration files

## Technologies Used

- Flutter
- Dart
- Firebase Authentication
- Cloud Firestore
- Firebase Cloud Messaging
- Material Design UI

## Typical App Flow

1. A donor registers with their email, password, name, blood type, and city.
2. The donor logs into the app and sees their personalized home screen.
3. The donor books a donation appointment by selecting a date and time slot.
4. The appointment is stored in Firestore and confirmed before being accepted.
5. A blood bank can search for donors matching a blood type and area.
6. The blood bank can send a notification to eligible donors about an urgent need.

## Purpose

The application makes the blood donation process easier and faster by connecting donors and blood banks in real time, reducing manual coordination and improving access to urgent blood needs.

## Demo

Find the link to see the app demo: https://drive.google.com/drive/folders/1WjDWMCBnMHhEs_TiRu4FoTpPeX4v09HJ?dmr=1&ec=wgc-drive-%5Bmodule%5D-goto

<div align="center">
  <img width="180" loading="lazy" decoding="async" alt="Blood donation app screenshot 1" src="https://github.com/user-attachments/assets/918c9ee3-93c5-4394-97e0-1f895870760b" />
  <img width="180" loading="lazy" decoding="async" alt="Blood donation app screenshot 2" src="https://github.com/user-attachments/assets/fe626b8c-408e-4c0d-a160-f4e7308d59dc" />
  <img width="180" loading="lazy" decoding="async" alt="Blood donation app screenshot 3" src="https://github.com/user-attachments/assets/d1792e77-8c97-4cdb-bf15-da8f8aba8241" />
</div>

<div align="center">
  <img width="180" loading="lazy" decoding="async" alt="Blood donation app screenshot 4" src="https://github.com/user-attachments/assets/73b31b56-4596-43df-9221-ede0dc02fd37" />
  <img width="180" loading="lazy" decoding="async" alt="Blood donation app screenshot 5" src="https://github.com/user-attachments/assets/1389cabf-ad50-42f2-8c6d-9f27a708e071" />
  <img width="180" loading="lazy" decoding="async" alt="Blood donation app screenshot 6" src="https://github.com/user-attachments/assets/8d82b61b-389f-4a27-8088-35b80eead1a2" />
</div>
