# Smart Health and Fitness Coach

A SwiftUI-based fitness tracking app with real-time pose analysis and form feedback.

## 🔒 Security Features

This project implements several security best practices:

### iOS App Security
- **Keychain Storage**: Sensitive data (auth tokens, user data) stored securely in iOS Keychain
- **Environment Configuration**: API endpoints and sensitive configs managed through environment variables
- **Secure Network Communication**: HTTPS-only API communication with proper authentication headers
- **No Hardcoded Secrets**: All sensitive information externalized to configuration files

### Backend Security
- **Environment Variables**: All secrets and configuration stored in `.env` files (never committed)
- **JWT Authentication**: Secure token-based authentication with configurable expiration
- **Rate Limiting**: API rate limiting to prevent abuse
- **Security Headers**: Helmet.js for security headers
- **CORS Configuration**: Proper CORS setup for cross-origin requests
- **Input Validation**: Request body size limits and validation

## 🚀 Getting Started

### Prerequisites
- Xcode 15.0+
- iOS 18.5+
- Node.js 18+
- MongoDB

### iOS App Setup

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd smart-health-and-fitness-coach
   ```

2. **Configure Environment Variables**
   - Create a `Config.plist` file in your Xcode project
   - Add your backend URL:
     ```xml
     <key>BackendURL</key>
     <string>https://your-backend-api.com/api</string>
     ```

3. **Build and Run**
   - Open `smart health and fitness coach.xcodeproj` in Xcode
   - Build and run on simulator or device

### Backend Setup

1. **Install Dependencies**
   ```bash
   cd backend
   npm install
   ```

2. **Environment Configuration**
   ```bash
   # Copy the example environment file
   cp env.example .env
   
   # Edit .env with your actual values
   nano .env
   ```

3. **Required Environment Variables**
   ```env
   # Server
   PORT=3000
   NODE_ENV=production
   
   # Database
   MONGODB_URI=mongodb://localhost:27017/fitness-coach-prod
   
   # Security
   JWT_SECRET=your-super-secure-jwt-secret-key
   JWT_EXPIRES_IN=24h
   
   # CORS
   CORS_ORIGIN=https://your-frontend-domain.com
   ```

4. **Start the Server**
   ```bash
   npm start
   ```

## 🔐 Security Checklist

### Before Deploying to Production

- [ ] **Change Default Secrets**: Update all default JWT secrets and API keys
- [ ] **Use HTTPS**: Ensure all API endpoints use HTTPS
- [ ] **Environment Variables**: Move all sensitive data to environment variables
- [ ] **Database Security**: Use MongoDB Atlas or secure database with authentication
- [ ] **API Rate Limiting**: Configure appropriate rate limits for your use case
- [ ] **CORS Configuration**: Set proper CORS origins for production domains
- [ ] **Security Headers**: Enable Helmet.js security headers
- [ ] **Input Validation**: Implement proper input validation and sanitization
- [ ] **Error Handling**: Avoid exposing sensitive information in error messages
- [ ] **Logging**: Implement secure logging without sensitive data

### iOS App Security

- [ ] **Keychain Usage**: Verify sensitive data is stored in Keychain, not UserDefaults
- [ ] **Certificate Pinning**: Consider implementing SSL certificate pinning
- [ ] **App Transport Security**: Configure ATS settings in Info.plist
- [ ] **Code Obfuscation**: Consider code obfuscation for production builds
- [ ] **Debug Information**: Remove debug logging and sensitive information from production builds

## 📁 Project Structure

```
smart-health-and-fitness-coach/
├── smart health and fitness coach/          # iOS App
│   ├── Configuration/
│   │   └── AppConfig.swift                  # App configuration
│   ├── Services/
│   │   ├── BackendService.swift            # API service
│   │   ├── KeychainManager.swift           # Secure storage
│   │   └── ExerciseAnalyzer.swift          # Exercise analysis
│   ├── Models/
│   │   ├── ExerciseType.swift              # Exercise definitions
│   │   └── PoseLandmark.swift              # Pose data models
│   └── Views/
│       └── CameraView.swift                # Camera and pose detection
├── backend/                                 # Node.js Backend
│   ├── server.js                           # Main server file
│   ├── package.json                        # Dependencies
│   └── env.example                         # Environment template
└── .gitignore                              # Git ignore rules
```

## 🛡️ Security Best Practices

### For Developers

1. **Never commit sensitive data** to version control
2. **Use environment variables** for all configuration
3. **Implement proper authentication** and authorization
4. **Validate all inputs** on both client and server
5. **Use HTTPS** for all communications
6. **Store sensitive data securely** (Keychain for iOS, encrypted storage for backend)
7. **Implement rate limiting** to prevent abuse
8. **Use security headers** (Helmet.js for Express)
9. **Regular security updates** for dependencies
10. **Monitor and log** security events

### For Deployment

1. **Use production-grade secrets** (generate with `openssl rand -base64 32`)
2. **Configure proper CORS** for your domain
3. **Use MongoDB Atlas** or secure database hosting
4. **Enable HTTPS** with valid SSL certificates
5. **Set up monitoring** and alerting
6. **Regular backups** of database
7. **Update dependencies** regularly
8. **Use container security** if deploying with Docker

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Ensure all security checks pass
5. Submit a pull request

## ⚠️ Security Notice

If you discover a security vulnerability, please report it responsibly:
1. Do not open a public issue
2. Contact the maintainers privately
3. Allow time for the issue to be addressed before public disclosure

---

**Remember**: Security is an ongoing process. Regularly review and update your security measures as threats evolve.
