import os

from dotenv import load_dotenv
import pandas as pd
import numpy as np
from faker import Faker
import snowflake.connector
from datetime import datetime, timedelta
import random

fake = Faker()
np.random.seed(42)
random.seed(42)

load_dotenv()

# ─── CONFIG SNOWFLAKE ────────────────────────────────────────────
conn = snowflake.connector.connect(
    account   = os.environ.get('SNOWFLAKE_ACCOUNT'),
    user      = os.environ.get('SNOWFLAKE_USER'),
    password  = os.environ.get('SNOWFLAKE_PASSWORD'),
    warehouse = 'retailpulse_wh',
    database  = 'retailpulse',
    schema    = 'raw',
    role      = 'dbt_role'
)
cursor = conn.cursor()

# ─── HELPERS ─────────────────────────────────────────────────────
def random_date(start, end):
    return start + timedelta(days=random.randint(0, (end - start).days))

START = datetime(2023, 1, 1)
END   = datetime(2024, 12, 31)

COUNTRIES  = ['CI', 'SN', 'ML', 'BF', 'GN', 'TG', 'BJ', 'CM']
CHANNELS   = ['organic', 'paid_search', 'social', 'email', 'referral', 'direct']
CATEGORIES = ['Informatique', 'Telephonie', 'Electromenager', 'Audio', 'Accessoires']
STATUSES   = ['completed', 'cancelled', 'pending', 'refunded']
PAYMENT    = ['mobile_money', 'card', 'cash', 'bank_transfer']

# ─── 1. CUSTOMERS (1000 lignes) ───────────────────────────────────
print("Generating customers...")
customers = []
for i in range(1, 1001):
    country = random.choice(COUNTRIES)
    customers.append({
        'customer_id'   : i,
        'first_name'    : fake.first_name(),
        'last_name'     : fake.last_name(),
        'email'         : fake.email() if random.random() > 0.03 else None,
        'phone'         : fake.phone_number()[:20],
        'country'       : country,
        'city'          : fake.city()[:50],
        'segment'       : random.choice(['B2C', 'B2B', 'B2B']),
        'created_at'    : random_date(START, END).date(),
        'is_active'     : random.random() > 0.1
    })
df_customers = pd.DataFrame(customers)

# ─── 2. PRODUCTS (50 lignes) ──────────────────────────────────────
print("Generating products...")
product_names = [
    'Laptop Pro 15', 'Laptop Air 13', 'Smartphone X12', 'Smartphone Y8',
    'Tablette Z10', 'Casque BT Pro', 'Casque Gaming', 'Ecouteurs TWS',
    'Imprimante Laser', 'Imprimante Jet', 'Disque SSD 1TB', 'Disque HDD 2TB',
    'Clavier Meca', 'Souris Gaming', 'Webcam 4K', 'Micro USB', 'Hub USB-C',
    'Chargeur 65W', 'Cable HDMI', 'Ecran 27p 4K', 'Ecran 24p FHD',
    'Frigo 300L', 'Machine a laver', 'Climatiseur 12000', 'Ventilateur Tower',
    'Fer a repasser', 'Micro-ondes', 'Mixeur Pro', 'Cafetiere', 'Grille-pain',
    'TV 55p 4K', 'TV 43p FHD', 'Barre de son', 'Enceinte BT', 'Projecteur HD',
    'Batterie 20000mAh', 'Batterie 10000mAh', 'Coque iPhone', 'Coque Samsung',
    'Film protection', 'Sac laptop 15p', 'Sac laptop 13p', 'Tapis souris XL',
    'Lampe bureau LED', 'Support laptop', 'Switch 8 ports', 'Routeur WiFi6',
    'Camera IP', 'Disque Externe 1TB', 'SSD Externe 500GB'
]
products = []
for i, name in enumerate(product_names, 1):
    cat   = random.choice(CATEGORIES)
    cost  = round(random.uniform(5000, 200000), 2)
    price = round(cost * random.uniform(1.3, 2.5), 2)
    products.append({
        'product_id'  : i,
        'product_name': name,
        'category'    : cat,
        'cost_price'  : cost,
        'sell_price'  : price,
        'stock_qty'   : random.randint(0, 200),
        'is_active'   : random.random() > 0.05
    })
df_products = pd.DataFrame(products)

# ─── 3. CAMPAIGNS (20 lignes) ────────────────────────────────────
print("Generating campaigns...")
campaigns = []
for i in range(1, 21):
    start = random_date(START, datetime(2024, 6, 1))
    campaigns.append({
        'campaign_id'  : i,
        'campaign_name': f'Campaign_{fake.word().capitalize()}_{i}',
        'channel'      : random.choice(CHANNELS),
        'budget'       : round(random.uniform(100000, 5000000), 2),
        'start_date'   : start.date(),
        'end_date'     : (start + timedelta(days=random.randint(7, 90))).date(),
        'target_country': random.choice(COUNTRIES + [None]),
        'status'       : random.choice(['active', 'completed', 'paused'])
    })
df_campaigns = pd.DataFrame(campaigns)

# ─── 4. ORDERS (5000 lignes) ─────────────────────────────────────
print("Generating orders...")
orders = []
for i in range(1, 5001):
    status = random.choices(STATUSES, weights=[70, 15, 10, 5])[0]
    orders.append({
        'order_id'      : i,
        'customer_id'   : random.randint(1, 1000),
        'order_date'    : random_date(START, END).date(),
        'status'        : status,
        'payment_method': random.choice(PAYMENT),
        'channel'       : random.choice(CHANNELS),
        'campaign_id'   : random.randint(1, 20) if random.random() > 0.4 else None,
        'shipping_cost' : round(random.uniform(0, 15000), 2)
    })
df_orders = pd.DataFrame(orders)

# ─── 5. ORDER ITEMS (12000 lignes) ───────────────────────────────
print("Generating order items...")
order_items = []
item_id = 1
for order_id in range(1, 5001):
    nb_items = random.choices([1, 2, 3, 4], weights=[50, 30, 15, 5])[0]
    products_chosen = random.sample(range(1, 51), min(nb_items, 50))
    for prod_id in products_chosen:
        price = df_products.loc[df_products.product_id == prod_id, 'sell_price'].values[0]
        qty   = random.randint(1, 5)
        order_items.append({
            'item_id'   : item_id,
            'order_id'  : order_id,
            'product_id': prod_id,
            'quantity'  : qty,
            'unit_price': price,
            'discount'  : round(random.uniform(0, 0.3), 2) if random.random() > 0.7 else 0
        })
        item_id += 1
df_order_items = pd.DataFrame(order_items)

# ─── 6. SESSIONS (15000 lignes) ──────────────────────────────────
print("Generating sessions...")
sessions = []
for i in range(1, 15001):
    sessions.append({
        'session_id'    : i,
        'customer_id'   : random.randint(1, 1000) if random.random() > 0.3 else None,
        'session_date'  : random_date(START, END).date(),
        'channel'       : random.choice(CHANNELS),
        'campaign_id'   : random.randint(1, 20) if random.random() > 0.5 else None,
        'pages_viewed'  : random.randint(1, 30),
        'duration_sec'  : random.randint(10, 3600),
        'converted'     : random.random() > 0.7,
        'device'        : random.choice(['mobile', 'desktop', 'tablet'])
    })
df_sessions = pd.DataFrame(sessions)

# ─── 7. REFUNDS (300 lignes) ─────────────────────────────────────
print("Generating refunds...")
refunded_orders = df_orders[df_orders.status == 'refunded'].order_id.tolist()
refunds = []
for i, order_id in enumerate(refunded_orders[:300], 1):
    refunds.append({
        'refund_id'    : i,
        'order_id'     : order_id,
        'refund_date'  : random_date(START, END).date(),
        'refund_amount': round(random.uniform(5000, 500000), 2),
        'reason'       : random.choice(['defect', 'wrong_item', 'not_delivered', 'changed_mind'])
    })
df_refunds = pd.DataFrame(refunds)

# ─── CHARGEMENT SNOWFLAKE ─────────────────────────────────────────
def load_df(df, table_name):
    print(f"Loading {table_name} ({len(df)} rows)...")

    def get_col_type(col, dtype):
        if col in ['created_at', 'start_date', 'end_date', 'order_date',
                   'session_date', 'refund_date']:
            return 'DATE'
        if dtype == bool or str(dtype) == 'bool':
            return 'BOOLEAN'
        if str(dtype).startswith('float'):
            return 'FLOAT'
        if str(dtype).startswith('int') or str(dtype) in ['int64', 'int32']:
            return 'NUMBER'
        return 'VARCHAR'

    cols = ', '.join([
        f'{c} {get_col_type(c, df[c].dtype)}'
        for c in df.columns
    ])

    cursor.execute(f"DROP TABLE IF EXISTS raw.{table_name}")
    cursor.execute(f"CREATE TABLE raw.{table_name} ({cols})")

    rows = [tuple(
        None if pd.isna(v)
        else bool(v) if isinstance(v, (bool, np.bool_))
        else str(v) if hasattr(v, 'isoformat')
        else v
        for v in row
    ) for row in df.itertuples(index=False)]

    placeholders = ', '.join(['%s'] * len(df.columns))
    cursor.executemany(
        f"INSERT INTO raw.{table_name} VALUES ({placeholders})",
        rows
    )
    print(f"  {table_name} loaded.")

load_df(df_customers,   'raw_customers')
load_df(df_products,    'raw_products')
load_df(df_campaigns,   'raw_campaigns')
load_df(df_orders,      'raw_orders')
load_df(df_order_items, 'raw_order_items')
load_df(df_sessions,    'raw_sessions')
load_df(df_refunds,     'raw_refunds')

cursor.close()
conn.close()
print("\nDone — toutes les tables sont chargées dans Snowflake.")