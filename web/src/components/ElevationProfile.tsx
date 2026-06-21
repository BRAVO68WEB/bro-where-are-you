import { AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';

interface ElevationProfileProps {
  data: Array<{ time: string; altitude: number }>;
}

export function ElevationProfile({ data }: ElevationProfileProps) {
  if (data.length < 2) {
    return (
      <div className="chart-empty">
        <p>Not enough data for elevation profile</p>
      </div>
    );
  }

  return (
    <div className="chart-container">
      <h3 className="chart-title">Elevation</h3>
      <ResponsiveContainer width="100%" height={200}>
        <AreaChart data={data} margin={{ top: 8, right: 16, bottom: 8, left: 0 }}>
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
            tickFormatter={(v: number) => `${v}m`}
            width={50}
            domain={['dataMin - 10', 'dataMax + 10']}
          />
          <Tooltip
            contentStyle={{
              background: '#1a1a1a',
              border: '1px solid #2a2a2a',
              borderRadius: '8px',
              fontSize: '13px',
              color: '#fff',
            }}
            formatter={(value) => [`${Number(value).toFixed(0)} m`, 'Altitude']}
            labelFormatter={(label) => String(label)}
          />
          <defs>
            <linearGradient id="elevationGradient" x1="0" y1="0" x2="0" y2="1">
              <stop offset="0%" stopColor="#faff69" stopOpacity={0.3} />
              <stop offset="100%" stopColor="#faff69" stopOpacity={0.02} />
            </linearGradient>
          </defs>
          <Area
            type="monotone"
            dataKey="altitude"
            stroke="#faff69"
            strokeWidth={2}
            fill="url(#elevationGradient)"
            dot={false}
            activeDot={{ r: 4, fill: '#faff69' }}
          />
        </AreaChart>
      </ResponsiveContainer>
    </div>
  );
}
