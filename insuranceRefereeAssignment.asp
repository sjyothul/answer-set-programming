% clingo "C:\Users\Kenji Mah\Desktop\CSE579 Knowledge Representation and Reasoning\insurance refereee problem\code.asp" "C:\Users\Kenji Mah\Desktop\CSE579 Knowledge Representation and Reasoning\insurance refereee problem\simpleInstances\instance3.asp" 
%--opt-mode=enum 0
#const maxWorkload = 720.

%Generate search space = 1-1 function from domain(cases) to codomain(referees)
{assign(Cid,Rid): referee(Rid,_,_,_,_)}=1 :- case(Cid,_,_,_,_,_).

%%%%%%%%%%%%  Hard Constraints %%%%%%%%%%%%%%%

% The maximum number of working minutes of a referee must not be exceeded by the actual workload, 
%where the actual workload is the sum of the efforts of all cases assigned to this referee.
:- referee(Rid,_,Max_workload,_,_),Max_workload-S < 0, S=#sum{Effort: case(Cid,_,Effort,_,_,_),referee(Rid,_,_,_,_), assign(Cid,Rid)}.

% A case must not be assigned to a referee who is not in charge of the region at all
:- assign(Cid,Rid) , {prefRegion(Rid, Postc,Pref)}=0, case(Cid,_,_,_,Postc,_), referee(Rid,_,_,_,_).
:- assign(Cid,Rid) , prefRegion(Rid, Postc,0), case(Cid,_,_,_,Postc,_), referee(Rid,_,_,_,_).

% A case must not be assigned to a referee who is not in charge of the type of the case at all
:- assign(Cid,Rid), {prefType(Rid, Caset,Pref)}=0, case(Cid,Caset,_,_,_,_), referee(Rid,_,_,_,_).
:- assign(Cid,Rid), prefType(Rid, Caset,0), case(Cid,Caset,_,_,_,_), referee(Rid,_,_,_,_).

% Cases with an amount of damage that exceeds a certain threshold can only be assigned to internal referees.
:- assign(Cid,Rid), case(Cid,_,_,Damage,_,_), referee(Rid,e,_,_,_), Damage > X, externalMaxDamage(X).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%% Weak Constraints %%%%%%%%%%%%%%%%%

% Internal referees are preferred in order to minimize the costs of external ones. 
:~ C_a=#sum{Payment,Cid,Rid:case(Cid,_,_,_,_,Payment), assign(Cid,Rid), referee(Rid,e,_,_,_)}. [16*C_a]

% The assignment of cases to external referees should be fair in the sense that their overall payment should be balanced
o_rid(Rid,X) :- referee(Rid,e,_,_,Prev_payment), X=Prev_payment+N, N=#sum{Payment,Cid:case(Cid,_,_,_,_,Payment),assign(Cid,Rid)}.
averageE(A) :- A=S/N, S=#sum{X,Rid: o_rid(Rid,X)}, N=#count{Rid: referee(Rid,e,_,_,_)}.
:~ averageE(A), o_rid(Rid,X). [7*|A-X|,Rid]

% The assignment of cases to (internal and external) referees should be fair in the sense that their overall workload should be balanced.
w_rid(Rid,X) :- referee(Rid,_,_,Prev_workload,_), X=Prev_workload+N, N=#sum{Effort,Cid:case(Cid,_,Effort,_,_,_),assign(Cid,Rid)}.
average(A) :- A=S/N, S=#sum{X,Rid: w_rid(Rid,X)}, N=#count{Rid: referee(Rid,_,_,_,_)}.
:~ average(A),w_rid(Rid,X). [9*|A-X|,Rid]

% Referees should handle types of cases with higher preference.
:~ S=#sum{3-Pref,Cid,Rid: assign(Cid,Rid), referee(Rid,_,_,_,_), case(Cid, Caset, _, _, _, _), prefType(Rid,Caset,Pref)}. [34*S]


% Referees should handle cases in regions with higher preference.
:~ S=#sum{3-Pref,Cid,Rid: assign(Cid,Rid), referee(Rid,_,_,_,_), case(Cid, Caset, _, _, _, _), prefRegion(Rid,Postc,Pref)}. [34*S]

#show assign/2.
