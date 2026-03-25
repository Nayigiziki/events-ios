-- DateNight Supabase Schema
-- Run this in the Supabase SQL Editor to set up the database

-- ============================================================
-- TABLES
-- ============================================================

-- Profiles (extends auth.users)
CREATE TABLE profiles (
    id UUID PRIMARY KEY REFERENCES auth.users ON DELETE CASCADE,
    name TEXT NOT NULL,
    age INT,
    bio TEXT,
    avatar_url TEXT,
    photos TEXT[] DEFAULT '{}',
    interests TEXT[] DEFAULT '{}',
    location TEXT,
    occupation TEXT,
    height INT,
    gender TEXT,
    birthdate DATE,
    ready_to_mingle BOOLEAN DEFAULT TRUE,
    available_from TIMESTAMPTZ,
    available_until TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- Events
CREATE TABLE events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    category TEXT NOT NULL,
    image_url TEXT,
    date TEXT NOT NULL,
    time TEXT NOT NULL,
    venue TEXT NOT NULL,
    location TEXT NOT NULL,
    price TEXT NOT NULL,
    description TEXT,
    total_spots INT NOT NULL DEFAULT 0,
    is_public BOOLEAN DEFAULT TRUE,
    created_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Event Interests (users interested in events)
CREATE TABLE event_interests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE (user_id, event_id)
);

-- Swipes
CREATE TABLE swipes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    swiper_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    swiped_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    direction TEXT NOT NULL CHECK (direction IN ('left', 'right')),
    event_id UUID REFERENCES events(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE (swiper_id, swiped_id)
);

-- Matches
CREATE TABLE matches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user1_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    user2_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    event_id UUID REFERENCES events(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE (user1_id, user2_id)
);

-- Date Requests
CREATE TABLE date_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
    organizer_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    max_people INT NOT NULL DEFAULT 2,
    description TEXT,
    date_type TEXT NOT NULL CHECK (date_type IN ('solo', 'group')),
    status TEXT NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'full', 'confirmed', 'cancelled')),
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Date Request Attendees
CREATE TABLE date_request_attendees (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    date_request_id UUID NOT NULL REFERENCES date_requests(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    joined_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE (date_request_id, user_id)
);

-- Conversations
CREATE TABLE conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    is_group BOOLEAN DEFAULT FALSE,
    group_name TEXT,
    match_id UUID REFERENCES matches(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Conversation Participants
CREATE TABLE conversation_participants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    joined_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE (conversation_id, user_id)
);

-- Messages
CREATE TABLE messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    message_type TEXT NOT NULL DEFAULT 'text' CHECK (message_type IN ('text', 'image', 'location')),
    created_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================================
-- INDEXES
-- ============================================================

CREATE INDEX idx_events_category ON events(category);
CREATE INDEX idx_events_created_by ON events(created_by);
CREATE INDEX idx_swipes_swiper ON swipes(swiper_id);
CREATE INDEX idx_swipes_swiped ON swipes(swiped_id);
CREATE INDEX idx_matches_user1 ON matches(user1_id);
CREATE INDEX idx_matches_user2 ON matches(user2_id);
CREATE INDEX idx_date_requests_event ON date_requests(event_id);
CREATE INDEX idx_date_requests_organizer ON date_requests(organizer_id);
CREATE INDEX idx_messages_conversation ON messages(conversation_id);
CREATE INDEX idx_messages_created_at ON messages(created_at);
CREATE INDEX idx_conversation_participants_user ON conversation_participants(user_id);

-- ============================================================
-- ROW LEVEL SECURITY
-- ============================================================

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE events ENABLE ROW LEVEL SECURITY;
ALTER TABLE event_interests ENABLE ROW LEVEL SECURITY;
ALTER TABLE swipes ENABLE ROW LEVEL SECURITY;
ALTER TABLE matches ENABLE ROW LEVEL SECURITY;
ALTER TABLE date_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE date_request_attendees ENABLE ROW LEVEL SECURITY;
ALTER TABLE conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE conversation_participants ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- Profiles policies
CREATE POLICY "Anyone can view profiles"
    ON profiles FOR SELECT
    USING (true);

CREATE POLICY "Users can insert own profile"
    ON profiles FOR INSERT
    WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update own profile"
    ON profiles FOR UPDATE
    USING (auth.uid() = id);

-- Events policies
CREATE POLICY "Anyone can view public events"
    ON events FOR SELECT
    USING (is_public = true);

CREATE POLICY "Authenticated users can create events"
    ON events FOR INSERT
    WITH CHECK (auth.uid() = created_by);

CREATE POLICY "Creators can update own events"
    ON events FOR UPDATE
    USING (auth.uid() = created_by);

CREATE POLICY "Creators can delete own events"
    ON events FOR DELETE
    USING (auth.uid() = created_by);

-- Event interests policies
CREATE POLICY "Users can view event interests"
    ON event_interests FOR SELECT
    USING (true);

CREATE POLICY "Users can insert own event interests"
    ON event_interests FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own event interests"
    ON event_interests FOR DELETE
    USING (auth.uid() = user_id);

-- Swipes policies
CREATE POLICY "Users can insert own swipes"
    ON swipes FOR INSERT
    WITH CHECK (auth.uid() = swiper_id);

CREATE POLICY "Users can view own swipes"
    ON swipes FOR SELECT
    USING (auth.uid() = swiper_id);

-- Matches policies
CREATE POLICY "Users can view own matches"
    ON matches FOR SELECT
    USING (auth.uid() = user1_id OR auth.uid() = user2_id);

-- Date requests policies
CREATE POLICY "Anyone can view open date requests"
    ON date_requests FOR SELECT
    USING (status = 'open' OR organizer_id = auth.uid());

CREATE POLICY "Authenticated users can create date requests"
    ON date_requests FOR INSERT
    WITH CHECK (auth.uid() = organizer_id);

CREATE POLICY "Organizers can update own date requests"
    ON date_requests FOR UPDATE
    USING (auth.uid() = organizer_id);

-- Date request attendees policies
CREATE POLICY "Anyone can view date request attendees"
    ON date_request_attendees FOR SELECT
    USING (true);

CREATE POLICY "Users can join date requests"
    ON date_request_attendees FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can leave date requests"
    ON date_request_attendees FOR DELETE
    USING (auth.uid() = user_id);

-- Conversations policies
CREATE POLICY "Participants can view conversations"
    ON conversations FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM conversation_participants
            WHERE conversation_id = conversations.id
            AND user_id = auth.uid()
        )
    );

-- Conversation participants policies
CREATE POLICY "Participants can view conversation members"
    ON conversation_participants FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM conversation_participants cp
            WHERE cp.conversation_id = conversation_participants.conversation_id
            AND cp.user_id = auth.uid()
        )
    );

-- Messages policies
CREATE POLICY "Participants can view messages"
    ON messages FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM conversation_participants
            WHERE conversation_id = messages.conversation_id
            AND user_id = auth.uid()
        )
    );

CREATE POLICY "Participants can send messages"
    ON messages FOR INSERT
    WITH CHECK (
        auth.uid() = sender_id
        AND EXISTS (
            SELECT 1 FROM conversation_participants
            WHERE conversation_id = messages.conversation_id
            AND user_id = auth.uid()
        )
    );

-- ============================================================
-- FUNCTIONS & TRIGGERS
-- ============================================================

-- Auto-create profile on user signup
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO profiles (id, name)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data ->> 'name', NEW.email)
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- Check for mutual swipe and create match + conversation
CREATE OR REPLACE FUNCTION check_mutual_swipe()
RETURNS TRIGGER AS $$
DECLARE
    mutual_swipe_exists BOOLEAN;
    new_match_id UUID;
    new_conversation_id UUID;
BEGIN
    IF NEW.direction != 'right' THEN
        RETURN NEW;
    END IF;

    SELECT EXISTS (
        SELECT 1 FROM swipes
        WHERE swiper_id = NEW.swiped_id
        AND swiped_id = NEW.swiper_id
        AND direction = 'right'
    ) INTO mutual_swipe_exists;

    IF mutual_swipe_exists THEN
        -- Create match
        INSERT INTO matches (user1_id, user2_id, event_id)
        VALUES (
            LEAST(NEW.swiper_id, NEW.swiped_id),
            GREATEST(NEW.swiper_id, NEW.swiped_id),
            NEW.event_id
        )
        RETURNING id INTO new_match_id;

        -- Create conversation
        INSERT INTO conversations (is_group, match_id)
        VALUES (FALSE, new_match_id)
        RETURNING id INTO new_conversation_id;

        -- Add both users as participants
        INSERT INTO conversation_participants (conversation_id, user_id)
        VALUES
            (new_conversation_id, NEW.swiper_id),
            (new_conversation_id, NEW.swiped_id);
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_swipe_inserted
    AFTER INSERT ON swipes
    FOR EACH ROW EXECUTE FUNCTION check_mutual_swipe();

-- Auto-update date request status when attendee joins
CREATE OR REPLACE FUNCTION update_date_request_status()
RETURNS TRIGGER AS $$
DECLARE
    attendee_count INT;
    max_allowed INT;
BEGIN
    SELECT COUNT(*) INTO attendee_count
    FROM date_request_attendees
    WHERE date_request_id = NEW.date_request_id;

    SELECT max_people INTO max_allowed
    FROM date_requests
    WHERE id = NEW.date_request_id;

    IF attendee_count >= max_allowed THEN
        UPDATE date_requests
        SET status = 'full'
        WHERE id = NEW.date_request_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_date_request_attendee_joined
    AFTER INSERT ON date_request_attendees
    FOR EACH ROW EXECUTE FUNCTION update_date_request_status();

-- Auto-update updated_at on profiles
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_profile_updated
    BEFORE UPDATE ON profiles
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ============================================================
-- REALTIME
-- ============================================================

ALTER PUBLICATION supabase_realtime ADD TABLE messages;

-- ============================================================
-- SEED DATA
-- ============================================================

-- Note: Seed data uses fixed UUIDs for consistency.
-- In production, user IDs come from auth.users.

DO $$
DECLARE
    user_current UUID := 'a0000000-0000-0000-0000-000000000000';
    user_emma    UUID := 'a0000000-0000-0000-0000-000000000001';
    user_sarah   UUID := 'a0000000-0000-0000-0000-000000000002';
    user_alex    UUID := 'a0000000-0000-0000-0000-000000000003';
    user_michael UUID := 'a0000000-0000-0000-0000-000000000004';
    user_jessica UUID := 'a0000000-0000-0000-0000-000000000005';
    user_david   UUID := 'a0000000-0000-0000-0000-000000000006';

    event_1 UUID := 'b0000000-0000-0000-0000-000000000001';
    event_2 UUID := 'b0000000-0000-0000-0000-000000000002';
    event_3 UUID := 'b0000000-0000-0000-0000-000000000003';
    event_4 UUID := 'b0000000-0000-0000-0000-000000000004';
    event_5 UUID := 'b0000000-0000-0000-0000-000000000005';
    event_6 UUID := 'b0000000-0000-0000-0000-000000000006';
    event_7 UUID := 'b0000000-0000-0000-0000-000000000007';
    event_8 UUID := 'b0000000-0000-0000-0000-000000000008';

    dr_1 UUID := 'c0000000-0000-0000-0000-000000000001';
    dr_2 UUID := 'c0000000-0000-0000-0000-000000000002';
    dr_3 UUID := 'c0000000-0000-0000-0000-000000000003';
BEGIN
    -- Seed profiles (bypassing auth.users FK for dev — remove FK or use test auth users in production)
    INSERT INTO profiles (id, name, age, bio, avatar_url, photos, interests, ready_to_mingle) VALUES
    (user_current, 'You', 28, 'Love live music and art galleries',
     'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400&h=400&fit=crop',
     ARRAY['https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=800&h=800&fit=crop'],
     ARRAY['Music', 'Art', 'Food', 'Comedy'], TRUE),
    (user_emma, 'Emma', 26, 'Jazz enthusiast and foodie',
     'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400&h=400&fit=crop',
     ARRAY['https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=800&h=800&fit=crop'],
     ARRAY['Music', 'Food', 'Wine'], TRUE),
    (user_sarah, 'Sarah', 29, 'Art lover, comedy fan',
     'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&h=400&fit=crop',
     ARRAY['https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=800&h=800&fit=crop'],
     ARRAY['Art', 'Comedy', 'Music'], TRUE),
    (user_alex, 'Alex', 27, 'Concert junkie and outdoor enthusiast',
     'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=400&h=400&fit=crop',
     ARRAY['https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=800&h=800&fit=crop'],
     ARRAY['Music', 'Outdoors', 'Food'], TRUE),
    (user_michael, 'Michael', 30, 'Wine connoisseur, live music fan',
     'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400&h=400&fit=crop',
     ARRAY['https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=800&h=800&fit=crop'],
     ARRAY['Wine', 'Music', 'Art'], TRUE),
    (user_jessica, 'Jessica', 25, 'Yoga instructor who loves comedy shows',
     'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400&h=400&fit=crop',
     ARRAY['https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=800&h=800&fit=crop'],
     ARRAY['Wellness', 'Comedy', 'Food'], TRUE),
    (user_david, 'David', 31, 'Food festival explorer',
     'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=400&fit=crop',
     ARRAY['https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=800&h=800&fit=crop'],
     ARRAY['Food', 'Music', 'Art'], TRUE)
    ON CONFLICT (id) DO NOTHING;

    -- Seed events
    INSERT INTO events (id, title, category, image_url, date, time, venue, location, price, description, total_spots, is_public, created_by) VALUES
    (event_1, 'Indie Rock Night', 'Music',
     'https://images.unsplash.com/photo-1604364260242-1156640c0dfb?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=1080',
     'March 28, 2026', '8:00 PM', 'The Electric Ballroom', 'Downtown', '$25',
     'Experience an unforgettable night with local indie bands. Great vibes, amazing music, and the perfect atmosphere for meeting new people.',
     200, TRUE, user_current),
    (event_2, 'Contemporary Art Exhibition', 'Art',
     'https://images.unsplash.com/photo-1713779490284-a81ff6a8ffae?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=1080',
     'March 30, 2026', '6:00 PM', 'Modern Art Gallery', 'Arts District', '$15',
     'Explore contemporary masterpieces and engage in meaningful conversations about art. Wine and cheese included.',
     50, TRUE, user_current),
    (event_3, 'Comedy Open Mic', 'Comedy',
     'https://images.unsplash.com/photo-1648237409808-aa4649c07ec8?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=1080',
     'March 26, 2026', '7:30 PM', 'Laugh Factory', 'Midtown', '$20',
     'Laugh the night away with up-and-coming comedians. Two-drink minimum, unlimited laughs guaranteed.',
     100, TRUE, user_current),
    (event_4, 'Street Food Festival', 'Food',
     'https://images.unsplash.com/photo-1551883738-19ffa3dc4c43?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=1080',
     'April 2, 2026', '12:00 PM', 'Central Park', 'Central Park', 'Free Entry',
     'Sample cuisines from around the world in a vibrant outdoor setting. Live music and entertainment all day.',
     500, TRUE, user_current),
    (event_5, 'Sunset Yoga Session', 'Wellness',
     'https://images.unsplash.com/photo-1608405059861-b21a68ae76a2?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=1080',
     'March 29, 2026', '6:30 PM', 'Beachfront Park', 'Beachside', '$10',
     'Unwind with a relaxing yoga session as the sun sets. All levels welcome. Stay for refreshments after.',
     30, TRUE, user_current),
    (event_6, 'Wine Tasting Evening', 'Wine',
     'https://images.unsplash.com/photo-1762455129210-c886b9295056?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=1080',
     'April 5, 2026', '7:00 PM', 'Vintage Wine Bar', 'Wine District', '$45',
     'Sample a curated selection of wines from around the world paired with artisanal cheeses and charcuterie.',
     25, TRUE, user_current),
    (event_7, 'Jazz Night Live', 'Music',
     'https://images.unsplash.com/photo-1757439160077-dd5d62a4d851?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=1080',
     'April 1, 2026', '9:00 PM', 'Blue Note Club', 'Jazz Quarter', '$30',
     'Smooth jazz performances in an intimate club setting. Perfect date night atmosphere with craft cocktails.',
     60, TRUE, user_current),
    (event_8, 'Rooftop Summer Kickoff', 'Social',
     'https://images.unsplash.com/photo-1644589075956-a2526d00fd31?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&w=1080',
     'April 8, 2026', '5:00 PM', 'Sky Lounge', 'Downtown', '$35',
     'Celebrate the season with stunning city views, DJ sets, and premium cocktails. Dress to impress!',
     150, TRUE, user_current)
    ON CONFLICT (id) DO NOTHING;

    -- Seed event interests (attendees)
    INSERT INTO event_interests (user_id, event_id) VALUES
    (user_emma, event_1), (user_alex, event_1), (user_michael, event_1),
    (user_sarah, event_2), (user_michael, event_2),
    (user_sarah, event_3), (user_jessica, event_3),
    (user_emma, event_4), (user_david, event_4),
    (user_jessica, event_5),
    (user_emma, event_6), (user_michael, event_6),
    (user_emma, event_7), (user_michael, event_7),
    (user_sarah, event_8), (user_alex, event_8), (user_david, event_8)
    ON CONFLICT (user_id, event_id) DO NOTHING;

    -- Seed date requests
    INSERT INTO date_requests (id, event_id, organizer_id, max_people, description, date_type, status) VALUES
    (dr_1, event_1, user_emma, 4,
     'Looking for 2 more music lovers to join us for this show! Let''s make it a fun group night.',
     'group', 'open'),
    (dr_2, event_2, user_sarah, 2,
     'Art gallery date, would love to meet someone who appreciates contemporary art.',
     'solo', 'open'),
    (dr_3, event_7, user_michael, 2,
     'Intimate jazz night for two. Love smooth jazz and good conversation.',
     'solo', 'full')
    ON CONFLICT (id) DO NOTHING;

    -- Seed date request attendees
    INSERT INTO date_request_attendees (date_request_id, user_id) VALUES
    (dr_1, user_emma), (dr_1, user_alex),
    (dr_2, user_sarah),
    (dr_3, user_michael), (dr_3, user_emma)
    ON CONFLICT (date_request_id, user_id) DO NOTHING;
END $$;
