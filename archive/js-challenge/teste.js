/* ===============================================================
   DATASET
   =============================================================== */

const rawData = [
  {
    system: "A",
    transactions: [
      { id: "t1", value: 200, kind: "credit", tags: ["sales", "online"] },
      { id: "t2", value: 50,  kind: "debit",  tags: ["ops"] }
    ]
  },
  {
    system: "B",
    entries: [
      { uuid: "x9", amount: 1000, type: "credit", categories: ["investment"] },
      { uuid: "x10", amount: 20,   type: "debit", categories: ["marketing"] }
    ]
  },
  {
    system: "C",
    error: "timeout"
  }
];


/* ===============================================================
   TASK 1 — normalizeData(rawData)
   =============================================================== */
/**
 * Requirements:
 *  - Return a FLAT ARRAY of:
 *    { id, amount, type, categories, sourceSystem }
 *  - Use map()/flatMap()
 *  - Ignore invalid items
 *  - DO NOT mutate rawData
 *  - Follow the same structure as the example function
 */
function normalizeData(data) {
  const normalizedSystemA = data.flatMap(system =>  {  
    if(system.system == "A"){
      return system.transactions.map(transaction => {
        return { 
          id: transaction.id,
          amount: transaction.value,
          type: transaction.kind,
          categories: transaction.tags,
          sourceSystem: system.system,
        }
      })
    } else if(system.system == "B"){
      return system.entries.map(entrie => {
        return { 
          id: entrie.uuid,
          amount: entrie.amount,
          type: entrie.type,
          categories: entrie.categories,
          sourceSystem: system.system,
        }
      })
    } else {
      return [];
    }
  });

  return normalizedSystemA;
}



/* ===============================================================
   TASK 2 — filterTransactions(transactions, filters, callback)
   =============================================================== */
/**
 * Requirements:
 *  - Use filter()
 *  - Apply only filters that exist
 *  - Supported filters:
 *      filters.type
 *      filters.minAmount
 *      filters.categoriesInclude (array)
 *  - Callback must receive the filtered array
 *  - No mutation
 */
function filterTransactions(transactions, filters, callback) {
  const filteredTransactions = transactions.filter(transaction => {
    if (filters.type && transaction.type !== filters.type) {
      return false;
    }

    if (
      filters.minAmount !== undefined &&
      transaction.amount < filters.minAmount
    ) {
      return false;
    }

    if (
      filters.categoriesInclude?.length &&
      !filters.categoriesInclude.some(category =>
        transaction.categories.includes(category)
      )
    ) {
      return false;
    }

    return true;
  });

  callback(filteredTransactions);

  return filteredTransactions;
}



/* ===============================================================
   TASK 3 — summarize(transactions)
   =============================================================== */
/**
 * Requirements:
 *  - Use reduce()
 *  - Return:
 *    {
 *      totalCredit,
 *      totalDebit,
 *      balance,
 *      categories: { [category]: totalAmount }
 *    }
 */
function summarize(transactions) {
  return transactions.reduce(
    (acc, transaction) => {
      if (transaction.type === "credit") {
        acc.totalCredit += transaction.amount;
        acc.balance += transaction.amount;
      }

      if (transaction.type === "debit") {
        acc.totalDebit += transaction.amount;
        acc.balance -= transaction.amount;
      }

      transaction.categories.forEach(category => {
        acc.categories[category] =
          (acc.categories[category] || 0) + transaction.amount;
      });

      return acc;
    },
    {
      totalCredit: 0,
      totalDebit: 0,
      balance: 0,
      categories: {},
    }
  );
}



/* ===============================================================
   TASK 4 — loadExternalRates()
   =============================================================== */
/**
 * Requirements:
 *  - Return Promise resolved after 200ms
 *  - Must return:
 *    { creditMultiplier, debitMultiplier }
 *   - Credit Multiplier must be 1.1 
 *   - Debit Multiplier must be 0.9
 */
async function loadExternalRates() {
  return new Promise(resolve => {
    setTimeout(() => {
      resolve({
        creditMultiplier: 1.1,
        debitMultiplier: 0.9,
      });
    }, 200);
  });
}



/* ===============================================================
   TASK 5 — applyRates(transactions, rates)
   =============================================================== */
/**
 * Requirements:
 *  - Use map()
 *  - No mutation
 *  - updatedAmount =
 *        type === "credit"
 *          ? amount * rates.creditMultiplier
 *          : amount * rates.debitMultiplier
 */
function applyRates(transactions, rates) {
  return transactions.map(transaction => ({
    ...transaction,
    amount:
      transaction.type === "credit"
        ? transaction.amount * rates.creditMultiplier
        : transaction.amount * rates.debitMultiplier,
  }));
}



/* ===============================================================
   TASK 6 — processAll(rawData)
   =============================================================== */
/**
 * Full pipeline:
 *   1. normalizeData
 *   2. loadExternalRates()
 *   3. applyRates
 *   4. summarize
 *
 * Requirements:
 *  - Must use async/await
 */
async function processAll(raw) {
  const normalizedTransactions = normalizeData(raw);

  const rates = await loadExternalRates();

  const transactionsWithRates = applyRates(
    normalizedTransactions,
    rates
  );

  const summary = summarize(transactionsWithRates);

  return summary;
}



/* ===============================================================
   INTERNAL TEST HARNESS (Candidate must NOT edit)
   =============================================================== */

(async function runTests() {
  const normalized = normalizeData(rawData);
  document.querySelector("#transactions-loaded").textContent =
    JSON.stringify(normalized, null, 2);

  const filtered = filterTransactions(
    normalized,
    { type: "credit", minAmount: 100, categoriesInclude: ["sales"] },
    (res) => res
  );
  document.querySelector("#filtered-credit").textContent =
    JSON.stringify(filtered, null, 2);

  const rates = await loadExternalRates();
  const rated = applyRates(normalized, rates);

  // FIX 1 — show rated data (not just rates)
  document.querySelector("#data-after-rates").textContent =
    JSON.stringify(rated, null, 2);

  // FIX 2 — show summary BEFORE rates using the original summarize(normalized)
  const summary = summarize(normalized);
  document.querySelector("#summary").textContent =
    JSON.stringify(summary, null, 2);

  // FIX 3 — category totals come from summarize(normalized)
  document.querySelector("#total-by-category").textContent =
    JSON.stringify(summary.categories, null, 2);

  // FIX 4 — final summary follows full processing pipeline
  const final = await processAll(rawData);
  document.querySelector("#final-summary").textContent =
    JSON.stringify(final, null, 2);
})();
