import SmsAndroid from 'react-native-get-sms-android';
import { SMS_SENDERS, EXCLUDE_PATTERNS, TRANSACTION_INDICATORS } from 'utils/sms/constants';
import { parseEquityBankTransaction } from 'utils/sms/equityBankParser';
import { parseMMoneyTransaction } from 'utils/sms/mmoneyParser';
import { ITransactionProps, TransactionEnumType } from 'types/redux-types'
import { SmsMessage } from 'types/sms-types';


export const readAndParseTransactions = (
  onSuccess: (transactions: ITransactionProps[]) => void,
  onError?: (error: any) => void
) => {
  const filter = {
    box: 'inbox',
    maxCount: 10000,
  };

  SmsAndroid.list(
    JSON.stringify(filter),
    (fail: string) => {
      console.error('Failed to read SMS:', fail);
      onError?.(fail);
    },
    (count: number, smsList: string) => {
      const messages = JSON.parse(smsList);
      const transactions = filterAndParseTransactions(messages);
      onSuccess(transactions);
    }
  );
};

function filterAndParseTransactions(messages: SmsMessage[]): ITransactionProps[] {
  const transactionMessages = messages.filter(isTransactionMessage);
  const parsedTransactions = transactionMessages.map(parseTransaction);
  return parsedTransactions.filter(t => t.balance && t.type);
}

function isTransactionMessage(sms: SmsMessage): boolean {
  const body = sms.body;
  const address = sms.address.toUpperCase();
  
  const isFromBank = address === SMS_SENDERS.EQUITY_BANK || 
                     address === SMS_SENDERS.M_MONEY;
  if (!isFromBank) return false;
  
  const isExcluded = EXCLUDE_PATTERNS.some(pattern => body.includes(pattern));
  if (isExcluded) return false;
  
  return TRANSACTION_INDICATORS.some(indicator => body.includes(indicator));
}

function parseTransaction(sms: SmsMessage, index: number): ITransactionProps {
  const body = sms.body;
  const sender = sms.address.toUpperCase();
  const date = new Date(parseInt(sms.date));
  
  // Create a base transaction in ITransactionProps format
  let transaction: ITransactionProps = {
    id: `sms_${sms._id || index}`,
    walletId: sender === SMS_SENDERS.EQUITY_BANK ? 'equity_bank' : 'mtn_momo',
    categoryId: 'other',
    balance: 0, // Default, will be overridden by parser
    date: date.toISOString(),
    type: TransactionEnumType.EXPENSES, // Default, will be overridden by parser
    category: {
      id: 'other',
      parentId: 'other',
      name: 'Other',
      icon: 'ic020',
    },
    note: {
      textNote: body, // Store original SMS message
    },
    // Store SMS metadata in note for now
    fee: 0,
    reference: `sms_${sms._id || index}`,
    isAutoImported: true,
  };
  
  // Parse specific bank formats (these functions need to be updated too)
  if (sender === SMS_SENDERS.EQUITY_BANK) {
    return parseEquityBankTransaction(body, transaction);
  } else if (sender === SMS_SENDERS.M_MONEY) {
    return parseMMoneyTransaction(body, transaction);
  }
  
  return transaction;
}