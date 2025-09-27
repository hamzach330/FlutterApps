# Becker Tool

[![pipeline status](https://gitlab.becker-antriebe.com/entwicklung_elektronik/centronic_plus_installation_tool/badges/master/pipeline.svg)](https://gitlab.becker-antriebe.com/entwicklung_elektronik/centronic_plus_installation_tool/-/commits/master) 

[![coverage report](https://gitlab.becker-antriebe.com/entwicklung_elektronik/centronic_plus_installation_tool/badges/master/coverage.svg)](https://gitlab.becker-antriebe.com/entwicklung_elektronik/centronic_plus_installation_tool/-/commits/master) 

[![Latest Release](https://gitlab.becker-antriebe.com/entwicklung_elektronik/centronic_plus_installation_tool/-/badges/release.svg)](https://gitlab.becker-antriebe.com/entwicklung_elektronik/centronic_plus_installation_tool/-/releases) 

## Overview

A comprehensive Flutter monorepository containing multiple applications and modules for Becker motor control systems. The repository includes installation tools, control applications, and supporting libraries for various Becker motor protocols including Centronic PLUS, EVO, Timecontrol, and XCF systems.

**Supported Platforms:** Android, Windows, macOS, Linux

**Minimum Flutter Version:** 3.10.6

## Quick Start

```bash
# For Control Tool
cd control_tool
flutter pub get
flutter run -d (windows|macos|android) --verbose (--release)

# For Install Tool  
cd install_tool
flutter pub get
flutter run -d (windows|macos|android) --verbose (--release)

# For Service App
cd service_app
flutter pub get
flutter run -d (windows|macos|android) --verbose (--release)
```

## Module Documentation

---

### **CONTROL TOOL**

| Field | Description |
| :--- | :--- |
| **Module Path** | `control_tool/` |
| **Type** | App |
| **Purpose/Goal** | A comprehensive control application for managing Becker motor systems including Centronic PLUS, EVO, Timecontrol, and CC Eleven devices. |

**Key Features/Functionality:**
* Provides unified interface for controlling multiple Becker motor protocols
* Real-time device monitoring and configuration management
* Bluetooth Low Energy connectivity for wireless device control
* Device discovery and pairing capabilities

**Dependencies/Integrations (External):**
* Flutter framework with Provider state management
* Multi-transport layer for cross-platform communication

**Summary:**
The Control Tool serves as the primary application for professionals to configure and manage Becker motor systems. It uses a modular architecture where each motor protocol (Centronic PLUS, EVO, Timecontrol, CC Eleven) is implemented as a separate module, allowing for flexible device management and real-time control capabilities across different communication protocols.

---

### **INSTALL TOOL**

| Field | Description |
| :--- | :--- |
| **Module Path** | `install_tool/` |
| **Type** | App |
| **Purpose/Goal** | A specialized installation and setup tool for Becker Centronic PLUS systems, designed for professional installers and technicians. |

**Key Features/Functionality:**
* Device installation wizard for Centronic PLUS systems
* Firmware update capabilities and version management
* System configuration and calibration tools
* Installation documentation and manual access

**Dependencies/Integrations (External):**
* Flutter framework with modular architecture
* Multi-transport communication layer
* File system integration for firmware updates

**Summary:**
The Install Tool is specifically designed for the professional installation market, providing a streamlined interface for setting up Becker motor systems. It includes comprehensive device configuration options, firmware management capabilities, and integrates with the modular protocol system to support various Becker motor types during installation and commissioning processes.

---

### **SERVICE APP**

| Field | Description |
| :--- | :--- |
| **Module Path** | `service_app/` |
| **Type** | App |
| **Purpose/Goal** | A lightweight service application providing basic functionality and utilities for Becker motor systems. |

**Key Features/Functionality:**
* Basic device connectivity and status monitoring
* Simple configuration interfaces
* Service and maintenance utilities

**Dependencies/Integrations (External):**
* Flutter framework with minimal dependencies
* UI Common library for shared components

**Summary:**
The Service App represents a simplified version of the control tools, focusing on essential functionality for basic device management and service operations. It leverages the shared UI components from the ui_common plugin while maintaining a lightweight footprint for quick service tasks and basic device interactions.

---

### **MODULES_COMMON**

| Field | Description |
| :--- | :--- |
| **Module Path** | `modules/modules_common/` |
| **Type** | Package/Library |
| **Purpose/Goal** | A shared library providing common functionality, utilities, and base classes used across all Becker applications. |

**Key Features/Functionality:**
* Internationalization (i18n) support and localization utilities
* Common UI components and navigation patterns
* Database integration with SQLite
* HTTP client and API communication utilities

**Dependencies/Integrations (External):**
* Provider for state management
* SQLite for local data storage
* HTTP package for network communication
* Flutter localization framework

**Summary:**
Modules Common serves as the foundation library for all Becker applications, providing essential shared functionality including internationalization support, common UI patterns, database operations, and network communication. It acts as a central repository for reusable code, ensuring consistency across different applications while reducing code duplication and maintenance overhead.

---

### **MOD_CEN_PLUS**

| Field | Description |
| :--- | :--- |
| **Module Path** | `modules/mod_cen_plus/` |
| **Type** | Package/Library |
| **Purpose/Goal** | A complete implementation module for Centronic PLUS motor control protocol, providing device management and configuration capabilities. |

**Key Features/Functionality:**
* Centronic PLUS protocol implementation with node management
* Device configuration and parameter adjustment
* Over-the-air (OTA) firmware update capabilities
* Real-time device monitoring and status reporting

**Dependencies/Integrations (External):**
* Centronic Plus protocol library
* Multi-transport communication layer
* Provider for state management

**Summary:**
The Centronic PLUS module provides comprehensive support for the Centronic PLUS motor control protocol, including device discovery, configuration management, and firmware updates. It implements a complete device management system with real-time monitoring capabilities and integrates seamlessly with the multi-transport layer for cross-platform communication with Centronic PLUS devices.

---

### **MOD_EVO**

| Field | Description |
| :--- | :--- |
| **Module Path** | `modules/mod_evo/` |
| **Type** | Package/Library |
| **Purpose/Goal** | A specialized module for EVO motor control systems, providing configuration and control interfaces for EVO-compatible devices. |

**Key Features/Functionality:**
* EVO protocol implementation with Bluetooth Low Energy connectivity
* Motor profile management and configuration
* Speed and position control interfaces
* Special function configuration and end-position settings

**Dependencies/Integrations (External):**
* EVO protocol library
* Bluetooth Low Energy communication
* Provider for state management

**Summary:**
The EVO module implements the complete EVO motor control protocol with focus on professional motor management. It provides intuitive interfaces for configuring motor profiles, adjusting speed settings, and managing special functions. The module uses Bluetooth Low Energy for wireless communication and integrates with the shared navigation system for consistent user experience across different motor types.

---

### **MOD_TIMECONTROL**

| Field | Description |
| :--- | :--- |
| **Module Path** | `modules/mod_timecontrol/` |
| **Type** | Package/Library |
| **Purpose/Goal** | A comprehensive module for Timecontrol motor systems, providing time-based automation and scheduling capabilities. |

**Key Features/Functionality:**
* Time-based motor control and scheduling
* Astronomical calculations for sun protection systems
* Preset configuration and operation mode management
* Real-time clock synchronization and location-based settings

**Dependencies/Integrations (External):**
* Timecontrol protocol library
* Geolocator for location services
* Provider for state management

**Summary:**
The Timecontrol module provides advanced time-based automation for motor systems, particularly suited for sun protection and automated shading applications. It includes sophisticated astronomical calculations, preset management, and location-based scheduling. The module integrates with system location services to provide accurate sun position calculations and automated motor control based on time and environmental conditions.

---

### **MOD_CC_ELEVEN**

| Field | Description |
| :--- | :--- |
| **Module Path** | `modules/mod_cc_eleven/` |
| **Type** | Package/Library |
| **Purpose/Goal** | A specialized module for CC Eleven motor control systems, providing advanced device management and group control capabilities. |

**Key Features/Functionality:**
* CC Eleven protocol implementation with dual-service Bluetooth support
* Group management and synchronized motor control
* Advanced device configuration and settings management
* Integration with Centronic PLUS for hybrid systems

**Dependencies/Integrations (External):**
* CC Eleven protocol library
* Centronic Plus protocol integration
* Multi-transport communication layer

**Summary:**
The CC Eleven module provides advanced motor control capabilities with support for group operations and hybrid systems. It implements a sophisticated device management system that can handle both CC Eleven and Centronic PLUS protocols simultaneously, enabling complex motor control scenarios with synchronized group operations and advanced configuration options.

---

### **MOD_XCF**

| Field | Description |
| :--- | :--- |
| **Module Path** | `modules/mod_xcf/` |
| **Type** | Package/Library |
| **Purpose/Goal** | A module for XCF motor control systems, providing configuration wizards and setup tools for complex motor installations. |

**Key Features/Functionality:**
* XCF protocol implementation with setup wizard interface
* Project configuration and manufacturer settings
* Monitoring and alert system for motor status
* Advanced parameter configuration and maintenance tools

**Dependencies/Integrations (External):**
* XCF protocol library
* Provider for state management
* Multi-transport communication layer

**Summary:**
The XCF module provides comprehensive support for XCF motor control systems with a focus on professional installation and configuration. It includes a step-by-step setup wizard for complex installations, advanced monitoring capabilities, and detailed configuration options. The module is designed to handle sophisticated motor control scenarios with extensive parameter customization and real-time status monitoring.

---

### **MOD_UPDATE_FILE**

| Field | Description |
| :--- | :--- |
| **Module Path** | `modules/mod_update_file/` |
| **Type** | Package/Library |
| **Purpose/Goal** | A utility module providing file management and update capabilities for firmware and configuration files across Becker systems. |

**Key Features/Functionality:**
* File loading and parsing utilities for update packages
* Version management and compatibility checking
* Installation manual and documentation access
* Update synchronization and validation

**Dependencies/Integrations (External):**
* HTTP client for remote file access
* File system integration
* Version management utilities

**Summary:**
The Update File module provides essential file management capabilities for system updates and documentation access. It handles the loading and parsing of update packages, manages version compatibility, and provides access to installation documentation. This module is crucial for maintaining system integrity during firmware updates and ensuring users have access to current documentation and installation guides.

---

### **UI_COMMON**

| Field | Description |
| :--- | :--- |
| **Module Path** | `plugins/ui_common/` |
| **Type** | Package/Library |
| **Purpose/Goal** | A shared UI component library providing standardized widgets, themes, and navigation patterns for all Becker applications. |

**Key Features/Functionality:**
* Standardized UI components and widgets
* Internationalization support with translation management
* Navigation patterns and routing utilities
* Theme and styling consistency across applications

**Dependencies/Integrations (External):**
* Go Router for navigation
* Provider for state management
* Flutter localization framework
* Package info for app metadata

**Summary:**
UI Common serves as the design system foundation for all Becker applications, ensuring visual and functional consistency across the entire product suite. It provides reusable components, standardized navigation patterns, and comprehensive internationalization support. This library is essential for maintaining a cohesive user experience while enabling rapid development of new features and applications.

---

### **MULTI_TRANSPORT**

| Field | Description |
| :--- | :--- |
| **Module Path** | `plugins/multi_transport/` |
| **Type** | Package/Library |
| **Purpose/Goal** | A platform-independent transport layer providing unified communication interfaces for Bluetooth, serial, and socket connections. |

**Key Features/Functionality:**
* Unified interface for multiple communication protocols
* Bluetooth Low Energy, serial, and socket transport implementations
* Cross-platform device discovery and connection management
* Protocol abstraction layer for consistent API usage

**Dependencies/Integrations (External):**
* Platform-specific Bluetooth implementations
* Serial communication libraries
* Socket networking capabilities

**Summary:**
Multi-transport provides a crucial abstraction layer that enables consistent communication across different platforms and protocols. It unifies Bluetooth Low Energy, serial, and socket communications under a single interface, allowing modules to communicate with devices regardless of the underlying transport mechanism. This design enables the same code to work across different platforms while providing optimal performance for each communication method.

---

### **CENTRONIC_PLUS_PROTOCOL**

| Field | Description |
| :--- | :--- |
| **Module Path** | `plugins/centronic_plus/` |
| **Type** | Package/Library |
| **Purpose/Goal** | A pure Dart implementation of the Centronic PLUS communication protocol, providing low-level protocol handling and data structures. |

**Key Features/Functionality:**
* Complete Centronic PLUS protocol implementation
* Message encoding and decoding utilities
* Protocol state management and error handling
* Integration with multi-transport layer

**Dependencies/Integrations (External):**
* Multi-transport interface
* Hex encoding utilities
* Version management

**Summary:**
The Centronic Plus Protocol library provides the core implementation of the Centronic PLUS communication protocol in pure Dart. It handles all low-level protocol operations including message encoding, decoding, and state management. This library is essential for any application that needs to communicate with Centronic PLUS devices, providing a robust and reliable foundation for higher-level modules and applications.

---

### **HYDROGEN_FLUTTER**

| Field | Description |
| :--- | :--- |
| **Module Path** | `plugins/hydrogen_flutter/` |
| **Type** | Package/Library |
| **Purpose/Goal** | A cryptographic library wrapper providing secure communication and data protection capabilities for Becker applications. |

**Key Features/Functionality:**
* Cryptographic functions for secure communication
* Data encryption and decryption capabilities
* Security utilities for authentication and integrity
* Cross-platform cryptographic operations

**Dependencies/Integrations (External):**
* FFI (Foreign Function Interface) for native library integration
* Platform-specific cryptographic implementations

**Summary:**
Hydrogen Flutter provides essential cryptographic capabilities for secure communication in Becker applications. It wraps native cryptographic libraries using FFI to provide cross-platform security functions. This library is crucial for ensuring secure communication with devices and protecting sensitive configuration data during transmission and storage.

---

### **WIN_BLE**

| Field | Description |
| :--- | :--- |
| **Module Path** | `plugins/win_ble/` |
| **Type** | Package/Library |
| **Purpose/Goal** | A Windows-specific Bluetooth Low Energy plugin enabling BLE functionality for Flutter applications on Windows platforms. |

**Key Features/Functionality:**
* Windows Bluetooth Low Energy implementation
* Device discovery and connection management
* BLE service and characteristic access
* Windows-specific BLE server capabilities

**Dependencies/Integrations (External):**
* Windows Bluetooth APIs
* Native Windows BLE server executable

**Summary:**
Win BLE provides essential Bluetooth Low Energy functionality for Windows platforms, enabling Flutter applications to communicate with BLE devices on Windows. It includes both client and server capabilities, with a native Windows executable for BLE server functionality. This plugin is crucial for Windows users who need to connect to and control Becker motor systems via Bluetooth Low Energy.

---

### **GETSTRINGS**

| Field | Description |
| :--- | :--- |
| **Module Path** | `bin/getStrings/` |
| **Type** | Package/Library |
| **Purpose/Goal** | A utility tool for extracting and managing internationalization strings from the codebase, supporting translation workflow. |

**Key Features/Functionality:**
* Automatic extraction of translatable strings from Dart code
* Generation of .pot files for translation
* Integration with translation workflow tools
* Code analysis for i18n string identification

**Dependencies/Integrations (External):**
* Dart analyzer for code parsing
* Gettext parser for translation file handling

**Summary:**
GetStrings is a specialized development tool that automates the extraction of internationalization strings from the codebase. It analyzes Dart code to identify translatable strings and generates .pot files that can be used by translators. This tool is essential for maintaining the multi-language support across all Becker applications and ensures that new strings are properly identified and included in the translation workflow.

---

### **TRANSLATOR**

| Field | Description |
| :--- | :--- |
| **Module Path** | `bin/translator/` |
| **Type** | Package/Library |
| **Purpose/Goal** | An AI-powered translation tool that assists in translating application strings and documentation using modern translation services. |

**Key Features/Functionality:**
* AI-powered translation using OpenAI services
* Automated translation workflow integration
* OpenAPI integration for translation services
* Batch translation processing capabilities

**Dependencies/Integrations (External):**
* OpenAI Dart client for AI translation
* OpenAPI generator for service integration

**Summary:**
The Translator tool leverages modern AI translation services to automate the translation of application strings and documentation. It integrates with OpenAI services to provide high-quality translations and includes OpenAPI integration for flexible service configuration. This tool significantly accelerates the internationalization process and helps maintain consistency across multiple language versions of Becker applications.

---

## Development Tasks

### Extract i18n strings
Übersetzungsschlüssel werden extrahiert und in strings.pot gespeichert
<br>
### Mason: gen centronic_plus
Erzeugt Telegrammdecoder anhand der config Datei
<br>
### Doc: centronic_plus
Erzeugt Dokumentation
<br>
### Test: centronic_plus
Automatisierte Tests ausführen
<br>
<br>

## Repository Structure

This monorepository contains:

- **Applications**: Complete Flutter apps (control_tool, install_tool, service_app)
- **Modules**: Feature-specific packages (mod_cen_plus, mod_evo, mod_timecontrol, etc.)
- **Plugins**: Reusable libraries and protocol implementations
- **Utilities**: Development tools for i18n and translation management

Each module is designed to be independently maintainable while sharing common functionality through the modules_common and ui_common libraries.
