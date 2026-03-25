-- Phase 2A: Friendships table
CREATE TABLE friendships (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    friend_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'declined')),
    created_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE(user_id, friend_id)
);

ALTER TABLE friendships ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can read own friendships" ON friendships FOR SELECT USING (auth.uid() = user_id OR auth.uid() = friend_id);
CREATE POLICY "Users can insert friendships" ON friendships FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own friendships" ON friendships FOR UPDATE USING (auth.uid() = friend_id);
