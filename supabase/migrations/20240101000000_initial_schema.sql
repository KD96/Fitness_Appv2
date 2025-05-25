-- =====================================================
-- FITNESS APP MVP - INITIAL SCHEMA
-- =====================================================

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- =====================================================
-- ENUMS
-- =====================================================

-- User fitness levels
CREATE TYPE fitness_level AS ENUM (
    'beginner',
    'intermediate', 
    'advanced',
    'expert',
    'master'
);

-- Workout types
CREATE TYPE workout_type AS ENUM (
    'running',
    'walking',
    'cycling',
    'strength'
);

-- Workout intensity levels
CREATE TYPE workout_intensity AS ENUM (
    'low',
    'medium',
    'high'
);

-- Reward categories
CREATE TYPE reward_category AS ENUM (
    'fitness',
    'nutrition',
    'wellness',
    'gear',
    'supplements'
);

-- Social activity types
CREATE TYPE social_activity_type AS ENUM (
    'workout_completed',
    'achievement_unlocked',
    'friend_joined',
    'level_up',
    'reward_redeemed'
);

-- User appearance preferences
CREATE TYPE appearance_mode AS ENUM (
    'light',
    'dark',
    'system'
);

-- =====================================================
-- CORE TABLES
-- =====================================================

-- Users table (extends Supabase auth.users)
CREATE TABLE public.users (
    id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    first_name TEXT GENERATED ALWAYS AS (split_part(name, ' ', 1)) STORED,
    profile_image_url TEXT,
    bio TEXT DEFAULT '',
    
    -- Fitness data
    token_balance DECIMAL(10,2) DEFAULT 0.0,
    experience_points INTEGER DEFAULT 0,
    current_level fitness_level DEFAULT 'beginner',
    workout_streak INTEGER DEFAULT 0,
    
    -- Preferences
    appearance_mode appearance_mode DEFAULT 'system',
    notifications_enabled BOOLEAN DEFAULT true,
    social_privacy_enabled BOOLEAN DEFAULT false,
    
    -- Metadata
    join_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_active TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Workouts table
CREATE TABLE public.workouts (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    
    -- Basic workout info
    name TEXT NOT NULL,
    type workout_type NOT NULL,
    duration_minutes INTEGER NOT NULL CHECK (duration_minutes > 0),
    calories_burned DECIMAL(8,2) DEFAULT 0,
    tokens_earned DECIMAL(8,2) DEFAULT 0,
    notes TEXT,
    completed BOOLEAN DEFAULT false,
    
    -- Metrics (nullable based on workout type)
    distance_meters DECIMAL(10,2), -- running, walking, cycling
    steps INTEGER, -- running, walking
    average_heart_rate INTEGER, -- all types
    max_heart_rate INTEGER, -- all types
    min_heart_rate INTEGER, -- all types
    laps INTEGER, -- swimming (future)
    reps INTEGER, -- strength
    sets INTEGER, -- strength
    weight_kg DECIMAL(6,2), -- strength
    intensity workout_intensity, -- yoga, hiit, other
    
    -- Metadata
    workout_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Rewards table
CREATE TABLE public.rewards (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    
    -- Reward info
    name TEXT NOT NULL,
    description TEXT NOT NULL,
    category reward_category NOT NULL,
    token_cost DECIMAL(8,2) NOT NULL CHECK (token_cost > 0),
    image_url TEXT,
    partner_name TEXT,
    partner_logo_url TEXT,
    
    -- Availability
    is_featured BOOLEAN DEFAULT false,
    is_available BOOLEAN DEFAULT true,
    stock_quantity INTEGER, -- NULL = unlimited
    
    -- Metadata
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User purchased rewards
CREATE TABLE public.user_rewards (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    reward_id UUID REFERENCES public.rewards(id) ON DELETE CASCADE NOT NULL,
    
    -- Purchase info
    tokens_spent DECIMAL(8,2) NOT NULL,
    redemption_code TEXT,
    redeemed_at TIMESTAMP WITH TIME ZONE,
    
    -- Metadata
    purchased_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(user_id, reward_id, purchased_at)
);

-- Daily missions
CREATE TABLE public.missions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    
    -- Mission info
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    target_value INTEGER NOT NULL,
    reward_tokens DECIMAL(6,2) NOT NULL,
    mission_type TEXT NOT NULL, -- 'workout_duration', 'calories_burned', etc.
    
    -- Availability
    is_active BOOLEAN DEFAULT true,
    valid_from DATE DEFAULT CURRENT_DATE,
    valid_until DATE DEFAULT (CURRENT_DATE + INTERVAL '1 day'),
    
    -- Metadata
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User mission progress
CREATE TABLE public.user_mission_progress (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    mission_id UUID REFERENCES public.missions(id) ON DELETE CASCADE NOT NULL,
    
    -- Progress tracking
    current_progress INTEGER DEFAULT 0,
    completed BOOLEAN DEFAULT false,
    completed_at TIMESTAMP WITH TIME ZONE,
    
    -- Metadata
    started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(user_id, mission_id)
);

-- =====================================================
-- SOCIAL FEATURES
-- =====================================================

-- Friend relationships
CREATE TABLE public.friendships (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    requester_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    addressee_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    
    -- Status
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'declined', 'blocked')),
    
    -- Metadata
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(requester_id, addressee_id),
    CHECK (requester_id != addressee_id)
);

-- Social activities feed
CREATE TABLE public.social_activities (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    
    -- Activity info
    activity_type social_activity_type NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    metadata JSONB DEFAULT '{}',
    
    -- Related entities (nullable)
    workout_id UUID REFERENCES public.workouts(id) ON DELETE SET NULL,
    reward_id UUID REFERENCES public.rewards(id) ON DELETE SET NULL,
    
    -- Metadata
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Fitness events (group activities)
CREATE TABLE public.fitness_events (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    creator_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    
    -- Event info
    name TEXT NOT NULL,
    description TEXT NOT NULL,
    event_type workout_type NOT NULL,
    location TEXT,
    is_virtual BOOLEAN DEFAULT false,
    
    -- Scheduling
    event_date TIMESTAMP WITH TIME ZONE NOT NULL,
    duration_minutes INTEGER NOT NULL CHECK (duration_minutes > 0),
    max_participants INTEGER,
    
    -- Metadata
    image_icon TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Event participants
CREATE TABLE public.event_participants (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    event_id UUID REFERENCES public.fitness_events(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    
    -- Participation status
    status TEXT DEFAULT 'joined' CHECK (status IN ('joined', 'left', 'completed')),
    
    -- Metadata
    joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    UNIQUE(event_id, user_id)
);

-- =====================================================
-- ANALYTICS & TRACKING
-- =====================================================

-- User analytics events
CREATE TABLE public.analytics_events (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    
    -- Event info
    event_type TEXT NOT NULL,
    event_name TEXT NOT NULL,
    screen_name TEXT,
    metadata JSONB DEFAULT '{}',
    
    -- Session info
    session_id UUID,
    
    -- Metadata
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- FUNCTIONS & TRIGGERS
-- =====================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply updated_at triggers
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_workouts_updated_at BEFORE UPDATE ON public.workouts FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_rewards_updated_at BEFORE UPDATE ON public.rewards FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_friendships_updated_at BEFORE UPDATE ON public.friendships FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_fitness_events_updated_at BEFORE UPDATE ON public.fitness_events FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Function to calculate user level based on experience points
CREATE OR REPLACE FUNCTION calculate_user_level(xp INTEGER)
RETURNS fitness_level AS $$
BEGIN
    CASE 
        WHEN xp < 1000 THEN RETURN 'beginner';
        WHEN xp < 3000 THEN RETURN 'intermediate';
        WHEN xp < 6000 THEN RETURN 'advanced';
        WHEN xp < 10000 THEN RETURN 'expert';
        ELSE RETURN 'master';
    END CASE;
END;
$$ LANGUAGE plpgsql;

-- Function to update user level when experience points change
CREATE OR REPLACE FUNCTION update_user_level()
RETURNS TRIGGER AS $$
BEGIN
    NEW.current_level = calculate_user_level(NEW.experience_points);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to auto-update user level
CREATE TRIGGER update_user_level_trigger 
    BEFORE UPDATE OF experience_points ON public.users 
    FOR EACH ROW EXECUTE FUNCTION update_user_level();

-- Function to create social activity when workout is completed
CREATE OR REPLACE FUNCTION create_workout_social_activity()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.completed = true AND (OLD.completed IS NULL OR OLD.completed = false) THEN
        INSERT INTO public.social_activities (
            user_id,
            activity_type,
            title,
            description,
            workout_id,
            metadata
        ) VALUES (
            NEW.user_id,
            'workout_completed',
            'Completed a ' || NEW.type || ' workout',
            NEW.name || ' - ' || NEW.duration_minutes || ' minutes',
            NEW.id,
            jsonb_build_object(
                'workout_type', NEW.type,
                'duration_minutes', NEW.duration_minutes,
                'calories_burned', NEW.calories_burned,
                'tokens_earned', NEW.tokens_earned
            )
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for workout completion social activity
CREATE TRIGGER workout_completion_social_activity
    AFTER UPDATE ON public.workouts
    FOR EACH ROW EXECUTE FUNCTION create_workout_social_activity();

-- =====================================================
-- INDEXES FOR PERFORMANCE
-- =====================================================

-- User indexes
CREATE INDEX idx_users_email ON public.users(email);
CREATE INDEX idx_users_level ON public.users(current_level);
CREATE INDEX idx_users_last_active ON public.users(last_active);

-- Workout indexes
CREATE INDEX idx_workouts_user_id ON public.workouts(user_id);
CREATE INDEX idx_workouts_type ON public.workouts(type);
CREATE INDEX idx_workouts_date ON public.workouts(workout_date);
CREATE INDEX idx_workouts_completed ON public.workouts(completed);

-- Social indexes
CREATE INDEX idx_friendships_requester ON public.friendships(requester_id);
CREATE INDEX idx_friendships_addressee ON public.friendships(addressee_id);
CREATE INDEX idx_friendships_status ON public.friendships(status);
CREATE INDEX idx_social_activities_user ON public.social_activities(user_id);
CREATE INDEX idx_social_activities_type ON public.social_activities(activity_type);
CREATE INDEX idx_social_activities_created ON public.social_activities(created_at);

-- Analytics indexes
CREATE INDEX idx_analytics_user_id ON public.analytics_events(user_id);
CREATE INDEX idx_analytics_event_type ON public.analytics_events(event_type);
CREATE INDEX idx_analytics_created_at ON public.analytics_events(created_at);

-- =====================================================
-- INITIAL SAMPLE DATA
-- =====================================================

-- Sample rewards
INSERT INTO public.rewards (name, description, category, token_cost, is_featured, partner_name) VALUES
('Protein Shake', '25% off premium protein shake', 'nutrition', 50.00, true, 'NutriMax'),
('Gym Day Pass', 'Free day pass to premium gym', 'fitness', 100.00, true, 'FitLife Gym'),
('Yoga Class', 'Free online yoga session', 'wellness', 30.00, false, 'ZenFlow'),
('Running Shoes Discount', '20% off running shoes', 'gear', 150.00, true, 'SportGear'),
('Meditation App', '1 month free premium meditation', 'wellness', 75.00, false, 'MindfulApp'),
('Fitness Tracker', '15% off fitness tracker', 'gear', 200.00, true, 'TechFit'),
('Vitamin Supplements', '30% off vitamin pack', 'supplements', 80.00, false, 'HealthPlus'),
('Personal Training', '1 free personal training session', 'fitness', 250.00, true, 'ProTrainers');

-- Sample daily missions
INSERT INTO public.missions (title, description, target_value, reward_tokens, mission_type, valid_until) VALUES
('Daily Steps', 'Walk 10,000 steps today', 10000, 10.00, 'daily_steps', CURRENT_DATE + INTERVAL '1 day'),
('Workout Duration', 'Exercise for 30 minutes', 30, 15.00, 'workout_duration', CURRENT_DATE + INTERVAL '1 day'),
('Calorie Burn', 'Burn 300 calories', 300, 20.00, 'calories_burned', CURRENT_DATE + INTERVAL '1 day'),
('Complete Workout', 'Finish any workout', 1, 25.00, 'complete_workout', CURRENT_DATE + INTERVAL '1 day'); 