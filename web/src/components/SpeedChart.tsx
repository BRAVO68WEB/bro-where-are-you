import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';

interface SpeedChartProps {
  data: Array<{ time: string; speed: number }>;
}

export function SpeedChart({ data }: SpeedChartProps) {
  if (data.length < 2) {
    return (
      <div className="chart-empty">
        <p>Not enough data for speed chart</p>
      </div>
    );
  }

  return (
    <div className="chart-container">
      <h3 className="chart-title">Speed</h3>
      <ResponsiveContainer width="100%" height={200}>
        <LineChart data={data} margin={{ top: 8, right: 16, bottom: 8, left: 0 }}>
          <CartesianGrid strokeDasharray="3 3" stroke="#2a2a2a" />
          <XAxis
            dataKey="time"
            stroke="#5a5a5a"
            fontSize={11}
            tickLine={false}
            interval="preserveStartEnd"
          />
          <YAxis
            stroke="#5a5a5a"
            fontSize={11}
            tickLine={false}
            tickFormatter={(v: number) => `${v}`}
            width={40}
          />
          <Tooltip
            contentStyle={{
              background: '#1a1a1a',
              border: '1px solid #2a2a2a',
              borderRadius: '8px',
              fontSize: '13px',
              color: '#fff',
            }}
            formatter={(value) => [`${(Number(value) * 3.6).toFixed(1)} km/h`, 'Speed']}
            labelFormatter={(label) => String(label)}
          />
          <Line
            type="monotone"
            dataKey="speed"
            stroke="#faff69"
            strokeWidth={2}
            dot={false}
            activeDot={{ r: 4, fill: '#faff69' }}
          />
        </LineChart>
      </ResponsiveContainer>
    </div>
  );
}
