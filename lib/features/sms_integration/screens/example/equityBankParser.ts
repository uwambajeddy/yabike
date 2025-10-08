import { USD_TO_RWF } from './constants';
import { ITransactionProps, TransactionEnumType, ICategoryProps } from 'types/redux-types';

// Parse EquityBank SMS format
export function parseEquityBankTransaction(body: string, transaction: ITransactionProps, usdToRwf = USD_TO_RWF): ITransactionProps {
  
  // Pattern: "XXX.XX RWF was successfully sent to NAME PHONE..." or "has been successfully sent to"
  const sentMatch = body.match(/(\d+(?:\.\d+)?)\s+(RWF|USD)\s+(?:was|has been) successfully sent to\s+([^0-9]+?)(?:\s+(\d+)|(?:\s+4\*+\d+))/);
  
  // Pattern: "You have received XXX.XX RWF from..."
  const receivedMatch = body.match(/You have received\s+(\d+(?:\.\d+)?)\s+(RWF|USD)\s+from\s+([^0-9]+)/);
  
  // Pattern: "you have withdrawn USD XXX withdraw charges XXX ref..."
  const withdrawnMatch = body.match(/withdrawn\s+(USD|RWF)\s+(\d+)/);
  
  // Pattern: "you have deposited USD XXX"
  const depositedMatch = body.match(/deposited\s+(USD|RWF)\s+(\d+)/);
  
  // Pattern: "Auth for card...Amt: USD X.XX Details:..."
  const cardAuthMatch = body.match(/Amt:\s+(USD|RWF)\s+(\d+(?:\.\d+)?)\s+Details:([^.]+)/);
  
  // Pattern: "Debit for card...Amt: USD X.XX"
  const cardDebitMatch = body.match(/Debit for card.*Amt:\s+(USD|RWF)\s+(\d+(?:\.\d+)?)/);
  
  if (sentMatch) {
    const [, amount, currency, recipient, phone] = sentMatch;
    const amountRWF = currency === 'USD' ? parseFloat(amount) * usdToRwf : parseFloat(amount);
    
    // Extract charges if present
    const chargesMatch = body.match(/Charges\s+(\d+(?:\.\d+)?)\s+(USD|RWF)/);
    const charges = chargesMatch ? parseFloat(chargesMatch[1]) : 0;
    const chargesRWF = chargesMatch && chargesMatch[2] === 'USD' ? charges * usdToRwf : charges;
    
    return {
      ...transaction,
      type: TransactionEnumType.EXPENSES,
      category: {
        id: 'transfer',
        parentId: 'expenses',
        name: 'Transfer',
        icon: 'ic023',
      },
      categoryId: 'transfer',
      balance: amountRWF,
      fee: chargesRWF,
      note: {
        ...transaction.note,
        textNote: `${transaction.note?.textNote || ''}\nTransfer to ${recipient.trim()} (${phone || 'N/A'})`,
      },
    };
  }
  else if (receivedMatch) {
    const [, amount, currency, sender] = receivedMatch;
    const amountRWF = currency === 'USD' ? parseFloat(amount) * usdToRwf : parseFloat(amount);
    
    return {
      ...transaction,
      type: TransactionEnumType.INCOME,
      category: {
        id: 'received',
        parentId: 'income',
        name: 'Received Money',
        icon: 'ic024',
      },
      categoryId: 'received',
      balance: amountRWF,
      note: {
        ...transaction.note,
        textNote: `${transaction.note?.textNote || ''}\nReceived from ${sender.trim()}`,
      },
    };
  }
  else if (withdrawnMatch) {
    const [, currency, amount] = withdrawnMatch;
    const amountRWF = currency === 'USD' ? parseFloat(amount) * usdToRwf : parseFloat(amount);
    
    const chargesMatch = body.match(/charges\s+(\d+(?:\.\d+)?)/);
    const charges = chargesMatch ? parseFloat(chargesMatch[1]) : 0;
    
    return {
      ...transaction,
      type: TransactionEnumType.EXPENSES,
      category: {
        id: 'withdrawal',
        parentId: 'expenses',
        name: 'ATM Withdrawal',
        icon: 'ic014',
      },
      categoryId: 'withdrawal',
      balance: amountRWF,
      fee: charges,
      note: {
        ...transaction.note,
        textNote: `${transaction.note?.textNote || ''}\nATM Withdrawal`,
      },
    };
  }
  else if (depositedMatch) {
    const [, currency, amount] = depositedMatch;
    const amountRWF = currency === 'USD' ? parseFloat(amount) * usdToRwf : parseFloat(amount);
    
    return {
      ...transaction,
      type: TransactionEnumType.INCOME,
      category: {
        id: 'deposit',
        parentId: 'income',
        name: 'Cash Deposit',
        icon: 'ic025',
      },
      categoryId: 'deposit',
      balance: amountRWF,
      note: {
        ...transaction.note,
        textNote: `${transaction.note?.textNote || ''}\nCash Deposit`,
      },
    };
  }
  else if (cardAuthMatch || cardDebitMatch) {
    const match = cardAuthMatch || cardDebitMatch;
    if (!match) return transaction;
    const [, currency, amount, details] = match;
    const amountRWF = currency === 'USD' ? parseFloat(amount) * usdToRwf : parseFloat(amount);
    
    return {
      ...transaction,
      type: TransactionEnumType.EXPENSES,
      category: {
        id: 'card_payment',
        parentId: 'expenses',
        name: 'Card Payment',
        icon: 'ic015',
      },
      categoryId: 'card_payment',
      balance: amountRWF,
      note: {
        ...transaction.note,
        textNote: `${transaction.note?.textNote || ''}\n${details ? details.trim() : 'Card Payment'}`,
      },
    };
  }
  
  // Extract balance if present and update
  const balanceMatch = body.match(/balance[:\s]+(\d+)/i);
  if (balanceMatch) {
    transaction.balance = parseFloat(balanceMatch[1]);
  }
  
  // Extract reference
  const refMatch = body.match(/[Rr]ef[.:\s]+(\d+)/);
  if (refMatch) {
    transaction.reference = refMatch[1];
  }
  
  return transaction;
}