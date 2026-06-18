-- Create the video-editor database for the client's auth tables
SELECT 'CREATE DATABASE "video-editor"'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'video-editor')\gexec
