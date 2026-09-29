import { FormEvent, useEffect, useState } from 'react';
import { fetchNui, isBrowser, useNuiEvent } from './nui';
import type { ActionResult, BankState, Transaction } from './types';

type Tab = 'overview' | 'deposit' | 'withdraw' | 'transfer';

const MOCK_STATE: BankState = {
  name: 'John Doe',
  bank: 48250,
  cash: 1320,
  transactions: [
    { type: 'transfer_in', amount: 5000, label: 'Virement de Jane Smith', date: Date.now() / 1000 - 3600 },
    { type: 'withdraw', amount: 800, label: 'Retrait', date: Date.now() / 1000 - 7200 },
    { type: 'deposit', amount: 2500, label: 'Dépôt', date: Date.now() / 1000 - 86400 },
  ],
};

const TABS: { id: Tab; label: string }[] = [
  { id: 'overview', label: 'Aperçu' },
  { id: 'deposit', label: 'Dépôt' },
  { id: 'withdraw', label: 'Retrait' },
  { id: 'transfer', label: 'Virement' },
];

const money = (value: number) =>
  new Intl.NumberFormat('fr-FR', { style: 'currency', currency: 'USD', maximumFractionDigits: 0 }).format(value);

const isIncoming = (t: Transaction) => t.type === 'deposit' || t.type === 'transfer_in';

export default function App() {
  const [visible, setVisible] = useState(isBrowser);
  const [state, setState] = useState<BankState | null>(isBrowser ? MOCK_STATE : null);
  const [tab, setTab] = useState<Tab>('overview');
  const [amount, setAmount] = useState('');
  const [target, setTarget] = useState('');
  const [loading, setLoading] = useState(false);
  const [feedback, setFeedback] = useState<{ ok: boolean; message: string } | null>(null);

  useNuiEvent<BankState>('open', (data) => {
    setState(data);
    setTab('overview');
    setFeedback(null);
    setVisible(true);
  });

  useNuiEvent('close', () => setVisible(false));

  const close = () => {
    setVisible(false);
    fetchNui('close');
  };

  useEffect(() => {
    const onKey = (e: KeyboardEvent) => e.key === 'Escape' && close();
    window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
  }, []);

  const submit = async (e: FormEvent) => {
    e.preventDefault();
    const value = Number(amount);
    if (!Number.isInteger(value) || value <= 0) {
      setFeedback({ ok: false, message: 'Entre un montant entier positif.' });
      return;
    }

    setLoading(true);
    const result = await fetchNui<ActionResult>(
      tab,
      { amount: value, target: Number(target) },
      { ok: true, message: 'Opération simulée (mode navigateur).' },
    );
    setLoading(false);

    setFeedback({ ok: result.ok, message: result.message });
    if (result.state) setState(result.state);
    if (result.ok) {
      setAmount('');
      setTarget('');
    }
  };

  if (!visible || !state) return null;

  return (
    <div className="backdrop">
      <main className="bank">
        <header>
          <div>
            <p className="muted">Bienvenue</p>
            <h1>{state.name}</h1>
          </div>
          <button className="close" onClick={close} aria-label="Fermer">
            ×
          </button>
        </header>

        <section className="balances">
          <div className="card primary">
            <p>Compte courant</p>
            <strong>{money(state.bank)}</strong>
          </div>
          <div className="card">
            <p>Liquide</p>
            <strong>{money(state.cash)}</strong>
          </div>
        </section>

        <nav>
          {TABS.map((t) => (
            <button
              key={t.id}
              className={tab === t.id ? 'active' : ''}
              onClick={() => {
                setTab(t.id);
                setFeedback(null);
              }}
            >
              {t.label}
            </button>
          ))}
        </nav>

        {tab === 'overview' ? (
          <ul className="history">
            {state.transactions.length === 0 && <li className="muted">Aucune transaction.</li>}
            {state.transactions.map((t, i) => (
              <li key={i}>
                <div>
                  <span>{t.label}</span>
                  <small className="muted">{new Date(t.date * 1000).toLocaleString('fr-FR')}</small>
                </div>
                <b className={isIncoming(t) ? 'in' : 'out'}>
                  {isIncoming(t) ? '+' : '-'}
                  {money(t.amount)}
                </b>
              </li>
            ))}
          </ul>
        ) : (
          <form onSubmit={submit}>
            {tab === 'transfer' && (
              <label>
                ID du destinataire
                <input type="number" min={1} value={target} onChange={(e) => setTarget(e.target.value)} required />
              </label>
            )}
            <label>
              Montant
              <input type="number" min={1} value={amount} onChange={(e) => setAmount(e.target.value)} required />
            </label>
            <button type="submit" disabled={loading}>
              {loading ? 'Traitement...' : 'Valider'}
            </button>
          </form>
        )}

        {feedback && <p className={`feedback ${feedback.ok ? 'in' : 'out'}`}>{feedback.message}</p>}
      </main>
    </div>
  );
}
