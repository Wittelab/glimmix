options ls = 70;

%macro numvar(number,tdata);
  %local i;
  %do i = 1 %to &number;
    &tdata&i
  %end;
%mend numvar;

%macro getdata(dirr, filename, typedata, nvar);
  data &filename.x;
  infile "&dir&filename";
  input %numvar(&nvar, &typedata);
  code = _n_;
  run;
%mend getdata;


%macro getXZ(dir=, Ydata=, Wdata=, Xdata=, Zdata=,
            taudata=, nvarX=, nvarZ=, nvarW=,
            semi=, cov=);

  %let nvarY = 1;
  %getdata(dirr=&dir, filename=&Ydata, typedata=Y, nvar=&nvarY);
  %if %upcase(&cov)=YES %then
      %getdata(dirr=&dir, filename=&Wdata, typedata=W, nvar=&nvarW);
  %getdata(dirr=&dir, filename=&Xdata, typedata=X, nvar=&nvarX);
  %getdata(dirr=&dir, filename=&Zdata, typedata=Z, nvar=&nvarZ);

  proc iml;
    use &Xdata.x;
    read all var { %numvar(&nvarX, X) } into X;
    use &Zdata.x;
    read all var { %numvar(&nvarZ, Z) } into Z;

    XZ = X*Z;

    create XZdata from XZ;
    append from XZ;
  quit;

  data XZdata;
    set XZdata;
    code=_n_;
  run;

  data dataset;
    %if %upcase(&cov=YES) %then
      %do;
      merge &Ydata.x &Wdata.x &Xdata.x XZdata;
      by code;
      %end;
    %else
      %do;
      merge &Ydata.x &Xdata.x XZdata;
      by code;
      %end;
  run;


  %if %upcase(&semi=YES) %then
    %do;
      data tau2;
        infile "&dir&taudata";
        input value;
        keep row col value;
        row = _n_;
        col = _n_;
      run;
    %end;

%mend getXZ;


%macro get_oput(dir=, Xdata=, Zdata=,
                nvarX=, nvarZ=, nvarW=, nmsol=);
  proc iml;
    use mmeqsol;
    read all var { %numvar(&nmsol, col) } into mmeqsol;

    p1 = &nvarW + 2;
    p2 = &nvarZ + &nvarW + 1;
    d1 = &nvarZ + p1;
    d2 = &nvarZ + &nvarW + &nvarX + 1;

    varpi = mmeqsol[p1:p2, p1:p2];
    varD = mmeqsol[d1:d2, d1:d2];
    cov_pd = mmeqsol[p1:p2, d1:d2];
    pi = mmeqsol[p1:p2, &nmsol];
    delta = mmeqsol[d1:d2, &nmsol];

    use &Xdata.x;
    read all var { %numvar(&nvarX, X) } into X;
    use &Zdata.x;
    read all var { %numvar(&nvarZ, Z) } into Z;

    b=Z*pi + delta; /* calculating the estimates for beta  */
    orb=exp(b);

    varb=Z*varpi*t(Z) + vard + Z*cov_pd + t(cov_pd)*t(Z);
    /* covariance matrix of t */

    stderr=vecdiag(varb);

    do i=1 to nrow(varb);
    if stderr[i]<0 then stderr[i]=0;
    end;
    stderr=sqrt(stderr);
    lower=b-1.96*stderr; /* upper and lower confidence bounds of beta */
    upper=b+1.96*stderr;

    orb=exp(b); /* first stage odds ratio */
    orupper=exp(upper); /* upper and lower confidence bounds of odds ratio */
    orlower=exp(lower);

    varpi=vecdiag(varpi);
    /* variances of the second stage covariate estimates */
    stdpi=sqrt(varpi);

    x = t("X1":"X&nvarX");
    z = t("Z1":"Z&nvarZ");
    print x b stderr, x orb orlower orupper,
    z pi stdpi;
  quit;

%mend get_oput;
