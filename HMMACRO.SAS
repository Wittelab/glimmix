%inc 'glimmix.sas' / nosource;
%inc 'hm1.sas' / nosource;

%getXZ(dir=,
       Ydata=Y_dat,
       Wdata=W_dat,
       Xdata=X_dat,
       Zdata=Z_dat,
       taudata=tau_dat,
       nvarX=12, nvarZ = 8, nvarW=6,
       semi=YES,
       cov=YES);

%glimmix(data=dataset, procopt=mmeqsol,
  stmts=%str(
        model Y1 = W1 W2 W3 W4 W5 W6
                   col1 col2 col3 col4 col5 col6 col7 col8 / solution;
        random     X1 X2 X3 X4 X5 X6 X7 X8 X9 X10 X11 X12 / g gdata=tau2 solution;
        make 'mmeqsol' out=mmeqsol;
        make 'g' out=g;
        ),
        options=mixprintlast, error=binomial
             )
      run;

%get_oput(dir=,
          Xdata=X_dat,
          Zdata=Z_dat,
          nvarX=12, nvarZ = 8, nvarW=6, nmsol=28);
