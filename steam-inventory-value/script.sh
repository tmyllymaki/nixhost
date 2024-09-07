#!/usr/bin/env -S nix shell nixpkgs#bash nixpkgs#httpie nixpkgs#sqlite nixpkgs#jq --command bash

https PUT https://montuga.com/api/inventories/76561198102246528/730 > inventory.json 

echo '"item","price","amount"' > inventory.csv

jq -r '.items | .[] | select(.common.marketable == 1) | {name: .common.name, sell_price: .common.sell_price_ts_24h, count: .amount} | map(tostring) | @csv' < inventory.json >> inventory.csv

sqlite3 inventory.sqlite <<EOF
CREATE TABLE IF NOT EXISTS inventory (
    item TEXT,
    price REAL,
    amount INTEGER,
    date TEXT DEFAULT CURRENT_TIMESTAMP
);
EOF

# Import CSV data into the staging table
sqlite3 -csv inventory.sqlite ".import 'inventory.csv' inventory_staging"

# Insert data from the staging table into the main table
sqlite3 inventory.sqlite <<EOF
INSERT INTO inventory (item, price, amount)
SELECT item, price, amount FROM inventory_staging;
EOF

# Optional: Drop the staging table if no longer needed
sqlite3 inventory.sqlite "DROP TABLE IF EXISTS inventory_staging;"

# Cleanup
rm inventory.json inventory.csv
