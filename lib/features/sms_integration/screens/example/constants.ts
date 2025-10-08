export const USD_TO_RWF = 1440;

export const SMS_SENDERS = {
  EQUITY_BANK: 'EQUITYBANK',
  M_MONEY: 'M-MONEY',
};

export const EXCLUDE_PATTERNS = [
  'Never share this code',
  'One-Time-Pin',
  'OTM',
  'Use code',
  'Do no share',
  'Customer Care',
  'balance of accumulated interest',
];

export const TRANSACTION_INDICATORS = [
  'RWF', 'USD',
  'transferred', 'received', 'sent', 'withdrawn', 'deposited',
  'payment', 'completed', 'successfully',
  'balance:', 'new balance', 'Fee',
  'TxId:', 'Ref.', 'Transaction Id'
];