-- Create journal_entries table
CREATE TABLE journal_entries (
  id SERIAL PRIMARY KEY,
  "userId" INTEGER NOT NULL,
  title TEXT,
  content TEXT NOT NULL,
  mood TEXT,
  "sleepSessionId" INTEGER,
  tags TEXT,
  "isFavorite" BOOLEAN NOT NULL DEFAULT FALSE,
  "createdAt" TIMESTAMP NOT NULL,
  "updatedAt" TIMESTAMP NOT NULL,
  "entryDate" TIMESTAMP NOT NULL
);

-- Create journal_prompts table
CREATE TABLE journal_prompts (
  id SERIAL PRIMARY KEY,
  category TEXT NOT NULL,
  "promptText" TEXT NOT NULL,
  "isActive" BOOLEAN NOT NULL DEFAULT TRUE,
  "isSystemPrompt" BOOLEAN NOT NULL DEFAULT TRUE,
  "createdAt" TIMESTAMP NOT NULL
);

-- Create indexes for better query performance
CREATE INDEX idx_journal_entries_user_id ON journal_entries("userId");
CREATE INDEX idx_journal_entries_entry_date ON journal_entries("entryDate");
CREATE INDEX idx_journal_entries_mood ON journal_entries(mood);
CREATE INDEX idx_journal_prompts_category ON journal_prompts(category);

-- Seed initial prompts
INSERT INTO journal_prompts (category, "promptText", "isActive", "isSystemPrompt", "createdAt") VALUES
-- Evening prompts
('evening', 'What went well today?', TRUE, TRUE, NOW()),
('evening', 'What are you grateful for today?', TRUE, TRUE, NOW()),
('evening', 'What''s on your mind right now?', TRUE, TRUE, NOW()),
('evening', 'What can wait until tomorrow?', TRUE, TRUE, NOW()),
('evening', 'What made you smile today?', TRUE, TRUE, NOW()),

-- Morning prompts
('morning', 'How do you feel this morning?', TRUE, TRUE, NOW()),
('morning', 'Did your worries from last night come true?', TRUE, TRUE, NOW()),
('morning', 'What are you looking forward to today?', TRUE, TRUE, NOW()),
('morning', 'How well did you sleep?', TRUE, TRUE, NOW()),

-- Weekly prompts
('weekly', 'What patterns do you notice in your sleep this week?', TRUE, TRUE, NOW()),
('weekly', 'What helped you sleep best this week?', TRUE, TRUE, NOW()),
('weekly', 'What would you like to improve about your sleep?', TRUE, TRUE, NOW());
