-- enable pgcrypto extension
create extension if not exists "pgcrypto";

-- create tables
create table businesses (
  id uuid primary key default gen_random_uuid(),
  name text not null
);
create table customers (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references businesses(id),
  name text not null,
  credit_limit numeric not null,
  created_at timestamptz default now()
);
create table products (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references businesses(id),
  name text not null,
  price numeric not null,
  stock integer not null check (stock >= 0),
  created_at timestamptz default now()
);
create table orders (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references businesses(id),
  customer_id uuid not null references customers(id),
  total_amount numeric not null,
  created_at timestamptz default now()
);
create table order_items (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references businesses(id),
  order_id uuid not null references orders(id),
  product_id uuid not null references products(id),
  quantity integer not null check (quantity > 0),
  price numeric not null
);
create table payments (
  id uuid primary key default gen_random_uuid(),
  business_id uuid not null references businesses(id),
  order_id uuid not null references orders(id),
  amount numeric not null check (amount > 0),
  created_at timestamptz default now()
);

-- add indexes
create index on customers (business_id);
create index on products (business_id);
create index on orders (business_id, customer_id);
create index on payments (business_id, order_id);
create index on order_items (business_id, order_id);
