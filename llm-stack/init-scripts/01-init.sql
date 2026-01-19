-- This runs automatically when the container is first created

-- Enable pgvector extension
CREATE EXTENSION IF NOT EXISTS vector;

-- Table for storing document embeddings
CREATE TABLE IF NOT EXISTS embeddings (
    id SERIAL PRIMARY KEY,
    content TEXT NOT NULL,
    embedding vector(384),  -- Adjust dimension based on your embedding model
    metadata JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Index for vector similarity search (cosine distance)
CREATE INDEX IF NOT EXISTS embeddings_vector_idx 
ON embeddings USING hnsw (embedding vector_cosine_ops);

-- Table for conversation history
CREATE TABLE IF NOT EXISTS conversations (
    id SERIAL PRIMARY KEY,
    conversation_id UUID DEFAULT gen_random_uuid(),
    role VARCHAR(20) NOT NULL,  -- 'user' or 'assistant'
    content TEXT NOT NULL,
    model VARCHAR(100),
    tokens_used INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Index for quick conversation retrieval
CREATE INDEX IF NOT EXISTS conversations_conversation_id_idx 
ON conversations(conversation_id);

CREATE INDEX IF NOT EXISTS conversations_created_at_idx 
ON conversations(created_at DESC);

-- Table for custom knowledge base
CREATE TABLE IF NOT EXISTS knowledge_base (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    source VARCHAR(255),
    tags TEXT[],
    embedding vector(384),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Index for knowledge base vector search
CREATE INDEX IF NOT EXISTS knowledge_base_vector_idx 
ON knowledge_base USING hnsw (embedding vector_cosine_ops);

-- Function to update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers for updating timestamps
CREATE TRIGGER update_embeddings_updated_at BEFORE UPDATE
ON embeddings FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_knowledge_base_updated_at BEFORE UPDATE
ON knowledge_base FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Grant necessary permissions
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO llm_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO llm_user;
