-- Create the test database
CREATE DATABASE testDB;
GO
USE testDB;
EXEC sys.sp_cdc_enable_db;

-- Create and populate our products using a single insert with many rows
CREATE TABLE products (
  id INTEGER IDENTITY(101,1) NOT NULL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  description VARCHAR(512),
  weight FLOAT
);
INSERT INTO products(name,description,weight)
  VALUES ('scooter','Small 2-wheel scooter',3.14);
INSERT INTO products(name,description,weight)
  VALUES ('car battery','12V car battery',8.1);
INSERT INTO products(name,description,weight)
  VALUES ('12-pack drill bits','12-pack of drill bits with sizes ranging from #40 to #3',0.8);
INSERT INTO products(name,description,weight)
  VALUES ('hammer','12oz carpenter''s hammer',0.75);
INSERT INTO products(name,description,weight)
  VALUES ('hammer','14oz carpenter''s hammer',0.875);
INSERT INTO products(name,description,weight)
  VALUES ('hammer','16oz carpenter''s hammer',1.0);
INSERT INTO products(name,description,weight)
  VALUES ('rocks','box of assorted rocks',5.3);
INSERT INTO products(name,description,weight)
  VALUES ('jacket','water resistent black wind breaker',0.1);
INSERT INTO products(name,description,weight)
  VALUES ('spare tire','24 inch spare tire',22.2);
EXEC sys.sp_cdc_enable_table @source_schema = 'dbo', @source_name = 'products', @role_name = NULL, @supports_net_changes = 0;
-- Create and populate the products on hand using multiple inserts
CREATE TABLE products_on_hand (
  product_id INTEGER NOT NULL PRIMARY KEY,
  quantity INTEGER NOT NULL,
  FOREIGN KEY (product_id) REFERENCES products(id)
);
INSERT INTO products_on_hand VALUES (101,3);
INSERT INTO products_on_hand VALUES (102,8);
INSERT INTO products_on_hand VALUES (103,18);
INSERT INTO products_on_hand VALUES (104,4);
INSERT INTO products_on_hand VALUES (105,5);
INSERT INTO products_on_hand VALUES (106,0);
INSERT INTO products_on_hand VALUES (107,44);
INSERT INTO products_on_hand VALUES (108,2);
INSERT INTO products_on_hand VALUES (109,5);
EXEC sys.sp_cdc_enable_table @source_schema = 'dbo', @source_name = 'products_on_hand', @role_name = NULL, @supports_net_changes = 0;
-- Create some customers ...
CREATE TABLE customers (
  id INTEGER IDENTITY(1001,1) NOT NULL PRIMARY KEY,
  first_name VARCHAR(255) NOT NULL,
  last_name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE
);
INSERT INTO customers(first_name,last_name,email)
  VALUES ('Sally','Thomas','sally.thomas@acme.com');
INSERT INTO customers(first_name,last_name,email)
  VALUES ('George','Bailey','gbailey@foobar.com');
INSERT INTO customers(first_name,last_name,email)
  VALUES ('Edward','Walker','ed@walker.com');
INSERT INTO customers(first_name,last_name,email)
  VALUES ('Anne','Kretchmar','annek@noanswer.org');
EXEC sys.sp_cdc_enable_table @source_schema = 'dbo', @source_name = 'customers', @role_name = NULL, @supports_net_changes = 0;
-- Create some very simple orders
CREATE TABLE orders (
  id INTEGER IDENTITY(10001,1) NOT NULL PRIMARY KEY,
  order_date DATE NOT NULL,
  purchaser INTEGER NOT NULL,
  quantity INTEGER NOT NULL,
  product_id INTEGER NOT NULL,
  FOREIGN KEY (purchaser) REFERENCES customers(id),
  FOREIGN KEY (product_id) REFERENCES products(id)
);
INSERT INTO orders(order_date,purchaser,quantity,product_id)
  VALUES ('16-JAN-2016', 1001, 1, 102);
INSERT INTO orders(order_date,purchaser,quantity,product_id)
  VALUES ('17-JAN-2016', 1002, 2, 105);
INSERT INTO orders(order_date,purchaser,quantity,product_id)
  VALUES ('19-FEB-2016', 1002, 2, 106);
INSERT INTO orders(order_date,purchaser,quantity,product_id)
  VALUES ('21-FEB-2016', 1003, 1, 107);
EXEC sys.sp_cdc_enable_table @source_schema = 'dbo', @source_name = 'orders', @role_name = NULL, @supports_net_changes = 0;

-- CREATE reproducer table
CREATE TABLE [repro] (
       [PK] [uniqueidentifier] NOT NULL,
       [LineType] [char](3) NOT NULL,
       [Sequence] [smallint] NOT NULL,
       [Desc] [nvarchar](1024) NOT NULL,
       [LineAmount] [money] NOT NULL,
       [GSTVAT] [money] NOT NULL,
       [AW] [uniqueidentifier] NULL,
       [WithholdingTax] [money] NOT NULL,
       [UnitQty] [int] NOT NULL,
       [UnitPrice] [money] NOT NULL,
       [OSUnitPrice] [money] NOT NULL,
       [OSAmount] [money] NOT NULL,
       [ExchangeRate] [numeric](18, 9) NOT NULL,
       [PostPeriod] [int] NOT NULL,
       [PostDate] [smalldatetime] NULL,
       [PostToGL] [varchar](1) NOT NULL,
       [ReversePeriod] [int] NOT NULL,
       [ReverseDate] [smalldatetime] NULL,
       [ReverseToGL] [varchar](1) NOT NULL,
       [ExportBatchNumber] [int] NOT NULL,
       [ExportReverseBatchNumber] [int] NOT NULL,
       [AG_PercentOf] [uniqueidentifier] NULL,
       [PercentageOfPeriod] [int] NOT NULL,
       [RevRecognitionType] [varchar](3) NOT NULL,
       [RX_NKTransactionCurrency] [varchar](3) NOT NULL,
       [SystemLastEditTimeUtc] [smalldatetime] NULL,
       [SystemLastEditUser] [varchar](3) NOT NULL,
       [SystemCreateTimeUtc] [smalldatetime] NULL,
       [SystemCreateUser] [varchar](3) NOT NULL,
       [GSTVATBasis] [char](1) NOT NULL,
       [A9_VATClass] [uniqueidentifier] NULL,
       [SubClassParentTableCode] [varchar](3) NOT NULL,
       [SubClassParentId] [uniqueidentifier] NULL,
       [PreventInvoicePrintGrouping] [bit] NOT NULL,
       [IsFinalCharge] [bit] NOT NULL,
       [InputGSTVATRecoverable] [numeric](5, 4) NOT NULL,
       [PostedTime] [datetime] NULL,
       [EventTime] [datetime] NULL,
       [GovtChargeCode] [nvarchar](20) NULL,
       [GSTVATExtra] [money] NULL,
       [TaxDate] [date] NULL,
       [TaxExtraRateDenominator] [int] NULL,
       [TaxExtraRateNumerator] [int] NULL,
       [TaxRateDenominator] [int] NULL,
       [TaxRateNumerator] [int] NULL,
       [PlaceOfSupply] [varchar](5) NULL,
       [PlaceOfSupplyType] [varchar](3) NULL,
CONSTRAINT [PK_AccTransactionLines] PRIMARY KEY CLUSTERED(PK));
INSERT INTO repro VALUES(
    'A0512838-BB95-4320-9B57-000001B8E4B1',
    'ACR',
    1,
    'GST PAID ON BEHALF - DP1L374709R',
    576.00,
    0,
    NULL,
    0.00,
    0,
    0.00,
    0.00,
    576.00,
    1,
    0,
    '12/1/2011 0:00',
    'Y',                                 
    0,
    '12/1/2011 0:00',
    'Y',
    0,
    0,
    NULL,
    0,
    'ARV',
    'SGD',
    '12/9/2011 3:44',
    'JOA',
    '12/1/2011 10:04',
    'LEN',
    'A',
    NULL,
    '' ,
    NULL,
    0,
    0,
    1,
    NULL,
    NULL,
    '' ,
    0,
    NULL,
    1,
    0,
    1,
    0,
    NULL,
    NULL
    );
EXEC sys.sp_cdc_enable_table @source_schema = 'dbo', @source_name = 'repro', @role_name = NULL, @supports_net_changes = 0;
GO
