CREATE OR REPLACE VIEW vw_partnership_performance AS
SELECT 
    b.name AS brand_name,
    c.name AS artist_name,
    p.sub_brand,
    p.start_year,
    p.end_year,
    p.est_peak_annual_rev,
    ROUND(AVG(af.total_revenue), 2) AS avg_brand_rev_during_deal,
    ROUND(
        (p.est_peak_annual_rev / MAX(af.total_revenue)) * 100, 
        2
    ) AS peak_revenue_share_pct
FROM partnerships p
JOIN brands b 
    ON p.brand_id = b.id
JOIN collaborators c 
    ON p.collaborator_id = c.id
LEFT JOIN annual_financials af 
    ON af.brand_id = p.brand_id
    AND af.fiscal_year >= p.start_year
    AND (af.fiscal_year <= p.end_year OR p.end_year IS NULL)
GROUP BY 
    b.name,
    c.name,
    p.sub_brand,
    p.start_year,
    p.end_year,
    p.est_peak_annual_rev;
