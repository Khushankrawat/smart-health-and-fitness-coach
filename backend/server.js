// server.js
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Security middleware
if (process.env.HELMET_ENABLED === 'true') {
    app.use(helmet());
}

// Rate limiting
const limiter = rateLimit({
    windowMs: parseInt(process.env.API_RATE_WINDOW_MS) || 15 * 60 * 1000, // 15 minutes
    max: parseInt(process.env.API_RATE_LIMIT) || 100, // limit each IP to 100 requests per windowMs
    message: 'Too many requests from this IP, please try again later.'
});
app.use('/api/', limiter);

// CORS configuration
const corsOptions = {
    origin: process.env.CORS_ORIGIN || 'http://localhost:3000',
    credentials: true,
    optionsSuccessStatus: 200
};
app.use(cors(corsOptions));

// Body parsing middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// MongoDB connection with security options
mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/fitness-coach-dev', {
    useNewUrlParser: true,
    useUnifiedTopology: true,
    useCreateIndex: true,
    useFindAndModify: false,
    serverSelectionTimeoutMS: 5000,
    socketTimeoutMS: 45000,
});

mongoose.connection.on('error', (err) => {
    console.error('MongoDB connection error:', err);
});

mongoose.connection.on('connected', () => {
    console.log('Connected to MongoDB');
});

// Models
const UserSchema = new mongoose.Schema({
    email: { type: String, required: true, unique: true },
    password: { type: String, required: true },
    name: { type: String, required: true },
    createdAt: { type: Date, default: Date.now }
});

const WorkoutSchema = new mongoose.Schema({
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    exerciseType: { type: String, required: true },
    startTime: { type: Date, required: true },
    endTime: { type: Date },
    duration: { type: Number, required: true },
    repetitions: { type: Number, required: true },
    formScore: { type: Number, required: true },
    feedback: [String],
    createdAt: { type: Date, default: Date.now }
});

const User = mongoose.model('User', UserSchema);
const Workout = mongoose.model('Workout', WorkoutSchema);

// Auth middleware
const authenticateToken = (req, res, next) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if (!token) {
        return res.status(401).json({ error: 'Access token required' });
    }

    jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
        if (err) {
            return res.status(403).json({ error: 'Invalid token' });
        }
        req.user = user;
        next();
    });
};

// Routes

// Auth routes
app.post('/api/auth/register', async (req, res) => {
    try {
        const { email, password, name } = req.body;
        
        // Check if user exists
        const existingUser = await User.findOne({ email });
        if (existingUser) {
            return res.status(400).json({ error: 'User already exists' });
        }

        // Hash password
        const hashedPassword = await bcrypt.hash(password, 10);

        // Create user
        const user = new User({ email, password: hashedPassword, name });
        await user.save();

        // Generate token
        const token = jwt.sign(
            { userId: user._id, email: user.email },
            process.env.JWT_SECRET,
            { expiresIn: process.env.JWT_EXPIRES_IN || '24h' }
        );

        res.json({
            token,
            user: {
                id: user._id,
                email: user.email,
                name: user.name
            }
        });
    } catch (error) {
        res.status(500).json({ error: 'Server error' });
    }
});

app.post('/api/auth/login', async (req, res) => {
    try {
        const { email, password } = req.body;

        // Find user
        const user = await User.findOne({ email });
        if (!user) {
            return res.status(400).json({ error: 'Invalid credentials' });
        }

        // Check password
        const isValidPassword = await bcrypt.compare(password, user.password);
        if (!isValidPassword) {
            return res.status(400).json({ error: 'Invalid credentials' });
        }

        // Generate token
        const token = jwt.sign(
            { userId: user._id, email: user.email },
            process.env.JWT_SECRET,
            { expiresIn: process.env.JWT_EXPIRES_IN || '24h' }
        );

        res.json({
            token,
            user: {
                id: user._id,
                email: user.email,
                name: user.name
            }
        });
    } catch (error) {
        res.status(500).json({ error: 'Server error' });
    }
});

// Workout routes
app.post('/api/workouts', authenticateToken, async (req, res) => {
    try {
        const { id, exerciseType, startTime, endTime, duration, repetitions, formScore, feedback } = req.body;

        const workout = new Workout({
            userId: req.user.userId,
            exerciseType,
            startTime: new Date(startTime),
            endTime: endTime ? new Date(endTime) : null,
            duration,
            repetitions,
            formScore,
            feedback
        });

        await workout.save();

        res.json({
            success: true,
            message: 'Workout saved successfully',
            workout
        });
    } catch (error) {
        res.status(500).json({ error: 'Server error' });
    }
});

app.get('/api/workouts', authenticateToken, async (req, res) => {
    try {
        const workouts = await Workout.find({ userId: req.user.userId })
            .sort({ startTime: -1 })
            .limit(50);

        res.json(workouts);
    } catch (error) {
        res.status(500).json({ error: 'Server error' });
    }
});

// Analytics route
app.get('/api/analytics/workouts', authenticateToken, async (req, res) => {
    try {
        const userId = req.user.userId;
        
        // Get workout statistics
        const totalWorkouts = await Workout.countDocuments({ userId });
        const workouts = await Workout.find({ userId });
        
        const totalRepetitions = workouts.reduce((sum, workout) => sum + workout.repetitions, 0);
        const averageFormScore = workouts.length > 0 
            ? workouts.reduce((sum, workout) => sum + workout.formScore, 0) / workouts.length 
            : 0;

        // Weekly progress (last 4 weeks)
        const weeklyProgress = [];
        for (let i = 3; i >= 0; i--) {
            const weekStart = new Date();
            weekStart.setDate(weekStart.getDate() - (i * 7));
            const weekEnd = new Date(weekStart);
            weekEnd.setDate(weekEnd.getDate() + 7);

            const weekWorkouts = await Workout.find({
                userId,
                startTime: { $gte: weekStart, $lt: weekEnd }
            });

            const weekAverageScore = weekWorkouts.length > 0
                ? weekWorkouts.reduce((sum, w) => sum + w.formScore, 0) / weekWorkouts.length
                : 0;

            weeklyProgress.push({
                week: weekStart.toISOString().split('T')[0],
                workouts: weekWorkouts.length,
                averageScore: weekAverageScore
            });
        }

        // Exercise breakdown
        const exerciseBreakdown = await Workout.aggregate([
            { $match: { userId: new mongoose.Types.ObjectId(userId) } },
            {
                $group: {
                    _id: '$exerciseType',
                    count: { $sum: 1 },
                    averageScore: { $avg: '$formScore' }
                }
            },
            {
                $project: {
                    exerciseType: '$_id',
                    count: 1,
                    averageScore: { $round: ['$averageScore', 2] }
                }
            }
        ]);

        res.json({
            totalWorkouts,
            totalRepetitions,
            averageFormScore: Math.round(averageFormScore * 100) / 100,
            weeklyProgress,
            exerciseBreakdown
        });
    } catch (error) {
        res.status(500).json({ error: 'Server error' });
    }
});

// Health check
app.get('/api/health', (req, res) => {
    res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});

module.exports = app;

