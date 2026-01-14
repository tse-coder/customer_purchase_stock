insert into businesses (id, name)
values ('11111111-1111-1111-1111-111111111111', 'Test Business');

insert into customers (id, business_id, name, credit_limit)
values (
  '22222222-2222-2222-2222-222222222222',
  '11111111-1111-1111-1111-111111111111',
  'Alice',
  1000
);

insert into products (id, business_id, name, price, stock)
values
(
  '33333333-3333-3333-3333-333333333333',
  '11111111-1111-1111-1111-111111111111',
  'Product A',
  100,
  10
),
(
  '44444444-4444-4444-4444-444444444444',
  '11111111-1111-1111-1111-111111111111',
  'Product B',
  200,
  5
);
