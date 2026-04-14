#!/bin/bash

generate_html() {
    local unknown="$1"
    local known="$2"
    local table_data="$3"
    local timestamp
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")

    cat <<EOF > "logs/report.html"
<!DOCTYPE html>
<html lang="no">
<head>
    <meta charset="UTF-8">
    <title>Network Watchdog Rapport</title>
    <style>
        body { font-family: sans-serif; background: #f0f2f5; margin: 40px; }
        .container { background: white; padding: 30px; border-radius: 12px; max-width: 900px; margin: auto; }
        .box { padding: 20px; border-radius: 8px; flex: 1; text-align: center; color: white; font-weight: bold; }
        .known-box { background: #28a745; }
        .unknown-box { background: #dc3545; }
        table { width: 100%; border-collapse: collapse; margin-top: 25px; }
        th, td { padding: 15px; text-align: left; border-bottom: 1px solid #dee2e6; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Nettverksstatus</h1>
        <p>Generert: $timestamp</p>
        <div style="display: flex; gap: 15px;">
            <div class="box known-box">Kjente: $known</div>
            <div class="box unknown-box">Ukjente: $unknown</div>
        </div>
        <table>
            <thead>
                <tr><th>IP</th><th>MAC</th><th>Produsent</th><th>Status</th></tr>
            </thead>
            <tbody>
                $table_data
            </tbody>
        </table>
    </div>
</body>
</html>
EOF
}