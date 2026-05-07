-- Создание базы данных
CREATE DATABASE ProductionDB;
GO
USE ProductionDB;
GO

-- Таблица: Рецептуры (recipes)
CREATE TABLE recipes (
    id INT PRIMARY KEY IDENTITY(1,1),
    name NVARCHAR(100) NOT NULL,
    version INT NOT NULL,
    status NVARCHAR(20) CHECK (status IN ('active', 'draft', 'archived')),
    created_at DATETIME2 NOT NULL,
    CONSTRAINT UQ_Recipe_Name_Version UNIQUE (name, version)
);
GO

-- Таблица: Производственные заказы (production_orders)
CREATE TABLE production_orders (
    id INT PRIMARY KEY IDENTITY(1,1),
    order_number NVARCHAR(50) UNIQUE NOT NULL,
    recipe_id INT NOT NULL,
    planned_quantity_kg DECIMAL(10,2) NOT NULL,
    status NVARCHAR(20) CHECK (status IN ('draft', 'planned', 'in_progress', 'completed', 'archived')),
    planned_start_date DATE NOT NULL,
    FOREIGN KEY (recipe_id) REFERENCES recipes(id),
    INDEX IX_Order_Status (status)
);
GO

-- Таблица: Производственные партии (batches)
CREATE TABLE batches (
    id INT PRIMARY KEY IDENTITY(1,1),
    batch_number NVARCHAR(50) UNIQUE NOT NULL,
    order_id INT NOT NULL,
    start_time DATETIME2 NOT NULL,
    end_time DATETIME2 NULL,
    status NVARCHAR(20) CHECK (status IN ('planned', 'running', 'completed', 'cancelled')),
    actual_quantity_kg DECIMAL(10,2) DEFAULT 0,
    FOREIGN KEY (order_id) REFERENCES production_orders(id),
    INDEX IX_Batch_Order (order_id),
    INDEX IX_Batch_Status (status)
);
GO

-- Таблица: Этапы производства (production_steps)
CREATE TABLE production_steps (
    id INT PRIMARY KEY IDENTITY(1,1),
    batch_id INT NOT NULL,
    step_order INT NOT NULL,
    step_name NVARCHAR(100) NOT NULL,
    planned_temp_c DECIMAL(5,2),
    actual_temp_c DECIMAL(5,2),
    planned_duration_min INT,
    actual_duration_min INT,
    planned_pressure_bar DECIMAL(4,2),
    actual_pressure_bar DECIMAL(4,2),
    deviation_flag BIT DEFAULT 0,
    operator_comment NVARCHAR(500),
    FOREIGN KEY (batch_id) REFERENCES batches(id),
    CONSTRAINT UQ_Batch_Step UNIQUE (batch_id, step_order)
);
GO

-- Таблица: Контроль качества (quality_control)
CREATE TABLE quality_control (
    id INT PRIMARY KEY IDENTITY(1,1),
    batch_id INT NOT NULL,
    analysis_date DATETIME2 NOT NULL,
    sample_type NVARCHAR(50) NOT NULL,
    parameter_name NVARCHAR(100) NOT NULL,
    measured_value DECIMAL(10,3),
    standard_value NVARCHAR(50),
    unit NVARCHAR(20),
    result NVARCHAR(10) CHECK (result IN ('pass', 'fail')),
    decision NVARCHAR(20) CHECK (decision IN ('approved', 'blocked', 'pending')),
    analyst_comment NVARCHAR(500),
    FOREIGN KEY (batch_id) REFERENCES batches(id),
    INDEX IX_QC_Batch (batch_id),
    INDEX IX_QC_Date (analysis_date)
);
GO