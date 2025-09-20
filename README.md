# rapidtradeai - Crypto Trading Bot Platform

A comprehensive Flutter-based cryptocurrency trading platform with automated bot trading, real-time market data, and advanced portfolio management features.

## 🚀 Features

### 🤖 **Automated Trading Bots**
- **Smart Trading Algorithms**: Advanced bot strategies for automated trading
- **Multi-Exchange Support**: Binance, Huobi, and other major exchanges
- **Risk Management**: Built-in stop-loss, take-profit, and trailing stop features
- **Real-time Monitoring**: Live bot performance tracking and analytics

### 📊 **Market Analysis**
- **Real-time Price Data**: Live cryptocurrency prices and market data
- **Technical Indicators**: Advanced charting with multiple indicators
- **Market Trends**: Comprehensive market analysis and insights
- **Price Alerts**: Custom price notifications and alerts

### 💼 **Portfolio Management**
- **Multi-Wallet Support**: Manage multiple cryptocurrency wallets
- **Transaction History**: Detailed trading and transaction records
- **P&L Tracking**: Real-time profit and loss calculations
- **Asset Allocation**: Portfolio diversification tools

### 🔐 **Security Features**
- **Secure Authentication**: Multi-factor authentication support
- **API Key Management**: Secure exchange API integration
- **Data Encryption**: End-to-end encryption for sensitive data
- **Audit Trails**: Comprehensive logging and monitoring

## 📱 **Platform Support**

- ✅ **Android** - Native Android app (Available on Play Store)
- ✅ **iOS** - Native iOS app
- ✅ **Web** - Progressive Web App (PWA)
- ✅ **Windows** - Desktop application
- ✅ **macOS** - Desktop application
- ✅ **Linux** - Desktop application

## 🛠️ **Technology Stack**

- **Frontend**: Flutter (Dart)
- **State Management**: Provider
- **HTTP Client**: HTTP package
- **Local Storage**: SharedPreferences
- **Charts**: Syncfusion Flutter Charts
- **Authentication**: JWT-based authentication
- **Real-time Data**: HTTP polling (WebSocket support planned)
- **Notifications**: Local notifications

## 📋 **Prerequisites**

- Flutter SDK (>=3.0.0)
- Dart SDK (>=2.19.0)
- Android Studio / VS Code
- Git

## 🚀 **Getting Started**

### **1. Clone the Repository**
```bash
git clone https://github.com/artichaudharybrt/rapidtradeai.git
cd rapidtradeai
```

### **2. Install Dependencies**
```bash
flutter pub get
```

### **3. Configure API Endpoints**
Update the API endpoints in `lib/data/api.dart`:
```dart
const String mainUrl = "https://rapidtradeai.com/";
```

### **4. Run the Application**

**For Web:**
```bash
flutter run -d chrome
```

**For Android:**
```bash
flutter run -d android
```

**For iOS:**
```bash
flutter run -d ios
```

## 🏗️ **Project Structure**

```
lib/
├── src/
│   ├── Service/           # Background services and API clients
│   ├── homepage/          # Home screen and dashboard
│   ├── user/             # Authentication screens (login/signup)
│   ├── tabscreen/        # Main navigation
│   ├── quantitative/     # Trading bot logic
│   └── widget/           # Reusable UI components
├── method/               # Provider classes and business logic
├── data/                 # API endpoints and constants
└── main.dart            # Application entry point
```

## 🔧 **Recent Performance Optimizations**

### **v2.0.0 - Authentication & Network Fixes**
- ✅ **Fixed Login/Signup Issues**: Resolved authentication problems with proper HTTP headers
- ✅ **Enhanced Error Handling**: Added comprehensive error messages and timeout handling
- ✅ **Debug Logging**: Implemented detailed request/response logging for troubleshooting
- ✅ **Network Optimization**: Added 15-second timeouts and proper exception handling
- ✅ **Code Quality**: Improved code structure and documentation

### **Key Technical Improvements:**
- Added `Content-Type: application/json` headers to all API requests
- Implemented proper timeout handling for network requests
- Enhanced exception handling for SocketException and TimeoutException
- Added debug logging for API requests and responses
- Improved user feedback with specific error messages

## 📱 **Build Instructions**

### **Android Release Build**
```bash
flutter build appbundle --release
```
The AAB file will be generated in `build/app/outputs/bundle/release/`

### **iOS Release Build**
```bash
flutter build ios --release
```

### **Web Build**
```bash
flutter build web --release
```

## 🤝 **Contributing**

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 🐛 **Known Issues & Solutions**

### **Authentication Issues** ✅ FIXED
- **Problem**: Login/signup not working
- **Solution**: Added proper HTTP headers and timeout handling
- **Status**: Resolved in v2.0.0

### **Bot Service Timeouts** ⚠️ IN PROGRESS
- **Problem**: Connection timeouts in bot service
- **Solution**: Implementing retry logic and connection pooling
- **Status**: Under development

### **Web CORS Issues** ⚠️ KNOWN LIMITATION
- **Problem**: Some API calls blocked by CORS policy in web browsers
- **Solution**: Use mobile app or configure server CORS headers
- **Status**: Server-side configuration needed

## 📄 **License**

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 **Support**

For support and questions:
- 🐛 Issues: [GitHub Issues](https://github.com/artichaudharybrt/rapidtradeai/issues)
- 📧 Email: dev2.brt@gmail.com

## ⚠️ **Disclaimer**

**Trading cryptocurrencies involves substantial risk and may not be suitable for all investors. Past performance is not indicative of future results. Please trade responsibly and only invest what you can afford to lose.**

---

**Made with ❤️ using Flutter**