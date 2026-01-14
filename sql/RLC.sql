-- enable RLC
alter table customers enable row level security;
alter table products enable row level security;
alter table orders enable row level security;
alter table order_items enable row level security;
alter table payments enable row level security;

create policy "server access"
on customers for all
using (true)
with check (true);

create policy "server access"
on businesses for all
using (true)
with check (true);

create policy "server access"
on products for all
using (true)
with check (true);

create policy "server access"
on orders for all
using (true)
with check (true);

create policy "server access"
on order_items for all
using (true)
with check (true);

create policy "server access"
on payments for all
using (true)
with check (true);
