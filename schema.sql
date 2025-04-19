-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Set up auth schema (if not already set up by Supabase)
-- This is automatically handled by Supabase, but included for completeness
CREATE SCHEMA IF NOT EXISTS auth;

-- User table
-- Maps to the User entity in the ER diagram
CREATE TABLE public.users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    auth_id UUID UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    is_registered BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Couple table
-- Maps to the Couple entity in the ER diagram
CREATE TABLE public.couples (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user1_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    user2_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    status TEXT NOT NULL CHECK (status IN ('pending', 'active', 'inactive')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT unique_couple UNIQUE (user1_id, user2_id),
    CONSTRAINT different_users CHECK (user1_id != user2_id)
);

-- Family History table
-- Maps to the FamilyHistory entity in the ER diagram
CREATE TABLE public.family_histories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    responses JSONB NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Test Package table
-- Maps to the TestPackage entity in the ER diagram
CREATE TABLE public.test_packages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    price DECIMAL NOT NULL CHECK (price >= 0),
    description TEXT,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Order table
-- Maps to the Order entity in the ER diagram
CREATE TABLE public.orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    couple_id UUID NOT NULL REFERENCES public.couples(id) ON DELETE CASCADE,
    package_id UUID NOT NULL REFERENCES public.test_packages(id) ON DELETE RESTRICT,
    payment_status TEXT NOT NULL CHECK (payment_status IN ('pending', 'completed', 'failed', 'refunded')),
    payment_intent_id TEXT,
    order_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Test Kit table
-- Maps to the TestKit entity in the ER diagram
CREATE TABLE public.test_kits (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    status TEXT NOT NULL CHECK (status IN ('created', 'shipped', 'delivered', 'returned', 'received', 'processing', 'processed')),
    tracking_number TEXT,
    shipped_date TIMESTAMP WITH TIME ZONE,
    received_date TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Genetic Data table
-- Maps to the GeneticData entity in the ER diagram
CREATE TABLE public.genetic_data (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    kit_id UUID UNIQUE REFERENCES public.test_kits(id) ON DELETE CASCADE,
    raw_data BYTEA, -- For small genetic data, consider using JSONB instead
    processed_flag BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Test Result table
-- Maps to the TestResult entity in the ER diagram
CREATE TABLE public.test_results (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    couple_id UUID NOT NULL REFERENCES public.couples(id) ON DELETE CASCADE,
    high_risk BOOLEAN NOT NULL DEFAULT FALSE,
    report_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Counseling Session table
-- Maps to the CounselingSession entity in the ER diagram
CREATE TABLE public.counseling_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    result_id UUID NOT NULL REFERENCES public.test_results(id) ON DELETE CASCADE,
    scheduled_time TIMESTAMP WITH TIME ZONE NOT NULL,
    completed BOOLEAN NOT NULL DEFAULT FALSE,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Child Risk Prediction table
-- Maps to the ChildRiskPrediction entity in the ER diagram
CREATE TABLE public.child_risk_predictions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    result_id UUID NOT NULL REFERENCES public.test_results(id) ON DELETE CASCADE,
    condition TEXT NOT NULL,
    risk_percentage DECIMAL NOT NULL CHECK (risk_percentage >= 0 AND risk_percentage <= 100),
    details TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    CONSTRAINT unique_condition_per_result UNIQUE (result_id, condition)
);

-- Row Level Security Policies
-- These are important for Supabase to control access to data

-- Users can only view and edit their own profile
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own profile" 
ON public.users FOR SELECT 
USING (auth.uid() = auth_id);

CREATE POLICY "Users can update their own profile" 
ON public.users FOR UPDATE 
USING (auth.uid() = auth_id);

-- Couples policies
ALTER TABLE public.couples ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view couples they belong to" 
ON public.couples FOR SELECT 
USING (auth.uid() IN (
    SELECT auth_id FROM public.users WHERE id = user1_id OR id = user2_id
));

-- Orders policies
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their couples' orders" 
ON public.orders FOR SELECT 
USING (EXISTS (
    SELECT 1 FROM public.couples c
    JOIN public.users u ON (u.id = c.user1_id OR u.id = c.user2_id)
    WHERE c.id = couple_id AND u.auth_id = auth.uid()
));

-- Test kits policies
ALTER TABLE public.test_kits ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own test kits" 
ON public.test_kits FOR SELECT 
USING (EXISTS (
    SELECT 1 FROM public.users u
    WHERE u.id = user_id AND u.auth_id = auth.uid()
));

-- Test results policies
ALTER TABLE public.test_results ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their couples' results" 
ON public.test_results FOR SELECT 
USING (EXISTS (
    SELECT 1 FROM public.couples c
    JOIN public.users u ON (u.id = c.user1_id OR u.id = c.user2_id)
    WHERE c.id = couple_id AND u.auth_id = auth.uid()
));

-- Useful indexes for performance
CREATE INDEX idx_users_auth_id ON public.users(auth_id);
CREATE INDEX idx_couples_user1_id ON public.couples(user1_id);
CREATE INDEX idx_couples_user2_id ON public.couples(user2_id);
CREATE INDEX idx_family_histories_user_id ON public.family_histories(user_id);
CREATE INDEX idx_orders_couple_id ON public.orders(couple_id);
CREATE INDEX idx_test_kits_order_id ON public.test_kits(order_id);
CREATE INDEX idx_test_kits_user_id ON public.test_kits(user_id);
CREATE INDEX idx_test_results_couple_id ON public.test_results(couple_id);
CREATE INDEX idx_counseling_sessions_result_id ON public.counseling_sessions(result_id);
CREATE INDEX idx_child_risk_predictions_result_id ON public.child_risk_predictions(result_id);

-- Create functions for handling timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Add triggers to update the updated_at column automatically
CREATE TRIGGER set_updated_at_users
BEFORE UPDATE ON public.users
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_updated_at_couples
BEFORE UPDATE ON public.couples
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_updated_at_family_histories
BEFORE UPDATE ON public.family_histories
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_updated_at_test_packages
BEFORE UPDATE ON public.test_packages
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_updated_at_orders
BEFORE UPDATE ON public.orders
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_updated_at_test_kits
BEFORE UPDATE ON public.test_kits
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_updated_at_genetic_data
BEFORE UPDATE ON public.genetic_data
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_updated_at_test_results
BEFORE UPDATE ON public.test_results
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_updated_at_counseling_sessions
BEFORE UPDATE ON public.counseling_sessions
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER set_updated_at_child_risk_predictions
BEFORE UPDATE ON public.child_risk_predictions
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();