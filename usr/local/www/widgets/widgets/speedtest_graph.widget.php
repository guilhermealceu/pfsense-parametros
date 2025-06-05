
<?php
require_once("guiconfig.inc");

$data_vivo = [];
$data_ligga = [];
$file = "/root/speedtest-data.csv";
$max_points = 12;

if (file_exists($file)) {
    $lines = file($file, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    $lines = array_slice($lines, 1); // Remove o cabeçalho
    
    // Separa os dados por gateway
    foreach ($lines as $line) {
        $fields = str_getcsv($line);
        if (count($fields) >= 5) {
            $entry = [
                'timestamp' => date("H:i", strtotime($fields[0])),
                'gateway' => $fields[1],
                'download' => (float)$fields[2],
                'upload' => (float)$fields[3],
                'ping' => (float)$fields[4]
            ];

            if (stripos($fields[1], "vivo") !== false) {
                $data_vivo[] = $entry;
            } elseif (stripos($fields[1], "ligga") !== false) {
                $data_ligga[] = $entry;
            }
        }
    }

    // Pega apenas os últimos N registros
    $data_vivo = array_slice($data_vivo, -$max_points);
    $data_ligga = array_slice($data_ligga, -$max_points);
}
?>

<div class="speed-chart-widget">
    <?php
    function renderChart($id, $title, $data) {
        if (empty($data)) return;

        $latest = end($data);
    ?>
    <div class="chart-header">
        <div class="chart-title"><?= htmlspecialchars($title) ?></div>
    </div>

    <div class="chart-container">
        <canvas id="<?= $id ?>"></canvas>
    </div>

    <div class="current-speeds">
        <div class="current-speed download">
            <span class="speed-value"><?= round($latest['download'], 1) ?></span>
            <span class="speed-unit">Mbps</span>
            <span class="speed-label">Download</span>
        </div>
        <div class="current-speed upload">
            <span class="speed-value"><?= round($latest['upload'], 1) ?></span>
            <span class="speed-unit">Mbps</span>
            <span class="speed-label">Upload</span>
        </div>
        <div class="current-speed ping">
            <span class="speed-value"><?= round($latest['ping'], 1) ?></span>
            <span class="speed-unit">ms</span>
            <span class="speed-label">Ping</span>
        </div>
    </div>

    <div class="chart-footer">
        Último teste: <?= date("d/m H:i", strtotime($latest['timestamp'])) ?>
    </div>
    <?php } ?>

    <?php renderChart('speedChartVivo', 'Vivo', $data_vivo); ?>
    <?php renderChart('speedChartLigga', 'Ligga', $data_ligga); ?>
</div>

<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script>
document.addEventListener('DOMContentLoaded', function() {
    function createChart(id, labels, downloadData, uploadData) {
        const ctx = document.getElementById(id).getContext('2d');
        new Chart(ctx, {
            type: 'line',
            data: {
                labels: labels,
                datasets: [
                    {
                        label: 'Download',
                        data: downloadData,
                        borderColor: '#4285F4',
                        backgroundColor: 'rgba(66, 133, 244, 0.1)',
                        borderWidth: 2,
                        tension: 0.3,
                        fill: true
                    },
                    {
                        label: 'Upload',
                        data: uploadData,
                        borderColor: '#34A853',
                        backgroundColor: 'rgba(52, 168, 83, 0.1)',
                        borderWidth: 2,
                        tension: 0.3,
                        fill: true
                    }
                ]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { display: false },
                    tooltip: { mode: 'index', intersect: false }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        ticks: {
                            callback: function(value) {
                                return value + ' Mbps';
                            }
                        },
                        grid: {
                            color: 'rgba(0, 0, 0, 0.05)'
                        }
                    },
                    x: {
                        grid: { display: false }
                    }
                },
                interaction: {
                    mode: 'nearest',
                    axis: 'x',
                    intersect: false
                }
            }
        });
    }

    <?php if (!empty($data_vivo)) : ?>
    createChart(
        'speedChartVivo',
        <?= json_encode(array_column($data_vivo, 'timestamp')) ?>,
        <?= json_encode(array_column($data_vivo, 'download')) ?>,
        <?= json_encode(array_column($data_vivo, 'upload')) ?>
    );
    <?php endif; ?>

    <?php if (!empty($data_ligga)) : ?>
    createChart(
        'speedChartLigga',
        <?= json_encode(array_column($data_ligga, 'timestamp')) ?>,
        <?= json_encode(array_column($data_ligga, 'download')) ?>,
        <?= json_encode(array_column($data_ligga, 'upload')) ?>
    );
    <?php endif; ?>
});
</script>

<style>
.speed-chart-widget {
    font-family: 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
    padding: 15px;
    background: white;
    border-radius: 10px;
    box-shadow: 0 2px 10px rgba(0,0,0,0.05);
}

.chart-header {
    margin-bottom: 5px;
}

.chart-title {
    font-weight: 600;
    font-size: 14px;
    color: #333;
    margin-bottom: 5px;
}

.chart-container {
    height: 200px;
    margin-bottom: 10px;
}

.current-speeds {
    display: flex;
    justify-content: space-around;
    gap: 10px;
    margin-bottom: 10px;
}

.current-speed {
    text-align: center;
    padding: 8px;
    border-radius: 8px;
    background: #f8f9fa;
    flex: 1;
}

.current-speed.download { border-bottom: 3px solid #4285F4; }
.current-speed.upload { border-bottom: 3px solid #34A853; }
.current-speed.ping { border-bottom: 3px solid #EA4335; }

.speed-value {
    font-size: 18px;
    font-weight: 600;
    display: block;
}

.speed-unit {
    font-size: 12px;
    color: #888;
}

.speed-label {
    font-size: 11px;
    color: #666;
    text-transform: uppercase;
    margin-top: 3px;
}

.chart-footer {
    font-size: 11px;
    color: #888;
    text-align: right;
    border-top: 1px solid #eee;
    padding-top: 5px;
    margin-bottom: 15px;
}
</style>
