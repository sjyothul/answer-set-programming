block(a).
block(b).
block(c).
block(d).
block(e).
block(f).
block(g).
block(h).
block(i).
block(j).
block(k).
block(l).
block(m).
block(n).
block(o).

%initial state
:-not on(m,table,0).
:-not on(l,m,0).
:-not on(a,l,0).
:-not on(b,a,0).
:-not on(c,b,0).
:-not on(o,table,0).
:-not on(n,o,0).
:-not on(d,n,0).
:-not on(e,d,0).
:-not on(j,e,0).
:-not on(k,j,0).
:-not on(f,table,0).
:-not on(g,f,0).
:-not on(h,g,0).
:-not on(i,h,0).

%goal
:-not on(e,j,tt).
:-not on(a,e,tt).
:-not on(n,a,tt).
:-not on(i,d,tt).
:-not on(h,i,tt).
:-not on(m,h,tt).
:-not on(o,m,tt).
:-not on(k,g,tt).
:-not on(c,k,tt).
:-not on(b,c,tt).
:-not on(l,b,tt).