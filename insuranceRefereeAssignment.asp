%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate Search space %
%%%%%%%%%%%%%%%%%%%%%%%%%

1 {assign(Cid, Rid) : referee(Rid, Rtype, Max_Workload, Prev_Workload, Prev_Payment)} 1 :- case(Cid, Ctype, Effort, Damage, Postc, Payment).

%%%%%%%%%%%%%%%%%%%%
% Hard Constraints %
%%%%%%%%%%%%%%%%%%%%

% The maximum number of working minutes of a referee must not be exceeded by the actual workload.
:- Total_Work = #sum{Effort, Rid, Cid : assign(Cid, Rid), case(Cid, Ctype, Effort, Damage, Postc, Payment)}, referee(Rid, Rtype, Max_Workload, Prev_Workload, Prev_Payment), Total_Work > Max_Workload.

% A case must not be assigned to a referee who is not in charge of the region at all.
:- assign(Cid, Rid), referee(Rid, Rtype, Max_Workload, Prev_Workload, Prev_Payment), case(Cid, Ctype, Effort, Damage, Postc, Payment), prefRegion(Rid, Postc, 0).

% A case must not be assigned to a referee who is not in charge of the type of the case at all.
:- assign(Cid, Rid), referee(Rid, Rtype, Max_Workload, Prev_Workload, Prev_Payment), case(Cid, Ctype, Effort, Damage, Postc, Payment), prefType(Rid, Ctype, 0).

% Cases with an amount of damage that exceeds a certain threshold can only be assigned to internal referees.
:- assign(Cid, Rid), referee(Rid, Rtype, Max_Workload, Prev_Workload, Prev_Payment), case(Cid, Ctype, Effort, Damage, Postc, Payment), Rtype==e, externalMaxDamage(Max_Damage), Damage > Max_Damage.

%%%%%%%%%%%%%%%%%%%%
% Weak Constraints %
%%%%%%%%%%%%%%%%%%%%

% Internal referees are preferred in order to minimize the costs of external ones.
internalCount(N) :- N = #count{1, Rid : assign(Cid, Rid), referee(Rid, Rtype, Max_Workload, Prev_Workload, Prev_Payment), Rtype == i}.
#maximize{N : internalCount(N)}.

% The assignment of cases to external referees should be fair in the sense that their overall payment should be balanced.
% 1.Calculate the difference between maximum external pay and minimum external pay.
payment(Rid, Total_Pay) :- Total_Pay = #sum{Payment, Rid, Cid : assign(Cid, Rid), case(Cid, Ctype, Effort, Damage, Postc, Payment)}, referee(Rid, Rtype, Max_Workload, Prev_Workload, Prev_Payment), Rtype == e.
total_payment(Rid, Total_Payment) :- Total_Payment = Prev_Payment + Total_Pay, referee(Rid, Rtype, Max_Workload, Prev_Workload, Prev_Payment), payment(Rid, Total_Pay), Rtype == e.
minimum_payment(Rid1_Payment) :- total_payment(Rid1, Rid1_Payment), 0 == #count{1, Rid2 : Rid1_Payment > Rid2_Payment, total_payment(Rid2, Rid2_Payment)}, total_payment(Rid1, Rid1_Payment).
maximum_payment(Rid1_Payment) :- total_payment(Rid1, Rid1_Payment), 0 == #count{1, Rid2 : Rid1_Payment < Rid2_Payment, total_payment(Rid2, Rid2_Payment)}, total_payment(Rid1, Rid1_Payment).
payment_diff(Diff_Payment) :- Diff_Payment = (Max_Payment - Min_Payment), maximum_payment(Max_Payment), minimum_payment(Min_Payment).

% 2.Minimize difference.
#minimize{Diff_Payment, Cid, Rid : payment_diff(Diff_Payment), assign(Cid, Rid), referee(Rid, Rtype, Max_Workload, Prev_Workload, Prev_Payment), case(Cid, Ctype, Effort, Damage, Postc, Payment)}.


% The assignment of cases to (internal and external) referees should be fair in the sense that their overall workload should be balanced.
% 1.Calculate the difference between maximum workload and minimum workload.
work(Rid, Total_Effort) :- Total_Effort = #sum{Effort, Rid, Cid : assign(Cid, Rid), case(Cid, Ctype, Effort, Damage, Postc, Payment)}, referee(Rid, Rtype, Max_Workload, Prev_Workload, Prev_Payment).
total_workload(Rid, Total_Workload) :- Total_Workload = Prev_Workload + Total_Effort, referee(Rid, Rtype, Max_Workload, Prev_Workload, Prev_Payment), work(Rid, Total_Effort).
minimum_workload(Rid1_Workload) :- total_workload(Rid1, Rid1_Workload), 0 == #count{1, Rid2 : Rid1_Workload > Rid2_Workload, total_workload(Rid2, Rid2_Workload)}, total_workload(Rid1, Rid1_Workload).
maximum_workload(Rid1_Workload) :- total_workload(Rid1, Rid1_Workload), 0 == #count{1, Rid2 : Rid1_Workload < Rid2_Workload, total_workload(Rid2, Rid2_Workload)}, total_workload(Rid1, Rid1_Workload).
effort_diff(Diff_Workload) :- Diff_Workload = (Max_Workload - Min_Workload), maximum_workload(Max_Workload), minimum_workload(Min_Workload).

% 2.Minimize difference.
#minimize{Diff_Workload, Cid, Rid : effort_diff(Diff_Workload), assign(Cid, Rid), referee(Rid, Rtype, Max_Workload, Prev_Workload, Prev_Payment), case(Cid, Ctype, Effort, Damage, Postc, Payment)}.


% Referees should handle types of cases and regions with higher preference.
#maximize{Case_Pref + Region_Pref, Rid : assign(Cid, Rid), referee(Rid, Rtype, Max_Workload, Prev_Workload, Prev_Payment), case(Cid, Ctype, Effort, Damage, Postc, Payment), prefRegion(Rid, Postc, Region_Pref), prefType(Rid, Ctype, Case_Pref)}.

#show assign/2.
