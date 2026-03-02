# IPBar

A macOS menu bar tool that displays your IP address. Monitors network interfaces in real time and shows the current IP in the menu bar.

## Features

- Real-time IP address display in the menu bar
- View details of all network interfaces (Wi-Fi, Ethernet, VPN, etc.)
- One-click IP address copy
- IPv4 / IPv6 support
- Chinese / English language switching (Cmd+, to open settings)
- Wi-Fi name display (requires Location Services authorization)

## Requirements

- macOS 13.0+
- Xcode 16.0+
- Swift 6.0

## Build & Run

```bash
# Build
make build

# Build and run
make run

# Clean
make clean
```

## Project Structure

```
IPBar/
├── IPBarApp.swift              # App entry point
├── Models/
│   ├── NetworkInterface.swift  # Network interface model
│   └── AppLanguage.swift       # Language manager (i18n)
├── Services/                   # Network monitoring service
├── ViewModels/
│   └── NetworkViewModel.swift  # View model
└── Views/
    ├── MenuBarPanel.swift      # Menu bar main panel
    ├── ActiveInterfaceCard.swift
    ├── InterfaceDetailView.swift
    ├── InterfaceSummaryRow.swift
    ├── ActionButtonsBar.swift
    └── SettingsWindow.swift    # Settings window
```

## License

MIT
