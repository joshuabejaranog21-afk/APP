-- =============================================
-- SUPABASE STORAGE SETUP FOR PDFs
-- Run this in Supabase SQL Editor (Dashboard → SQL Editor)
-- =============================================

-- 1. Create the pdfs bucket
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'pdfs',
  'pdfs',
  true,
  52428800, -- 50 MB limit
  ARRAY['application/pdf']
)
ON CONFLICT (id) DO NOTHING;

-- 2. Allow anyone to upload PDFs (development mode - no auth required)
CREATE POLICY "Allow public uploads"
ON storage.objects FOR INSERT
WITH CHECK (bucket_id = 'pdfs');

-- 3. Allow anyone to read/download PDFs
CREATE POLICY "Allow public reads"
ON storage.objects FOR SELECT
USING (bucket_id = 'pdfs');

-- 4. Allow anyone to delete PDFs
CREATE POLICY "Allow public deletes"
ON storage.objects FOR DELETE
USING (bucket_id = 'pdfs');

-- 5. Allow updates
CREATE POLICY "Allow public updates"
ON storage.objects FOR UPDATE
USING (bucket_id = 'pdfs');
