select t.availablebalance
  from tranlegacy t
 where t.accountno = '630000781'
   and t.transactiondate =
       (select max(tr.transactiondate)
          from tranlegacy tr
         where tr.accountno = '630000781'
           and tr.transactiondate < = '20-OCT-2015' ) -- todate
           and rownum = 1
           
