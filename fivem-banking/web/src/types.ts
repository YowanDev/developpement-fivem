export type TransactionType = 'deposit' | 'withdraw' | 'transfer_in' | 'transfer_out';

export interface Transaction {
  type: TransactionType;
  amount: number;
  label: string;
  date: number;
}

export interface BankState {
  name: string;
  bank: number;
  cash: number;
  transactions: Transaction[];
}

export interface ActionResult {
  ok: boolean;
  message: string;
  state?: BankState;
}
