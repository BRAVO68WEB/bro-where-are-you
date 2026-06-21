import { useEffect, useState } from 'react';
import { useAuth } from 'react-oidc-context';
import { subscribe } from '../graphql/client';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, AreaChart, Area } from 'recharts';

interface JourneyRow {
  started_at: string;
  ended_at: string | null;
  total_distance_m: number;
  transport_mode: string | null;
}

interface DayData {
  date: string;
  journeys: number;
  distance: number;
  duration: number;
}

function groupByDay(journeys: JourneyRow[]): DayData[] {
  const map = new Map<string, DayData>();

  for (const j of journeys) {
    if (!j.ended_at) continue;
    const day = new Date(j.started_at).toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
    const duration = (new Date(j.ended_at).getTime() - new Date(j.started_at).getTime()) / 1000;

    const existing = map.get(day);
    if (existing) {
      existing.journeys++;
      existing.distance += j.total_distance_m;
      existing.duration += duration;
    } else {
      map.set(day, { date: day, journeys: 1, distance: j.total_distance_m, duration });
    }
  }

  return Array.from(map.values()).reverse().slice(-14);
}

function groupByWeek(journeys: JourneyRow[]): DayData[] {
  const map = new Map<string, DayData>();

  for (const j of journeys) {
    if (!j.ended_at) continue;
    const d = new Date(j.started_at);
    const weekStart = new Date(d);
    weekStart.setDate(d.getDate() - d.getDay());
    const key = weekStart.toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
    const duration = (new Date(j.ended_at).getTime() - d.getTime()) / 1000;

    const existing = map.get(key);
    if (existing) {
      existing.journeys++;
      existing.distance += j.total_distance_m;
      existing.duration += duration;
    } else {
      map.set(key, { date: key, journeys: 1, distance: j.total_distance_m, duration });
    }
  }

  return Array.from(map.values()).reverse().slice(-12);
}

function groupByMonth(journeys: JourneyRow[]): DayData[] {
  const map = new Map<string, DayData>();

  for (const j of journeys) {
    if (!j.ended_at) continue;
    const key = new Date(j.started_at).toLocaleDateString('en-US', { month: 'short', year: 'numeric' });
    const duration = (new Date(j.ended_at).getTime() - new Date(j.started_at).getTime()) / 1000;

    const existing = map.get(key);
    if (existing) {
      existing.journeys++;
      existing.distance += j.total_distance_m;
      existing.duration += duration;
    } else {
      map.set(key, { date: key, journeys: 1, distance: j.total_distance_m, duration });
    }
  }

  return Array.from(map.values()).reverse();
}

export function StatsPage() {
  const auth = useAuth();
  const [allJourneys, setAllJourneys] = useState<JourneyRow[]>([]);
  const [period, setPeriod] = useState<'day' | 'week' | 'month'>('day');

  useEffect(() => {
    if (!auth.isAuthenticated) return;

    const unsub = subscribe<{ journeys: JourneyRow[] }>(
      `subscription { journeys(order_by: {started_at: desc}) { started_at ended_at total_distance_m transport_mode } }`,
      {},
      (data) => setAllJourneys(data.journeys),
    );
    return unsub;
  }, [auth.isAuthenticated]);

  const completed = allJourneys.filter((j) => j.ended_at);
  const totalDistance = completed.reduce((s, j) => s + j.total_distance_m, 0);
  const totalDuration = completed.reduce((s, j) => {
    return s + (new Date(j.ended_at!).getTime() - new Date(j.started_at).getTime()) / 1000;
  }, 0);
  const avgSpeed = totalDuration > 0 ? (totalDistance / totalDuration) : 0;
  const activeCount = allJourneys.filter((j) => !j.ended_at).length;

  const chartData = period === 'day'
    ? groupByDay(allJourneys)
    : period === 'week'
    ? groupByWeek(allJourneys)
    : groupByMonth(allJourneys);

  const formatDist = (m: number) => m >= 1000 ? `${(m / 1000).toFixed(1)} km` : `${Math.round(m)} m`;
  const formatDur = (s: number) => {
    const h = Math.floor(s / 3600);
    const m = Math.floor((s % 3600) / 60);
    if (h > 0) return `${h}h ${m}m`;
    return `${m}m`;
  };

  return (
    <div className="page-content">
      <div className="page-header">
        <h1>Stats</h1>
      </div>

      {/* Summary cards */}
      <div className="stats-summary">
        <div className="stats-card">
          <span className="stats-value">{completed.length}</span>
          <span className="stats-label">Journeys</span>
        </div>
        <div className="stats-card">
          <span className="stats-value">{formatDist(totalDistance)}</span>
          <span className="stats-label">Total Distance</span>
        </div>
        <div className="stats-card">
          <span className="stats-value">{formatDur(totalDuration)}</span>
          <span className="stats-label">Total Time</span>
        </div>
        <div className="stats-card">
          <span className="stats-value">{(avgSpeed * 3.6).toFixed(1)} km/h</span>
          <span className="stats-label">Avg Speed</span>
        </div>
        <div className="stats-card">
          <span className="stats-value">{activeCount}</span>
          <span className="stats-label">Active Now</span>
        </div>
      </div>

      {/* Period selector */}
      <div className="period-tabs">
        {(['day', 'week', 'month'] as const).map((p) => (
          <button
            key={p}
            className={`tab-btn ${period === p ? 'active' : ''}`}
            onClick={() => setPeriod(p)}
          >
            {p.charAt(0).toUpperCase() + p.slice(1)}
          </button>
        ))}
      </div>

      {/* Distance chart */}
      <div className="chart-container" style={{ marginBottom: 16 }}>
        <h3 className="chart-title">Distance by {period}</h3>
        <ResponsiveContainer width="100%" height={220}>
          <BarChart data={chartData} margin={{ top: 8, right: 16, bottom: 8, left: 0 }}>
            <CartesianGrid strokeDasharray="3 3" stroke="#2a2a2a" />
            <XAxis dataKey="date" stroke="#5a5a5a" fontSize={11} tickLine={false} />
            <YAxis
              stroke="#5a5a5a"
              fontSize={11}
              tickLine={false}
              width={50}
              tickFormatter={(v: number) => v >= 1000 ? `${(v / 1000).toFixed(0)}k` : `${v}`}
            />
            <Tooltip
              contentStyle={{ background: '#1a1a1a', border: '1px solid #2a2a2a', borderRadius: '8px', fontSize: '13px', color: '#fff' }}
              formatter={(value) => [formatDist(Number(value)), 'Distance']}
            />
            <Bar dataKey="distance" fill="#faff69" radius={[4, 4, 0, 0]} />
          </BarChart>
        </ResponsiveContainer>
      </div>

      {/* Journey count chart */}
      <div className="chart-container" style={{ marginBottom: 16 }}>
        <h3 className="chart-title">Journeys by {period}</h3>
        <ResponsiveContainer width="100%" height={180}>
          <AreaChart data={chartData} margin={{ top: 8, right: 16, bottom: 8, left: 0 }}>
            <CartesianGrid strokeDasharray="3 3" stroke="#2a2a2a" />
            <XAxis dataKey="date" stroke="#5a5a5a" fontSize={11} tickLine={false} />
            <YAxis stroke="#5a5a5a" fontSize={11} tickLine={false} width={30} allowDecimals={false} />
            <Tooltip
              contentStyle={{ background: '#1a1a1a', border: '1px solid #2a2a2a', borderRadius: '8px', fontSize: '13px', color: '#fff' }}
              formatter={(value) => [Number(value), 'Journeys']}
            />
            <defs>
              <linearGradient id="journeyGrad" x1="0" y1="0" x2="0" y2="1">
                <stop offset="0%" stopColor="#faff69" stopOpacity={0.3} />
                <stop offset="100%" stopColor="#faff69" stopOpacity={0.02} />
              </linearGradient>
            </defs>
            <Area type="monotone" dataKey="journeys" stroke="#faff69" strokeWidth={2} fill="url(#journeyGrad)" />
          </AreaChart>
        </ResponsiveContainer>
      </div>

      {/* Duration chart */}
      <div className="chart-container">
        <h3 className="chart-title">Time by {period}</h3>
        <ResponsiveContainer width="100%" height={180}>
          <BarChart data={chartData} margin={{ top: 8, right: 16, bottom: 8, left: 0 }}>
            <CartesianGrid strokeDasharray="3 3" stroke="#2a2a2a" />
            <XAxis dataKey="date" stroke="#5a5a5a" fontSize={11} tickLine={false} />
            <YAxis
              stroke="#5a5a5a"
              fontSize={11}
              tickLine={false}
              width={50}
              tickFormatter={(v: number) => `${Math.round(v / 60)}m`}
            />
            <Tooltip
              contentStyle={{ background: '#1a1a1a', border: '1px solid #2a2a2a', borderRadius: '8px', fontSize: '13px', color: '#fff' }}
              formatter={(value) => [formatDur(Number(value)), 'Duration']}
            />
            <Bar dataKey="duration" fill="#22c55e" radius={[4, 4, 0, 0]} />
          </BarChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
}
