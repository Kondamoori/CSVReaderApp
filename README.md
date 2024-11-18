# CSV File Reader App - MVP 1 - Load CSV file and display records on app.

# Application Functionality
- Read CSV file from local file system.
- Parse CSV file and display contents of file to app user.
- Support CSV formats with configuration.
- Detail screen with all the details of CSV Row.

# Core Functionality: CSVFileParser Overview
- The CSVFileParser is a robust solution for parsing large CSV files efficiently.
- It employs a chunk-based processing mechanism to minimise memory usage and dynamically fetch data as required. This design is ideal for processing large datasets while maintaining optimal performance.
- Dynamically fetches additional chunks of data when the remaining text falls below a threshold (default: 100 characters) and the requested row limit is unmet.

# Memory Management
- Removes processed chunks from memory to reduce the application's memory footprint.
- Actively manages the in-memory state of the parser.

# Event-Based Notifications
- Publishes progress using Combine publishers.
- RowsPublisher, Emits parsed rows as an array of strings.
- ParsingPublisher, indicates the parser's current state (idle, parsing, finished)
- Detects and reports parsing errors through Combine's completion handler.

# Technical Design
- Used Xcode 16 & SwiftUI, Swift.
- No third party libraries are used.
- Used MVVM-C pattern (combination of the Model-View-ViewModel architecture, plus the Coordinator pattern), Swift UI, Combine declarative Swift API for processing values over time.
- XCTest for unit testing viewModels for business logic (FileLoading, File Parsing, Process records) of data.

# High level overview of app flow. This will give details how app components perform.

![csv parser](https://github.com/user-attachments/assets/560c3617-c1a5-4193-9b5a-adb9b8653dc8)

# Improvements can be considered if we have some more time.

# MVP 2
 - Improve the UI with grid layout and bring excel feeling of viewing CSV.
 - Add support to different types of CSV file format.
 - Utilise FileHandler seekToOffset function to move back & forward on data chunk.
 - Remove elements from data source after certain limit, keep feeding values by moving on File both forward & backward direction.
 - See memory optimisation plus asynchronous handling
 - Fetch files form remote and parse.
 - Accessibility
 - UITests to have more coverage of happy flows.
 - Improve the list with search.

# Test Coverage
![Screenshot 2024-11-18 at 03 37 58](https://github.com/user-attachments/assets/8d492f40-15c2-4dce-9dc5-0c4d4d645cf3)

# Screenshots & Quick app look for various states.

# Happy Case
![Simulator Screenshot - iPhone 16 Pro - 2024-11-18 at 03 32 05](https://github.com/user-attachments/assets/c593050b-f609-4529-9514-5cc02442699e)

# Error case 
![Simulator Screenshot - iPhone 16 Pro - 2024-11-18 at 03 29 55](https://github.com/user-attachments/assets/2e435375-348c-4f93-b81c-f453845c522e)

