SELECT * FROM marketing_analytics.campaigns;
 
 ALTER TABLE campaigns
ADD COLUMN Brand VARCHAR(20) AFTER Campaign_ID;
 
 DESCRIBE campaigns;
 
 select Brand, Count(*) as brand_count 
 from campaigns
 group by Brand;
 
 -- EDA
 -- 1. idenitfy unique
 select distinct Campaign_Type from campaigns;
 select distinct Language From campaigns; 
 select distinct Customer_Segment from campaigns;
 
 TRUNCATE TABLE campaigns; -- delete the data in table
 
 -- 2. Identify NULL
 select
 sum(case when Impressions is NUll then 1 else 0 end)
 as null_impression,
 sum(case when Clicks is NULL then 1 else 0 end)
 as null_clicks,
 sum(case when Acquisition_Cost is NULL then 1 else 0 end)
 as null_acquisisiton
 from campaigns; 
 
 -- 3. check duplicate
 select Campaign_ID, Count(*) as dup_count
 from campaigns
 group by Campaign_ID
 Having count(*) > 1
 order by dup_count DESC;
 
 -- 4. funnel check
 select 
 sum(case when Clicks > Impressions then 1 else 0 end) as clicks_gt_impressions,
 sum(case when Leads > Clicks then 1 else 0 end) as leads_gt_impressions,
 sum(case when Conversions > Leads then 1 else 0 end) as conversion_gt_leads
 from campaigns
 where Impressions is NOT NULL
 and Clicks is not NULL;
 
 -- 5. Negative Check
 select
 sum( case when Impressions < 0 then 1 else 0 End) as neg_impressions,
 sum(case when Revenue < 0 then 1 else 0 end) as neg_revenue
 from campaigns;
 
 -- 6. Primary Key
 alter table campaigns add Primary Key (Campaign_ID);
 
 -- 7. Stat
 select 
 Brand,
 Count(*)  as total_campaigns,
 round(avg(Duration),1) as avg_duration,
 round(avg(Impressions),1) as avg_impressions,
 round(avg(Clicks),1) as avg_clicks,
 round(avg(Revenue),1) as avg_revenue,
 round(avg(ROI),2) as avg_roi
 from campaigns
 group by Brand;

 -- 9. KPI by Brand
 select 
 Brand,
 count(*) as total_campaigns,
 sum(Revenue) as total_revenue,
 sum(Acquisition_Cost * Conversions) as total_spend,
 -- KPI Weight Avergae
 round(sum(Clicks) / sum(Impressions),4) as overall_CTR,
 round(sum(Leads)/ sum(Clicks),4) as overal_Lead_rate,
 round(sum(Conversions)/sum(Leads),4) as overall_Conv_Rate,
 round(sum(Acquisition_Cost * Conversions) / sum(Conversions),2) as overall_CPA,
 round(
 (sum(Revenue) - sum(Acquisition_Cost * Conversions)) / Sum(Acquisition_Cost * Conversions), 4) as overall_ROI
 from campaigns
 group by Brand;
 
 -- 10. KPI by Campaigns
  select 
 Campaign_Type,
 count(*) as total_campaigns,
 round(sum(Clicks) / sum(Impressions),4) as overall_CTR,
 round(sum(Acquisition_Cost * Conversions) / sum(Conversions),2) as overall_CPA,
 round(
 (sum(Revenue) - sum(Acquisition_Cost * Conversions)) / Sum(Acquisition_Cost * Conversions), 4) as overall_ROI
 from campaigns
 group by Campaign_Type;
 
 -- 11. brand x campaigns
 select 
 Brand,
 Campaign_Type,
 count(*) as total_campaigns,
round(sum(Revenue),0) as total_revenue,
 round(
 (sum(Revenue) - sum(Acquisition_Cost * Conversions)) / Sum(Acquisition_Cost * Conversions), 4) as ROI
 from campaigns
 group by Brand, Campaign_Type
 order by Brand, ROI DESC;