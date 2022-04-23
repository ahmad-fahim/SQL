
begin
  for idx in (select al.acntlien_acnum,
                     al.acntlien_lien_date,
                     al.acntlien_lien_to_brn,
                     al.acntlien_lien_to_acnum,
                     al.acntlien_lien_amount,
                     p.migdep_dep_ac_num
                from mig_acntlien al, mig_pbdcontract p
               where p.migdep_dep_ac_num = al.acntlien_acnum) loop
    update mig_pbdcontract
       set mig_pbdcontract.migdep_lien_date     = idx.acntlien_lien_date,
           mig_pbdcontract.migdep_lien_to_brn   = idx.acntlien_lien_to_brn,
           mig_pbdcontract.migdep_lien_to_acnum = idx.acntlien_lien_to_acnum,
           mig_pbdcontract.migdep_ac_lien_amt   = idx.acntlien_lien_amount
    
     where mig_pbdcontract.migdep_dep_ac_num = idx.acntlien_acnum;
  end loop;
end;
