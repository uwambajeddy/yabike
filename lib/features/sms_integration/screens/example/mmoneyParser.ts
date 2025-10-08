import { ITransactionProps, TransactionEnumType, ICategoryProps } from 'types/redux-types';

export function parseMMoneyTransaction(body: string, transaction: ITransactionProps): ITransactionProps {
  // Pattern: "*165*s*XXXX RWF transferred to NAME (PHONE)..."
  const sentMatch = body.match(/(\d+)\s+RWF transferred to\s+([^(]+)\((\d+)\)/);
  
  // Pattern: "You have received XXXX RWF from NAME (PHONE*...)..."
  const receivedMatch = body.match(/You have received\s+(\d+)\s+RWF from\s+([^(]+)\(\*+(\d+)\)/);
  
  // Pattern: "*162*TxId:XXXXX*s*Your payment of X,XXX RWF to..."
  const paymentMatch = body.match(/Your payment of\s+([\d,]+)\s+RWF to\s+([^0-9]+)/);
  
  // Pattern: "TxId: XXXXX. Your payment of X,XXX RWF to..."
  const paymentMatch2 = body.match(/TxId:\s+\d+\.\s+Your payment of\s+([\d,]+)\s+RWF to\s+([^0-9]+)/);
  
  // Pattern: "*164*s*...transaction of XXXX RWF by MERCHANT..."
  const merchantMatch = body.match(/transaction of\s+([\d,]+)\s+RWF by\s+([^o]+)on your MOMO/);
  
  // Pattern for agent withdrawals
  const agentWithdrawMatch = body.match(/withdrawn\s+(\d+)\s+RWF from your mobile money/);
  
  if (sentMatch) {
    const [, amount, recipient, phone] = sentMatch;
    const amountNum = parseFloat(amount.replace(/,/g, ''));
    
    const feeMatch = body.match(/Fee was:\s+(\d+)/);
    const fee = feeMatch ? parseFloat(feeMatch[1]) : 0;
    
    const balanceMatch = body.match(/[Nn]ew balance:\s*([\d,]+)\s+RWF/);
    const balance = balanceMatch ? parseFloat(balanceMatch[1].replace(/,/g, '')) : undefined;
    
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
      balance: balance || amountNum,
      fee: fee,
      note: {
        ...transaction.note,
        textNote: `${transaction.note?.textNote || ''}\nTransfer to ${recipient.trim()} (${phone})`,
      },
    };
  }
  else if (receivedMatch) {
    const [, amount, sender, phone] = receivedMatch;
    const amountNum = parseFloat(amount.replace(/,/g, ''));
    
    const balanceMatch = body.match(/[Nn]ew balance:\s*([\d,]+)\s+RWF/);
    const balance = balanceMatch ? parseFloat(balanceMatch[1].replace(/,/g, '')) : undefined;
    
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
      balance: balance || amountNum,
      note: {
        ...transaction.note,
        textNote: `${transaction.note?.textNote || ''}\nReceived from ${sender.trim()} (${phone})`,
      },
    };
  }
  else if (paymentMatch || paymentMatch2) {
    const match = paymentMatch || paymentMatch2;
    if (!match) return transaction;
    const [, amount, merchant] = match;
    const amountNum = parseFloat(amount.replace(/,/g, ''));
    
    const feeMatch = body.match(/Fee was\s+(\d+)/);
    const fee = feeMatch ? parseFloat(feeMatch[1]) : 0;
    
    const balanceMatch = body.match(/[Nn]ew balance:\s*([\d,]+)\s+RWF/);
    const balance = balanceMatch ? parseFloat(balanceMatch[1].replace(/,/g, '')) : undefined;
    
    // Detect payment type
    let category: ICategoryProps = {
      id: 'payment',
      parentId: 'expenses',
      name: 'Payment',
      icon: 'ic001',
    };
    
    if (body.includes('Cash Power') || body.includes('MTN cash Power')) {
      category = {
        id: 'electricity',
        parentId: 'expenses',
        name: 'Electricity',
        icon: 'ic008',
      };
    } else if (body.includes('Airtime')) {
      category = {
        id: 'airtime',
        parentId: 'expenses',
        name: 'Airtime',
        icon: 'ic019',
      };
    }
    
    return {
      ...transaction,
      type: TransactionEnumType.EXPENSES,
      category: category,
      categoryId: category.id,
      balance: balance || amountNum,
      fee: fee,
      note: {
        ...transaction.note,
        textNote: `${transaction.note?.textNote || ''}\nPayment to ${merchant.trim()}`,
      },
    };
  }
  else if (merchantMatch) {
    const [, amount, merchant] = merchantMatch;
    const amountNum = parseFloat(amount.replace(/,/g, ''));
    
    const balanceMatch = body.match(/[Nn]ew balance:\s*([\d,]+)\s+RWF/);
    const balance = balanceMatch ? parseFloat(balanceMatch[1].replace(/,/g, '')) : undefined;
    
    return {
      ...transaction,
      type: TransactionEnumType.EXPENSES,
      category: {
        id: 'merchant_payment',
        parentId: 'expenses',
        name: 'others',
        icon: 'ic002',
      },
      categoryId: 'merchant_payment',
      balance: balance || amountNum,
      note: {
        ...transaction.note,
        textNote: `${transaction.note?.textNote || ''}\nPayment to ${merchant.trim()}`,
      },
    };
  }
  else if (agentWithdrawMatch) {
    const [, amount] = agentWithdrawMatch;
    const amountNum = parseFloat(amount.replace(/,/g, ''));
    
    const feeMatch = body.match(/Fee paid:\s+(\d+)/);
    const fee = feeMatch ? parseFloat(feeMatch[1]) : 0;
    
    const balanceMatch = body.match(/[Nn]ew balance:\s*([\d,]+)\s+RWF/);
    const balance = balanceMatch ? parseFloat(balanceMatch[1].replace(/,/g, '')) : undefined;
    
    return {
      ...transaction,
      type: TransactionEnumType.EXPENSES,
      category: {
        id: 'agent_withdrawal',
        parentId: 'expenses',
        name: 'Cash Withdrawal',
        icon: 'ic014',
      },
      categoryId: 'agent_withdrawal',
      balance: balance || amountNum,
      fee: fee,
      note: {
        ...transaction.note,
        textNote: `${transaction.note?.textNote || ''}\nCash withdrawal`,
      },
    };
  }
  
  // Extract transaction ID and store in reference
  const txIdMatch = body.match(/TxId:\s*(\d+)|Transaction Id:\s*(\d+)/);
  if (txIdMatch) {
    transaction.reference = txIdMatch[1] || txIdMatch[2];
  }
  
  return transaction;
}