-- 城市灵魂匹配计划：匿名结果库
-- 在 Supabase 后台的 SQL Editor 整段运行一次。

create table if not exists public.city_test_submissions (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  app_version text not null default '1.1',
  china_city text not null,
  china_score smallint not null check (china_score between 1 and 100),
  world_city text not null,
  world_score smallint not null check (world_score between 1 and 100),
  profile jsonb not null,
  guardrails jsonb not null default '[]'::jsonb
);

alter table public.city_test_submissions enable row level security;

-- 网页只被允许新增一条匿名结果；访客不能读取其他人的记录。
create policy "anonymous visitors can add a result"
on public.city_test_submissions for insert to anon
with check (true);

-- 给你在后台看排行用；网页端没有读取权限。
create or replace view public.city_popularity as
select city, city_type, count(*)::integer as total
from (
  select china_city as city, '中国城市'::text as city_type from public.city_test_submissions
  union all
  select world_city as city, '世界城市'::text as city_type from public.city_test_submissions
) ranked
group by city, city_type
order by city_type, total desc, city;

-- 后台看最近结果：
-- select created_at, china_city, china_score, world_city, world_score, profile, guardrails
-- from public.city_test_submissions order by created_at desc;
--
-- 后台看热门城市：
-- select * from public.city_popularity;
