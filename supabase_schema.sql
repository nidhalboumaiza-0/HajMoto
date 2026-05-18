-- ============================================
-- Gestion Stock - Supabase Database Schema
-- Motorcycle Spare Parts Shop Management
-- ============================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- 1. PRODUCTS TABLE
-- ============================================
CREATE TABLE products (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  reference_code TEXT NOT NULL UNIQUE,
  name TEXT NOT NULL,
  category TEXT NOT NULL CHECK (category IN ('vespa_parts', 'forza_parts', 'vespa_scooter', 'forza_scooter')),
  purchase_price DOUBLE PRECISION NOT NULL DEFAULT 0,
  selling_price DOUBLE PRECISION NOT NULL DEFAULT 0,
  quantity INTEGER NOT NULL DEFAULT 0,
  low_stock_threshold INTEGER NOT NULL DEFAULT 5,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index for fast lookups
CREATE INDEX idx_products_reference ON products (reference_code);
CREATE INDEX idx_products_category ON products (category);
CREATE INDEX idx_products_name ON products (name);

-- ============================================
-- 2. CLIENTS TABLE
-- ============================================
CREATE TABLE clients (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  mobile_number TEXT NOT NULL,
  cin TEXT NOT NULL UNIQUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_clients_cin ON clients (cin);
CREATE INDEX idx_clients_mobile ON clients (mobile_number);

-- ============================================
-- 3. SALES TABLE
-- ============================================
CREATE TABLE sales (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  product_id UUID NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
  client_id UUID NOT NULL REFERENCES clients(id) ON DELETE RESTRICT,
  reference_code TEXT NOT NULL,
  product_name TEXT NOT NULL,
  quantity INTEGER NOT NULL,
  selling_price DOUBLE PRECISION NOT NULL,
  purchase_price DOUBLE PRECISION NOT NULL,
  total_without_tva DOUBLE PRECISION NOT NULL,
  tva_amount DOUBLE PRECISION NOT NULL,
  total_with_tva DOUBLE PRECISION NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_sales_product ON sales (product_id);
CREATE INDEX idx_sales_client ON sales (client_id);
CREATE INDEX idx_sales_created ON sales (created_at DESC);

-- ============================================
-- 4. INVOICES TABLE
-- ============================================
CREATE TABLE invoices (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  invoice_number TEXT NOT NULL UNIQUE,
  sale_id UUID NOT NULL REFERENCES sales(id) ON DELETE RESTRICT,
  client_id UUID NOT NULL REFERENCES clients(id) ON DELETE RESTRICT,
  client_name TEXT NOT NULL,
  client_cin TEXT NOT NULL,
  client_mobile TEXT NOT NULL,
  product_name TEXT NOT NULL,
  reference_code TEXT NOT NULL,
  quantity INTEGER NOT NULL,
  unit_price DOUBLE PRECISION NOT NULL,
  total_without_tva DOUBLE PRECISION NOT NULL,
  tva_amount DOUBLE PRECISION NOT NULL,
  total_with_tva DOUBLE PRECISION NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_invoices_number ON invoices (invoice_number);
CREATE INDEX idx_invoices_client ON invoices (client_id);
CREATE INDEX idx_invoices_created ON invoices (created_at DESC);

-- ============================================
-- 5. ROW LEVEL SECURITY (RLS)
-- Enable RLS and allow all operations for authenticated users
-- ============================================
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE clients ENABLE ROW LEVEL SECURITY;
ALTER TABLE sales ENABLE ROW LEVEL SECURITY;
ALTER TABLE invoices ENABLE ROW LEVEL SECURITY;

-- Policies for products
CREATE POLICY "Allow all for products" ON products FOR ALL USING (true) WITH CHECK (true);

-- Policies for clients
CREATE POLICY "Allow all for clients" ON clients FOR ALL USING (true) WITH CHECK (true);

-- Policies for sales
CREATE POLICY "Allow all for sales" ON sales FOR ALL USING (true) WITH CHECK (true);

-- Policies for invoices
CREATE POLICY "Allow all for invoices" ON invoices FOR ALL USING (true) WITH CHECK (true);

-- ============================================
-- 6. TRIGGER: Auto-update updated_at on products
-- ============================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_products_updated_at
  BEFORE UPDATE ON products
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
