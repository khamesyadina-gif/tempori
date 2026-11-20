alter table public.items
  add column if not exists notes text,
  add column if not exists created_at timestamptz not null default now();

insert into storage.buckets (id, name, public)
values ('item-photos', 'item-photos', true)
on conflict (id) do update
set public = excluded.public;

drop policy if exists "Users upload their own Tempori item photos"
  on storage.objects;
create policy "Users upload their own Tempori item photos"
  on storage.objects for insert to authenticated
  with check (
    bucket_id = 'item-photos'
    and (storage.foldername(name))[1] = (select auth.uid()::text)
  );

drop policy if exists "Users update their own Tempori item photos"
  on storage.objects;
create policy "Users update their own Tempori item photos"
  on storage.objects for update to authenticated
  using (
    bucket_id = 'item-photos'
    and (storage.foldername(name))[1] = (select auth.uid()::text)
  )
  with check (
    bucket_id = 'item-photos'
    and (storage.foldername(name))[1] = (select auth.uid()::text)
  );

drop policy if exists "Users delete their own Tempori item photos"
  on storage.objects;
create policy "Users delete their own Tempori item photos"
  on storage.objects for delete to authenticated
  using (
    bucket_id = 'item-photos'
    and (storage.foldername(name))[1] = (select auth.uid()::text)
  );
