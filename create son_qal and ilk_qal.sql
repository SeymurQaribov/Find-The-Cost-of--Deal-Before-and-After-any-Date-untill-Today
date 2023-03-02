DECLARE @date1 DATETIME='01.01.2014'
DECLARE @date2 DATETIME='03.02.2023'


SELECT *, med_meb/2 med_cem, mex_meb/2 mex_cem
  FROM (
SELECT t1.kontra, SPACE(5)+CONVERT(NVARCHAR(20), t1.tarix, 104)+' - '+t1.emel_name+' - '+t1.sen_no name,
    (ISNULL((select sum(nov*mebleg) from sm_kontr_qal where tarix<@date1 ),0) +
       sum(t1.nov*mebleg) over (partition by kontra order by kontra,tarix,t1.idn,(SPACE(5)+CONVERT(NVARCHAR(20), t1.tarix, 104)+' - '+t1.emel_name+' - '+t1.sen_no )
) - t1.nov*t1.mebleg )ilk_qal,
	    
       CASE WHEN t1.nov=1 THEN t1.mebleg END med_meb,
       CASE WHEN t1.nov=-1 THEN t1.mebleg END mex_meb,
      (ISNULL((select sum(nov*mebleg) from sm_kontr_qal where tarix<@date1 ),0) +
       sum(t1.nov*mebleg) over (partition by kontra order by kontra,tarix,t1.idn,(SPACE(5)+CONVERT(NVARCHAR(20), t1.tarix, 104)+' - '+t1.emel_name+' - '+t1.sen_no )
)) son_qaliq,
	   t2.firma,
       t1.emel_name, t1.tarix, t1.emel, t1.idn, t1.serh,
       1 xus, 11 sira
  FROM sm_kontr_qal t1, sm_kontra t2
 WHERE t1.kontra=t2.idn AND t1.tarix BETWEEN @date1 AND @date2   
        
 UNION ALL
SELECT t1.kontra, t2.name,
       SUM(CASE WHEN t1.tarix<@date1 THEN t1.nov*t1.mebleg END) ilk_meb,
       SUM(CASE WHEN t1.nov=1 AND t1.tarix BETWEEN @date1 AND @date2 THEN t1.mebleg END) med_meb,
       SUM(case when t1.nov=-1 and t1.tarix BETWEEN @date1 AND @date2 THEN t1.mebleg END) mex_meb,
       SUM(t1.nov*t1.mebleg) son_meb,t2.firma,
       NULL emel_name, NULL tarix, NULL emel, NULL idn, NULL serh,
       24 xus, 1 sira
  FROM sm_kontr_qal t1, sm_kontra t2
 WHERE t1.kontra=t2.idn AND t1.tarix<=@date2
        
 GROUP BY t1.kontra, t2.name,t2.firma) t
 ORDER BY kontra, tarix,idn,name