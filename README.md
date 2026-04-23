# Trendy Headaches - SQLite Version

The original iOS health tracking application designed to help users monitor and analyze migraine patterns through comprehensive symptom logging and data visualizations using local SQLite database storage.

## Project Overview

This repository contains the original implementation of Trendy Headaches, an iOS application that empowers users to take control of their migraine health through detailed tracking and data-driven insights. This version uses SQLite for local data persistence, providing a fully offline-capable health tracking solution.

**Status**: Legacy Version - This project has been migrated to Supabase for cloud functionality. See [Trendy-Headaches-Supabase](https://github.com/abbiebarnhardt19/Trendy-Headaches-Supabase) for the current version.

## Key Features

### Comprehensive Health Logging
- Track multiple aspects of migraine episodes including:
  - Symptoms and their severity
  - Medications taken
  - Potential triggers
  - Side effects experienced
  - Custom log topics for personalized tracking
- Flexible logging system that adapts to individual user needs
- Historical log management with editing and deletion capabilities

### Data Visualizations
- Analytics dashboard with visual representations of health data
- Trend analysis over time
- Correlation analysis between symptoms, triggers, and medications
- Statistical summaries of logged data

### Local Data Storage
- SQLite database for offline data persistence
- Core Data integration for iOS data management
- All data stored locally on device
- No internet connection required for full functionality

## Technologies Used

- **Swift**: Native iOS development
- **SQLite**: Local relational database
- **Core Data**: iOS data persistence framework
- **SwiftUI/UIKit**: User interface design

## Why This Version Exists

This SQLite implementation served as the foundation for the Trendy Headaches project and demonstrates:
- Local-first data architecture
- Offline-capable mobile application design
- SQLite database schema design and optimization
- Core Data integration patterns

## Migration to Supabase

This project was migrated to Supabase to enable:
- **Cloud synchronization**: Access data across multiple devices
- **Automatic backup**: Prevent data loss
- **Real-time updates**: Instant synchronization
- **Enhanced security**: Row-level security and encryption
- **Scalability**: Support for growing user base

The migration required:
- Redesigning database schema for PostgreSQL
- Implementing Supabase authentication
- Refactoring data access layer
- Adding network connectivity handling
- Implementing data synchronization logic

## Database Schema

The SQLite database includes tables for:
- User profiles and settings
- Symptom logs with timestamps
- Medication tracking
- Trigger identification
- Side effect monitoring
- Custom log topics

All entities are connected through foreign key relationships to maintain data integrity.

## Technical Highlights

### Local Data Architecture
- SQLite provides lightweight, serverless database functionality
- Core Data manages object graph and persistence
- Optimized queries for fast data retrieval
- Efficient indexing for analytics queries

### Offline-First Design
- Full functionality without internet connection
- No dependency on external services
- Fast performance with local data access
- Privacy-focused with all data stored on device

## Comparison: SQLite vs Supabase

| Feature | SQLite Version | Supabase Version |
|---------|---------------|------------------|
| Data Storage | Local device only | Cloud with local caching |
| Multi-device sync | Not supported | Real-time sync |
| Backup | Manual export only | Automatic cloud backup |
| Authentication | Local only | Secure cloud auth |
| Scalability | Single device | Multi-user platform |
| Internet Required | No | Yes (with offline mode) |
| Data Security | Device encryption | Row-level security + encryption |

## Setup & Installation

### Prerequisites
```
Xcode 14.0+
iOS 15.0+ deployment target
Swift 5.5+
```

### Installation
1. Clone the repository
```bash
git clone https://github.com/abbiebarnhardt19/Trendy-Headaches-SQLite.git
cd Trendy-Headaches-SQLite
```

2. Open in Xcode
- Open the project file in Xcode
- No external dependencies required

3. Build and run
- Select your target device or simulator
- Build and run (⌘R)

## Why This Repository Remains Available

This repository is maintained for:
- **Reference**: Demonstrates local-first mobile architecture
- **Learning**: Shows SQLite and Core Data implementation patterns
- **Comparison**: Illustrates differences between local and cloud database approaches
- **Portfolio**: Documents project evolution and migration capabilities

## Project Evolution

This project evolved through several phases:

1. **SQLite Implementation** (This repository)
   - Local database with Core Data
   - Offline-first architecture
   - Single-device functionality

2. **Supabase Migration** ([Current version](https://github.com/abbiebarnhardt19/Trendy-Headaches-Supabase))
   - Cloud database with PostgreSQL
   - Multi-device synchronization
   - Enhanced security and scalability

3. **Future Development**
   - Apple Health integration
   - Weather API integration
   - App Store launch

## Academic & Professional Context

This project demonstrates:
- **Database design**: SQLite schema design and optimization
- **iOS development**: Native Swift application development
- **Data persistence**: Core Data framework implementation
- **Migration planning**: Ability to evolve architecture based on requirements
- **Version control**: Managing multiple versions of a project

## Contact

**Abigail Barnhardt**
- Email: abbiebarnhardt@gmail.com
- LinkedIn: [linkedin.com/in/abigail-barnhardt-6276942b5](https://linkedin.com/in/abigail-barnhardt-6276942b5)
- GitHub: [@abbiebarnhardt19](https://github.com/abbiebarnhardt19)

## License

This project is currently in development. All rights reserved. Please contact the author for usage permissions.

---

*Original implementation of Trendy Headaches demonstrating local-first mobile architecture with SQLite.*

**Related Repositories**:
- [Trendy-Headaches-Supabase](https://github.com/abbiebarnhardt19/Trendy-Headaches-Supabase) - Current cloud-based implementation
- [Headache-Predictions](https://github.com/abbiebarnhardt19/Headache-Predictions) - Data analysis research and exploration
