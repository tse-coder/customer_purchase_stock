# Customer Credit Backend

## Project Overview

This project implements a **multi-tenant backend system** for managing **customer purchases on credit**, using **Supabase (PostgreSQL)** and **Next.js (App Router)**.

It is designed for multiple businesses sharing the same backend, with full **data isolation**, **atomic purchase processing**, and **support for partial payments**.

**Key Features Implemented:**

- Multi-product orders per purchase.
- Customers have a **fixed credit limit**, but **partial payments are allowed**.
- Purchases automatically update **stock** and **customer balances**.
- Multi-tenant safety: one business cannot access or modify another business's data.
- Concurrency-safe operations using **transactions** and **row-level locks**.
- Query for **overdue customers** (balances older than 30 days).

---

## Folder Structure

```
customer_credit/
├─ app/
│  ├─ actions/purchase.ts        ← Server action wrapping the purchase RPC
│  ├─ api/purchase/route.ts      ← HTTP endpoint for testing purchases
│  ├─ layout.tsx
│  └─ page.tsx
├─ lib/supabase.ts               ← Supabase server-only client
├─ public/schemaScreenshot.png   ← Database schema visualization
├─ sql/
│  ├─ schema.sql                 ← Table definitions
│  ├─ seed.sql                   ← Sample businesses, customers, products
│  ├─ RLC.sql                     ← Row-level security policies
│  ├─ overdueQuery.sql            ← Query for overdue customers
│  └─ processPurchase.sql         ← Complete PostgreSQL function for processing purchases
├─ .env.local                     ← Supabase URL + Service Role Key
└─ README.md
```

---

## Database Schema

**Tables:**

1. **businesses** – Represents each tenant/business.
2. **customers** – Contains customer info and `credit_limit`.
3. **products** – Tracks product stock and price.
4. **orders** – Records each purchase per customer.
5. **order_items** – Stores multiple products per order with quantity and price snapshot.
6. **payments** – Supports partial payments against orders.

**Schema Screenshot:**

![Schema](./public/schemaScreenshot.png)

---

## Purchase Process

All purchase logic is encapsulated in the PostgreSQL function **`process_purchase`**, defined in `processPurchase.sql`.

**Steps in the function:**

1. **Customer & Product Locking**
   - `FOR UPDATE` locks are used to prevent concurrent requests from overselling products or exceeding credit.

2. **Credit Validation**
   - The function calculates the customer's current balance, considering previous orders and payments.
   - It raises an exception if the new purchase exceeds the customer’s credit limit.

3. **Stock Validation**
   - Each product's available stock is checked.
   - If stock is insufficient, the function raises an exception, preventing partial updates.

4. **Atomic Transaction**
   - All inserts/updates (orders, order_items, stock adjustment) happen inside a **single transaction**.
   - On any error, the transaction rolls back completely.

5. **Tenant Isolation**
   - Every table and query includes `business_id`, ensuring that purchases for one business cannot affect another.

**Next.js Integration:**

- **Server Action (`app/actions/purchase.ts`)**: calls `process_purchase` via Supabase RPC.
- **API Route (`app/api/purchase/route.ts`)**: exposes the purchase functionality over HTTP for testing with tools like **ApiDog** or **Postman**.

---

### Example API Request

**POST `/api/purchase`**

**Headers:**

```
Content-Type: application/json
```

**Body:**

```json
{
  "business_id": "11111111-1111-1111-1111-111111111111",
  "customer_id": "22222222-2222-2222-2222-222222222222",
  "items": [
    { "product_id": "33333333-3333-3333-3333-333333333333", "quantity": 2 },
    { "product_id": "44444444-4444-4444-4444-444444444444", "quantity": 1 }
  ]
}
```

**Responses:**

- **Success:**

```json
{ "success": true }
```

- **Insufficient stock:**

```json
{ "error": "insufficient stock" }
```

- **Credit limit exceeded:**

```json
{ "error": "credit limit exceeded" }
```

> All failure cases leave the database in a consistent state due to the atomic transaction.

---

## Overdue Customers

Query in `overdueQuery.sql`:

```sql
SELECT
    c.id,
    c.name,
    SUM(o.total_amount) - COALESCE(SUM(p.amount), 0) AS outstanding
FROM customers c
JOIN orders o ON o.customer_id = c.id
LEFT JOIN payments p ON p.order_id = o.id
WHERE o.created_at < now() - INTERVAL '30 days'
GROUP BY c.id
HAVING SUM(o.total_amount) - COALESCE(SUM(p.amount), 0) > 0;
```

- Returns all customers with unpaid balances older than 30 days.
- Takes partial payments into account.

---

## Concurrency and Multi-Tenant Safety

- **Atomic Transactions:** All purchase logic is executed inside a single transaction, guaranteeing either **full success or full rollback**.
- **Row Locking (`FOR UPDATE`):** Prevents overselling or credit limit violations in concurrent requests.
- **Tenant Isolation:** `business_id` is included in all queries, ensuring one business cannot affect another’s data.
- **Partial Payments:** Properly reduce outstanding balance and allow subsequent purchases within credit limits.

---

## Environment Variables

Create `.env.local` at the project root:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
```

- **Use server-only keys** (never expose to client).
- Restart Next.js after updating `.env.local`.

---

## Seed Data

- `sql/seed.sql` contains example businesses, customers, and products for testing.
- Use these for API testing or to simulate concurrent requests.

---

## How to Run

````bash
# Install dependencies
npm install

# Start development server
npm run dev

# Test API endpoint
POST http://localhost:3000/api/purchase

---

## Testing

The project uses **Jest** and **React Testing Library** for unit and integration tests.

```bash
# Run all tests
npm test

# Run tests in watch mode
npm run test:watch
````

Tests are located in the `__tests__` directory and cover server actions and API routes.

---

## Docker

You can run the entire application using Docker.

### Prerequisites

- Docker and Docker Compose installed.
- `.env.local` file with Supabase credentials.

### Running with Docker Compose

```bash
# Build and start the container
docker-compose up --build
```

The application will be available at `http://localhost:3000`.

### Dockerfile Details

The `Dockerfile` uses a multi-stage build:

1. **deps**: Installs production and development dependencies.
2. **builder**: Builds the Next.js application using the `standalone` output for minimal image size.
3. **runner**: Optimized production image running as a non-root user.

---

## Optional Enhancements

- Indexes for faster queries: `orders(customer_id, business_id)`, `products(business_id)`.
- View for real-time outstanding balances.
- More detailed JSON errors for API clients.

---

## Summary

This backend demonstrates:

- Correct **multi-tenant database design**
- Atomic and concurrency-safe **purchase logic**
- **Credit and stock validation**
- **Partial payment handling**
- Query for **overdue customers**
- Clear **API exposure** for testing
