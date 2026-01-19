create or replace function process_purchase(
  p_business_id uuid,
  p_customer_id uuid,
  p_items jsonb
)
returns void
language plpgsql
as $$
declare
  v_credit_limit numeric;
  v_balance numeric;
  v_total numeric := 0;
  v_order_id uuid := gen_random_uuid();
  item record;
  v_price numeric;
  v_stock integer;
begin
  -- lock customer
  select credit_limit
  into v_credit_limit
  from customers
  where id = p_customer_id
    and business_id = p_business_id
  for update;

  if not found then
    raise exception 'customer not found';
  end if;

  -- current balance
  select coalesce(sum(o.total_amount), 0) - coalesce(sum(p.amount), 0)
  into v_balance
  from orders o
  left join payments p on p.order_id = o.id
  where o.customer_id = p_customer_id
    and o.business_id = p_business_id;

  -- validate items
  for item in
    select * from jsonb_to_recordset(p_items)
    as i(product_id uuid, quantity int)
  loop
    select price, stock
    into v_price, v_stock
    from products
    where id = item.product_id
      and business_id = p_business_id
    for update;

    if v_stock < item.quantity then
      raise exception 'insufficient stock';
    end if;

    v_total := v_total + (v_price * item.quantity);
  end loop;

  if v_balance + v_total > v_credit_limit then
    raise exception 'credit limit exceeded';
  end if;

  -- create order
  insert into orders (id, business_id, customer_id, total_amount)
  values (v_order_id, p_business_id, p_customer_id, v_total);

  -- order items + stock update
  for item in
    select * from jsonb_to_recordset(p_items)
    as i(product_id uuid, quantity int)
  loop
    select price into v_price
    from products
    where id = item.product_id;

    insert into order_items
      (business_id, order_id, product_id, quantity, price)
    values
      (p_business_id, v_order_id, item.product_id, item.quantity, v_price);

    update products
    set stock = stock - item.quantity
    where id = item.product_id;
  end loop;
end;
$$;
