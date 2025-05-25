-- =====================================================
-- ROW LEVEL SECURITY POLICIES
-- =====================================================

-- Enable RLS on all tables
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.workouts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rewards ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_rewards ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.missions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_mission_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.friendships ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.social_activities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fitness_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.event_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.analytics_events ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- USERS TABLE POLICIES
-- =====================================================

-- Users can view their own profile
CREATE POLICY "Users can view own profile" ON public.users
    FOR SELECT USING (auth.uid() = id);

-- Users can update their own profile
CREATE POLICY "Users can update own profile" ON public.users
    FOR UPDATE USING (auth.uid() = id);

-- Users can insert their own profile (for registration)
CREATE POLICY "Users can insert own profile" ON public.users
    FOR INSERT WITH CHECK (auth.uid() = id);

-- Users can view public profiles of friends and suggested users
CREATE POLICY "Users can view public profiles" ON public.users
    FOR SELECT USING (
        -- Own profile
        auth.uid() = id 
        OR 
        -- Friends (accepted friendships)
        EXISTS (
            SELECT 1 FROM public.friendships 
            WHERE ((requester_id = auth.uid() AND addressee_id = id) 
                   OR (requester_id = id AND addressee_id = auth.uid()))
            AND status = 'accepted'
        )
        OR
        -- Public profiles (when social_privacy_enabled = false)
        social_privacy_enabled = false
    );

-- =====================================================
-- WORKOUTS TABLE POLICIES
-- =====================================================

-- Users can view their own workouts
CREATE POLICY "Users can view own workouts" ON public.workouts
    FOR SELECT USING (auth.uid() = user_id);

-- Users can insert their own workouts
CREATE POLICY "Users can insert own workouts" ON public.workouts
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can update their own workouts
CREATE POLICY "Users can update own workouts" ON public.workouts
    FOR UPDATE USING (auth.uid() = user_id);

-- Users can delete their own workouts
CREATE POLICY "Users can delete own workouts" ON public.workouts
    FOR DELETE USING (auth.uid() = user_id);

-- Friends can view workouts if user allows social sharing
CREATE POLICY "Friends can view shared workouts" ON public.workouts
    FOR SELECT USING (
        auth.uid() = user_id 
        OR 
        (
            EXISTS (
                SELECT 1 FROM public.friendships 
                WHERE ((requester_id = auth.uid() AND addressee_id = user_id) 
                       OR (requester_id = user_id AND addressee_id = auth.uid()))
                AND status = 'accepted'
            )
            AND 
            EXISTS (
                SELECT 1 FROM public.users 
                WHERE id = user_id AND social_privacy_enabled = false
            )
        )
    );

-- =====================================================
-- REWARDS TABLE POLICIES
-- =====================================================

-- Everyone can view available rewards
CREATE POLICY "Everyone can view available rewards" ON public.rewards
    FOR SELECT USING (is_available = true);

-- Only authenticated users can view all rewards
CREATE POLICY "Authenticated users can view all rewards" ON public.rewards
    FOR SELECT USING (auth.role() = 'authenticated');

-- =====================================================
-- USER REWARDS TABLE POLICIES
-- =====================================================

-- Users can view their own purchased rewards
CREATE POLICY "Users can view own purchased rewards" ON public.user_rewards
    FOR SELECT USING (auth.uid() = user_id);

-- Users can insert their own reward purchases
CREATE POLICY "Users can insert own reward purchases" ON public.user_rewards
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can update their own reward redemptions
CREATE POLICY "Users can update own reward redemptions" ON public.user_rewards
    FOR UPDATE USING (auth.uid() = user_id);

-- =====================================================
-- MISSIONS TABLE POLICIES
-- =====================================================

-- Everyone can view active missions
CREATE POLICY "Everyone can view active missions" ON public.missions
    FOR SELECT USING (is_active = true AND valid_until >= CURRENT_DATE);

-- =====================================================
-- USER MISSION PROGRESS TABLE POLICIES
-- =====================================================

-- Users can view their own mission progress
CREATE POLICY "Users can view own mission progress" ON public.user_mission_progress
    FOR SELECT USING (auth.uid() = user_id);

-- Users can insert their own mission progress
CREATE POLICY "Users can insert own mission progress" ON public.user_mission_progress
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can update their own mission progress
CREATE POLICY "Users can update own mission progress" ON public.user_mission_progress
    FOR UPDATE USING (auth.uid() = user_id);

-- =====================================================
-- FRIENDSHIPS TABLE POLICIES
-- =====================================================

-- Users can view friendships they're involved in
CREATE POLICY "Users can view own friendships" ON public.friendships
    FOR SELECT USING (
        auth.uid() = requester_id OR auth.uid() = addressee_id
    );

-- Users can create friend requests
CREATE POLICY "Users can create friend requests" ON public.friendships
    FOR INSERT WITH CHECK (auth.uid() = requester_id);

-- Users can update friendships they're involved in
CREATE POLICY "Users can update own friendships" ON public.friendships
    FOR UPDATE USING (
        auth.uid() = requester_id OR auth.uid() = addressee_id
    );

-- Users can delete friendships they're involved in
CREATE POLICY "Users can delete own friendships" ON public.friendships
    FOR DELETE USING (
        auth.uid() = requester_id OR auth.uid() = addressee_id
    );

-- =====================================================
-- SOCIAL ACTIVITIES TABLE POLICIES
-- =====================================================

-- Users can view their own social activities
CREATE POLICY "Users can view own social activities" ON public.social_activities
    FOR SELECT USING (auth.uid() = user_id);

-- Users can view social activities from friends
CREATE POLICY "Users can view friends social activities" ON public.social_activities
    FOR SELECT USING (
        auth.uid() = user_id 
        OR 
        EXISTS (
            SELECT 1 FROM public.friendships 
            WHERE ((requester_id = auth.uid() AND addressee_id = user_id) 
                   OR (requester_id = user_id AND addressee_id = auth.uid()))
            AND status = 'accepted'
        )
    );

-- Users can insert their own social activities
CREATE POLICY "Users can insert own social activities" ON public.social_activities
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- =====================================================
-- FITNESS EVENTS TABLE POLICIES
-- =====================================================

-- Everyone can view public fitness events
CREATE POLICY "Everyone can view fitness events" ON public.fitness_events
    FOR SELECT USING (true);

-- Users can create fitness events
CREATE POLICY "Users can create fitness events" ON public.fitness_events
    FOR INSERT WITH CHECK (auth.uid() = creator_id);

-- Event creators can update their events
CREATE POLICY "Creators can update own events" ON public.fitness_events
    FOR UPDATE USING (auth.uid() = creator_id);

-- Event creators can delete their events
CREATE POLICY "Creators can delete own events" ON public.fitness_events
    FOR DELETE USING (auth.uid() = creator_id);

-- =====================================================
-- EVENT PARTICIPANTS TABLE POLICIES
-- =====================================================

-- Users can view participants of events they're involved in
CREATE POLICY "Users can view event participants" ON public.event_participants
    FOR SELECT USING (
        auth.uid() = user_id 
        OR 
        EXISTS (
            SELECT 1 FROM public.fitness_events 
            WHERE id = event_id AND creator_id = auth.uid()
        )
    );

-- Users can join events (insert their participation)
CREATE POLICY "Users can join events" ON public.event_participants
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can update their own participation status
CREATE POLICY "Users can update own participation" ON public.event_participants
    FOR UPDATE USING (auth.uid() = user_id);

-- Users can leave events (delete their participation)
CREATE POLICY "Users can leave events" ON public.event_participants
    FOR DELETE USING (auth.uid() = user_id);

-- =====================================================
-- ANALYTICS EVENTS TABLE POLICIES
-- =====================================================

-- Users can view their own analytics events
CREATE POLICY "Users can view own analytics" ON public.analytics_events
    FOR SELECT USING (auth.uid() = user_id);

-- Users can insert their own analytics events
CREATE POLICY "Users can insert own analytics" ON public.analytics_events
    FOR INSERT WITH CHECK (auth.uid() = user_id OR user_id IS NULL);

-- =====================================================
-- HELPER FUNCTIONS FOR POLICIES
-- =====================================================

-- Function to check if two users are friends
CREATE OR REPLACE FUNCTION public.are_friends(user1_id UUID, user2_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.friendships 
        WHERE ((requester_id = user1_id AND addressee_id = user2_id) 
               OR (requester_id = user2_id AND addressee_id = user1_id))
        AND status = 'accepted'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to check if user has social privacy enabled
CREATE OR REPLACE FUNCTION public.has_social_privacy(user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.users 
        WHERE id = user_id AND social_privacy_enabled = true
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- REALTIME SUBSCRIPTIONS
-- =====================================================

-- Enable realtime for social features
ALTER PUBLICATION supabase_realtime ADD TABLE public.social_activities;
ALTER PUBLICATION supabase_realtime ADD TABLE public.friendships;
ALTER PUBLICATION supabase_realtime ADD TABLE public.fitness_events;
ALTER PUBLICATION supabase_realtime ADD TABLE public.event_participants;

-- =====================================================
-- STORAGE POLICIES (for profile images, etc.)
-- =====================================================

-- Create storage bucket for user avatars
INSERT INTO storage.buckets (id, name, public) VALUES ('avatars', 'avatars', true);

-- Policy for avatar uploads
CREATE POLICY "Users can upload their own avatar" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'avatars' 
        AND auth.uid()::text = (storage.foldername(name))[1]
    );

-- Policy for avatar updates
CREATE POLICY "Users can update their own avatar" ON storage.objects
    FOR UPDATE USING (
        bucket_id = 'avatars' 
        AND auth.uid()::text = (storage.foldername(name))[1]
    );

-- Policy for avatar viewing
CREATE POLICY "Anyone can view avatars" ON storage.objects
    FOR SELECT USING (bucket_id = 'avatars'); 