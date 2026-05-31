-- ═══════════════════════════════════════════
--  담하로 팬사이트 Supabase 초기화 SQL
--  Supabase SQL Editor에서 순서대로 실행
-- ═══════════════════════════════════════════

-- ── 1. 노래책 ──────────────────────────────
CREATE TABLE IF NOT EXISTS public.songs (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  artist     TEXT,
  title      TEXT,
  genre      TEXT DEFAULT 'kpop',  -- kpop | jpop | pop | ballad | ost | anime | etc
  level      INT DEFAULT 3,
  memo       TEXT,
  sort_order INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.songs ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read songs"  ON public.songs FOR SELECT USING (true);
CREATE POLICY "Auth insert songs"  ON public.songs FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Auth delete songs"  ON public.songs FOR DELETE TO authenticated USING (true);
CREATE POLICY "Auth update songs"  ON public.songs FOR UPDATE TO authenticated USING (true) WITH CHECK (true);

-- ── 2. 방송 일정 ───────────────────────────
CREATE TABLE IF NOT EXISTS public.schedules (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  date        DATE NOT NULL UNIQUE,
  status      TEXT DEFAULT 'normal', -- normal | holiday | special | anniversary
  slot1_title TEXT,
  slot2_title TEXT,
  slot1_time  TEXT DEFAULT '13:30',
  slot2_time  TEXT DEFAULT '23:00',
  note        TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.schedules ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public read schedules"  ON public.schedules FOR SELECT USING (true);
CREATE POLICY "Auth insert schedules"  ON public.schedules FOR INSERT TO authenticated WITH CHECK (true);
CREATE POLICY "Auth update schedules"  ON public.schedules FOR UPDATE TO authenticated USING (true);
CREATE POLICY "Auth delete schedules"  ON public.schedules FOR DELETE TO authenticated USING (true);

-- ── 3. OBS 오버레이 상태 ────────────────────
CREATE TABLE IF NOT EXISTS public.overlay_state (
  id          INT PRIMARY KEY DEFAULT 1 CHECK (id = 1),
  song_title  TEXT DEFAULT '',
  song_artist TEXT DEFAULT '',
  is_visible  BOOLEAN DEFAULT FALSE,
  updated_at  TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO public.overlay_state (id, song_title, song_artist, is_visible)
VALUES (1, '', '', false) ON CONFLICT (id) DO NOTHING;

ALTER TABLE public.overlay_state ENABLE ROW LEVEL SECURITY;
CREATE POLICY "overlay_read"     ON public.overlay_state FOR SELECT USING (true);
CREATE POLICY "overlay_all_auth" ON public.overlay_state
  FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- ── 4. 업보 테이블 5종 ─────────────────────

-- 4-1. 업보 타입
CREATE TABLE IF NOT EXISTS public.upbo_task_types (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name       TEXT NOT NULL,
  category   TEXT DEFAULT 'normal', -- normal | event
  sort_order INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4-2. 시청자 멤버
CREATE TABLE IF NOT EXISTS public.upbo_members (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nickname   TEXT NOT NULL,
  user_id    TEXT,
  memo       TEXT,
  is_hidden  BOOLEAN DEFAULT FALSE,
  sort_order INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4-3. 업보 태스크
CREATE TABLE IF NOT EXISTS public.upbo_tasks (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  member_id  UUID REFERENCES public.upbo_members(id) ON DELETE CASCADE,
  type_id    UUID REFERENCES public.upbo_task_types(id) ON DELETE CASCADE,
  quantity   INT DEFAULT 1,
  memo       TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4-4. 문의
CREATE TABLE IF NOT EXISTS public.upbo_inquiries (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  nickname   TEXT,
  content    TEXT,
  is_read    BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4-5. 설정
CREATE TABLE IF NOT EXISTS public.upbo_settings (
  key   TEXT PRIMARY KEY,
  value TEXT
);

INSERT INTO public.upbo_settings (key, value)
VALUES ('updated_at', '갱신 전') ON CONFLICT (key) DO NOTHING;

-- RLS
ALTER TABLE public.upbo_task_types  ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.upbo_members     ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.upbo_tasks       ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.upbo_inquiries   ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.upbo_settings    ENABLE ROW LEVEL SECURITY;

CREATE POLICY "public read task_types"  ON public.upbo_task_types  FOR SELECT USING (true);
CREATE POLICY "public read members"     ON public.upbo_members     FOR SELECT USING (true);
CREATE POLICY "public read tasks"       ON public.upbo_tasks       FOR SELECT USING (true);
CREATE POLICY "public read settings"    ON public.upbo_settings    FOR SELECT USING (true);
CREATE POLICY "public insert inquiries" ON public.upbo_inquiries   FOR INSERT WITH CHECK (true);

CREATE POLICY "auth all task_types"  ON public.upbo_task_types  FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "auth all members"     ON public.upbo_members     FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "auth all tasks"       ON public.upbo_tasks       FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "auth all settings"    ON public.upbo_settings    FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "auth all inquiries"   ON public.upbo_inquiries   FOR ALL TO authenticated USING (true) WITH CHECK (true);
