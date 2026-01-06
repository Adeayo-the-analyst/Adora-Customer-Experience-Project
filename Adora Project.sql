
-- Look at the persona churn rate
SELECT 
    persona,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users
FROM adora
GROUP BY persona
ORDER BY total_users DESC;



-- Since there are a lot of ghosts and hybrids, is onboarding an issue?
SELECT
    persona,
    onboarding_status,
    plan_type_id,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users
FROM adora
WHERE persona IN ('Ghost', 'Hybrid')
GROUP BY persona, onboarding_status, plan_type_id
ORDER BY total_users DESC;

-- Check their signup_channel and link it to usage_intensity
SELECT
    persona,
    signup_channel,
    usage_intensity,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users
FROM adora
WHERE persona IN ('Ghost', 'Hybrid')
    AND usage_intensity <> 'N/A'
GROUP BY persona, signup_channel, usage_intensity

-- How engaged are the ghosts and hybrids
SELECT 
    persona,
    meaningful_session_ratio,
    short_session_ratio,
    friction_level,
    experience_level,
    COUNT([user_id]) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    CONCAT(ROUND(100.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 2), '%') AS churn_rate
FROM adora
WHERE persona IN ('Ghost', 'Hybrid')
GROUP BY persona, meaningful_session_ratio, short_session_ratio, experience_level, friction_level
ORDER BY total_users DESC;

SELECT
    persona,
    plan_type_id,
    signup_channel,
    CASE
        WHEN meaningful_session_ratio >= 0.8 AND short_session_ratio <= 0.2 AND success_rate = 1 THEN 'High Intent'
        WHEN meaningful_session_ratio BETWEEN 0.5 AND 0.8 AND short_session_ratio BETWEEN 0.2 AND 0.5 THEN 'Moderate Engagement'
        WHEN meaningful_session_ratio < 0.5 AND short_session_ratio > 0.5 THEN 'Low Value / High Churn Risk'
        WHEN total_sessions <= 2 THEN 'Sparse Activity'
        ELSE 'Other'
    END AS engagement_segment,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    CONCAT(ROUND(100.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 2), '%') AS churn_rate
FROM adora
WHERE persona IN ('Hybrid', 'Ghost')
GROUP BY persona, plan_type_id, signup_channel,
    CASE
        WHEN meaningful_session_ratio >= 0.8 AND short_session_ratio <= 0.2 AND success_rate = 1 THEN 'High Intent'
        WHEN meaningful_session_ratio BETWEEN 0.5 AND 0.8 AND short_session_ratio BETWEEN 0.2 AND 0.5 THEN 'Moderate Engagement'
        WHEN meaningful_session_ratio < 0.5 AND short_session_ratio > 0.5 THEN 'Low Value / High Churn Risk'
        WHEN total_sessions <= 2 THEN 'Sparse Activity'
        ELSE 'Other'
    END 
ORDER BY churn_rate DESC;


-- Look at operational levers for the ghosts and hybrids
SELECT
    persona,
    plan_type,
    signup_channel,
    fail_rate,
    error_rate,
    frustration_level,
    friction_level,
    CASE
        WHEN meaningful_session_ratio >= 0.8 AND short_session_ratio <= 0.2 AND (fail_rate = 0 or fail_rate IS NULL) THEN 'High Intent'
        WHEN meaningful_session_ratio BETWEEN 0.5 AND 0.8 AND short_session_ratio BETWEEN 0.2 AND 0.5 THEN 'Moderate Engagement'
        WHEN meaningful_session_ratio < 0.5 AND short_session_ratio > 0.5 THEN 'Low Value / High Churn Risk'
        WHEN total_sessions <= 2 THEN 'Sparse Activity'
        ELSE 'Other'
    END AS engagement_segment,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    CONCAT(ROUND(100.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 2), '%') AS churn_rate
FROM adora
WHERE persona IN ('Hybrid', 'Ghost')
GROUP BY persona, plan_type, signup_channel, error_rate, fail_rate, friction_level, frustration_level,
    CASE
        WHEN meaningful_session_ratio >= 0.8 AND short_session_ratio <= 0.2 AND (fail_rate = 0 or fail_rate IS NULL) THEN 'High Intent'
        WHEN meaningful_session_ratio BETWEEN 0.5 AND 0.8 AND short_session_ratio BETWEEN 0.2 AND 0.5 THEN 'Moderate Engagement'
        WHEN meaningful_session_ratio < 0.5 AND short_session_ratio > 0.5 THEN 'Low Value / High Churn Risk'
        WHEN total_sessions <= 2 THEN 'Sparse Activity'
        ELSE 'Other'
    END 
ORDER BY churn_rate DESC;

-- Does onboarding status play a role in customer retention
SELECT
    persona,
    onboarding_status,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    CONCAT(ROUND(100.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/ COUNT(user_id), 2), '%') AS churn_rate
FROM adora
WHERE persona NOT IN ('Hybrid', 'Ghost')
GROUP BY persona, onboarding_status
ORDER BY churn_rate DESC;

-- What of plan_type?
SELECT
    persona,
    plan_type_id,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    CONCAT(ROUND(100.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/ COUNT(user_id), 2), '%') AS churn_rate
FROM adora
WHERE persona NOT IN ('Hybrid', 'Ghost')
GROUP BY persona, plan_type_id
ORDER BY churn_rate DESC;

-- Look at the relationship between plan_type and user experience
SELECT
    persona,
    plan_type_id,
    friction_level,
    experience_level,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    CONCAT(ROUND(100.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/ COUNT(user_id), 2), '%') AS churn_rate
FROM adora
WHERE persona NOT IN ('Hybrid', 'Ghost')
GROUP BY persona, plan_type_id, experience_level, friction_level
ORDER BY total_users DESC;


SELECT
    persona,
    CASE
        WHEN experience_level IN ('Flawless', 'Mostly Successful') THEN 'Successful'
        WHEN experience_level IN ('High Friction', 'Failed') THEN 'Failed'
        ELSE 'Mixed'
    END AS experience_level,
    CASE
        WHEN friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
        ELSE 'Low Friction'
    END AS friction_level,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(100.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/ COUNT(user_id), 2) AS churn_rate
FROM adora
WHERE persona NOT IN ('Hybrid', 'Ghost')
    AND experience_level IS NOT NULL
    AND friction_level IS NOT NULL
GROUP BY persona,
     CASE
        WHEN experience_level IN ('Flawless', 'Mostly Successful') THEN 'Successful'
        WHEN experience_level IN ('High Friction', 'Failed') THEN 'Failed'
        ELSE 'Mixed'
    END,
    CASE
        WHEN friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
        ELSE 'Low Friction'
    END
HAVING COUNT(user_id) > 30
ORDER BY total_users DESC; 


-- What of signup_channel?
SELECT
    persona,
    signup_channel,
    plan_type_id,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    CONCAT(ROUND(100.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/ COUNT(user_id), 2), '%') AS churn_rate
FROM adora
WHERE persona NOT IN ('Hybrid', 'Ghost')
GROUP BY persona, plan_type_id, signup_channel
ORDER BY total_users DESC;



-- See what usage intensity, friction level, and frustration level has to do
SELECT
    persona,
    usage_intensity,
    CASE
        WHEN experience_level IN ('Flawless', 'Mostly Successful') THEN 'Successful'
        WHEN experience_level IN ('High Friction', 'Failed') THEN 'Failed'
        ELSE 'Mixed'
    END AS experience_level,
     CASE
        WHEN friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
        ELSE 'Low Friction'
    END AS friction_level,
    COALESCE(support_contact_category, 'No Help') AS support_contact_category,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    CONCAT(ROUND(100.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/ COUNT(user_id), 2), '%') AS churn_rate
FROM adora
WHERE persona NOT IN ('Hybrid', 'Ghost')
GROUP BY persona, usage_intensity, 
      CASE
        WHEN experience_level IN ('Flawless', 'Mostly Successful') THEN 'Successful'
        WHEN experience_level IN ('High Friction', 'Failed') THEN 'Failed'
        ELSE 'Mixed'
    END,
     CASE
        WHEN friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
        ELSE 'Low Friction'
    END,
    support_contact_category
HAVING COUNT(user_id) >= 30
ORDER BY churn_rate DESC;

-- Quantify the impact of support on friction and experience
WITH support_aggregated AS (
    SELECT
        persona,
        CASE
            WHEN experience_level IN ('Flawless', 'Mostly Successful') THEN 'Successful'
            WHEN experience_level IN ('High Friction', 'Failed') THEN 'Failed'
            ELSE 'Mixed'
        END AS experience_level,
        CASE
            WHEN friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
            ELSE 'Low Friction'
        END AS friction_level,
        COALESCE(support_contact_category, 'No Help') AS support_contact_category,
        COUNT(user_id) AS total_users,
        SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
        ROUND(SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/ COUNT(user_id), 2) AS churn_rate
    FROM adora 
    WHERE persona NOT IN ('Hybrid', 'Ghost')
    GROUP BY   
        persona, support_contact_category,
        CASE
            WHEN experience_level IN ('Flawless', 'Mostly Successful') THEN 'Successful'
            WHEN experience_level IN ('High Friction', 'Failed') THEN 'Failed'
            ELSE 'Mixed'
        END,
        CASE
            WHEN friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
            ELSE 'Low Friction'
        END
),
-- Compute churn baseline per friction and experience
friction_experience_baseline AS (
    SELECT
        friction_level,
        experience_level,
        SUM(churned_users) AS total_churned,
        SUM(total_users) AS total_users,
        ROUND(1.0 * SUM(churned_users)/SUM(total_users), 2) AS baseline_churn_rate
    FROM support_aggregated
    WHERE persona NOT IN ('Ghost', 'Hybrid')
    GROUP BY friction_level, experience_level
),
-- Merge baseline with each support category to compute lift
support_lift AS (
    SELECT
        sa.persona,
        sa.experience_level,
        sa.friction_level,
        sa.support_contact_category,
        sa.total_users,
        sa.churned_users,
        ROUND(sa.churned_users * 1.0/sa.total_users, 4) AS churn_rate,
        feb.baseline_churn_rate,
        ROUND((sa.churned_users * 1.0 /sa.total_users) - feb.baseline_churn_rate, 4) AS lift_vs_baseline
    FROM support_aggregated sa
    INNER JOIN friction_experience_baseline feb
        ON sa.friction_level = feb.friction_level
            AND sa.experience_level = feb.experience_level
)
-- Apply minimum cohort size filter
SELECT *
FROM support_lift
WHERE total_users >= 30
ORDER BY friction_level, experience_level, lift_vs_baseline DESC;

-- Rank support types by lift
-- Step 1: Compute lift vs baseline per friction x experience x support
WITH churn_support AS (
    SELECT
        CASE
            WHEN experience_level IN ('Flawless', 'Mostly Successful') THEN 'Successful'
            WHEN experience_level IN ('High Friction', 'Failed') THEN 'Failed'
            ELSE 'Mixed'
        END AS experience_level,
        CASE
            WHEN friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
            ELSE 'Low Friction'
        END AS friction_level,
        COALESCE(support_contact_category, 'No Help') AS support_contact_category,
        COUNT(user_id) AS total_users,
        SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
        ROUND(SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) * 1.0/COUNT(user_id),4) AS churn_rate
    FROM adora
    WHERE persona NOT IN ('Ghost', 'Hybrid')
    GROUP BY support_contact_category,
        CASE
            WHEN experience_level IN ('Flawless', 'Mostly Successful') THEN 'Successful'
            WHEN experience_level IN ('High Friction', 'Failed') THEN 'Failed'
            ELSE 'Mixed'
        END,
        CASE
            WHEN friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
            ELSE 'Low Friction'
        END 
),


-- Step 2: Compute baseline churn per friction x experience (ignoring support)
baseline AS (
    SELECT
          CASE
            WHEN experience_level IN ('Flawless', 'Mostly Successful') THEN 'Successful'
            WHEN experience_level IN ('High Friction', 'Failed') THEN 'Failed'
            ELSE 'Mixed'
        END AS experience_level,
        CASE
            WHEN friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
            ELSE 'Low Friction'
        END AS friction_level,
        COUNT(user_id) AS total_users,
        SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
        ROUND(SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) * 1.0 / COUNT(user_id), 4) AS baseline_churn_rate
    FROM adora
    WHERE persona NOT IN ('Ghost', 'Hybrid')
    GROUP BY    
        CASE
            WHEN experience_level IN ('Flawless', 'Mostly Successful') THEN 'Successful'
            WHEN experience_level IN ('High Friction', 'Failed') THEN 'Failed'
            ELSE 'Mixed'
        END,
        CASE
            WHEN friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
            ELSE 'Low Friction'
        END
),
-- Step 3: Join to compute lift
lift_calc AS (
    SELECT
        c.friction_level,
        c.experience_level,
        c.support_contact_category,
        c.total_users,
        c.churned_users,
        c.churn_rate,
        b.baseline_churn_rate,
        ROUND(c.churn_rate - b.baseline_churn_rate, 4) AS lift_vs_baseline
    FROM churn_support c
    INNER JOIN baseline b
        ON c.friction_level = b.friction_level
        AND c.experience_level = b.experience_level
    WHERE c.total_users >= 30
)
SELECT
    friction_level,
    experience_level,
    support_contact_category,
    total_users,
    churned_users,
    churn_rate,
    baseline_churn_rate,
    lift_vs_baseline,
    RANK () OVER (PARTITION BY friction_level, experience_level ORDER BY lift_vs_baseline DESC) AS support_rank
FROM lift_calc
ORDER BY friction_level, experience_level, support_rank;

-- Look at the effectiveness of the onboarding
WITH onboarding AS (
    SELECT
        CASE
            WHEN experience_level IN ('Flawless', 'Mostly Successful') THEN 'Successful'
            WHEN experience_level IN ('High Friction', 'Failed') THEN 'Failed'
            ELSE 'Mixed'
        END AS experience_level,
        CASE
            WHEN friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
            ELSE 'Low Friction'
        END AS friction_level,
        onboarding_status,
        COUNT(user_id) AS total_users,
        SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
        ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
    FROM adora
    WHERE persona NOT IN ('Ghost', 'Hybrid')
    GROUP BY onboarding_status,
        CASE
            WHEN experience_level IN ('Flawless', 'Mostly Successful') THEN 'Successful'
            WHEN experience_level IN ('High Friction', 'Failed') THEN 'Failed'
            ELSE 'Mixed'
        END,
        CASE
            WHEN friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
            ELSE 'Low Friction'
        END
),

-- Step 2: Compute the baseline
baseline AS (
    SELECT
        CASE
            WHEN experience_level IN ('Flawless', 'Mostly Successful') THEN 'Successful'
            WHEN experience_level IN ('High Friction', 'Failed') THEN 'Failed'
            ELSE 'Mixed'
        END AS experience_level,
        CASE
            WHEN friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
            ELSE 'Low Friction'
        END AS friction_level,
        COUNT(user_id) AS total_users,
        SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
        ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS baseline_churn_rate
    FROM adora
    WHERE persona NOT IN ('Ghost', 'Hybrid')
    GROUP BY 
        CASE
            WHEN experience_level IN ('Flawless', 'Mostly Successful') THEN 'Successful'
            WHEN experience_level IN ('High Friction', 'Failed') THEN 'Failed'
            ELSE 'Mixed'
        END,
        CASE
            WHEN friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
            ELSE 'Low Friction'
        END
),
lift_calc AS (
    SELECT
        o.onboarding_status,
        o.friction_level,
        o.experience_level,
        o.total_users,
        o.churned_users,
        o.churn_rate,
        b.baseline_churn_rate,
        ROUND(o.churn_rate - b.baseline_churn_rate, 4) AS lift_vs_baseline
    FROM onboarding o
    INNER JOIN baseline b
        ON o.friction_level = b.friction_level
        AND b.experience_level = o.experience_level
    WHERE o.total_users >= 30
)
SELECT
    onboarding_status,
    friction_level,
    experience_level,
    total_users,
    churned_users,
    churn_rate,
    baseline_churn_rate,
    lift_vs_baseline,
    RANK() OVER (PARTITION BY friction_level, experience_level ORDER BY lift_vs_baseline DESC) AS onboarding_rank
FROM lift_calc
ORDER BY onboarding_status, friction_level, experience_level, onboarding_rank

-- Let us see how onboarding and support compare with intervention
WITH onboarding AS (
    SELECT
        onboarding_status,
         CASE
            WHEN experience_level IN ('Flawless', 'Mostly Successful') THEN 'Successful'
            WHEN experience_level IN ('High Friction', 'Failed') THEN 'Failed'
            ELSE 'Mixed'
        END AS experience_level,
        CASE
            WHEN friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
            ELSE 'Low Friction'
        END AS friction_level,
        COUNT(user_id) AS total_users,
        SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
        ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS onboarding_churn_rate
    FROM adora
    WHERE persona NOT IN ('Ghost', 'Hybrid')
    GROUP BY onboarding_status,
        CASE
            WHEN experience_level IN ('Flawless', 'Mostly Successful') THEN 'Successful'
            WHEN experience_level IN ('High Friction', 'Failed') THEN 'Failed'
            ELSE 'Mixed'
        END,
        CASE
            WHEN friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
            ELSE 'Low Friction'
        END
),

-- Step 2: Compute a table for support separately
support AS (
    SELECT
        COALESCE(support_contact_category, 'No Help') AS support_contact_category,
        CASE
            WHEN experience_level IN ('Flawless', 'Mostly Successful') THEN 'Successful'
            WHEN experience_level IN ('High Friction', 'Failed') THEN 'Failed'
            ELSE 'Mixed'
        END AS experience_level,
        CASE
            WHEN friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
            ELSE 'Low Friction'
        END AS friction_level,
        COUNT(user_id) AS total_users,
        SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
        ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS support_churn_rate
    FROM adora
    WHERE persona NOT IN ('Ghost', 'Hybrid')
    GROUP BY support_contact_category,
        CASE
            WHEN experience_level IN ('Flawless', 'Mostly Successful') THEN 'Successful'
            WHEN experience_level IN ('High Friction', 'Failed') THEN 'Failed'
            ELSE 'Mixed'
        END,
        CASE
            WHEN friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
            ELSE 'Low Friction'
        END
),
-- Set the baseline churn rate
baseline AS (
    SELECT
        CASE
            WHEN experience_level IN ('Flawless', 'Mostly Successful') THEN 'Successful'
            WHEN experience_level IN ('High Friction', 'Failed') THEN 'Failed'
            ELSE 'Mixed'
        END AS experience_level,
        CASE
            WHEN friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
            ELSE 'Low Friction'
        END AS friction_level,
        COUNT(user_id) AS total_users,
        SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
        ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS baseline_churn_rate
    FROM adora
    WHERE persona NOT IN ('Ghost', 'Hybrid')
    GROUP BY
        CASE
            WHEN experience_level IN ('Flawless', 'Mostly Successful') THEN 'Successful'
            WHEN experience_level IN ('High Friction', 'Failed') THEN 'Failed'
            ELSE 'Mixed'
        END,
        CASE
            WHEN friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
            ELSE 'Low Friction'
        END
)
-- Create a new table that includes both the onboarding and support
SELECT
    b.friction_level,
    b.experience_level,

    -- Onboarding info,
    o.onboarding_status,
    o.total_users AS onboarding_total_users,
    o.churned_users AS onboarding_churned_users,
    o.onboarding_churn_rate,
    ROUND(o.onboarding_churn_rate - b.baseline_churn_rate, 4) AS onboarding_lift_vs_baseline,

    -- Support info
    s.support_contact_category,
    s.total_users,
    s.churned_users,
    s.support_churn_rate,
    ROUND(s.support_churn_rate - b.baseline_churn_rate,4) AS support_lift_vs_baseline,
    -- Shared baseline
    b.baseline_churn_rate
FROM baseline b
LEFT JOIN onboarding o
    ON b.friction_level = o.friction_level
    AND b.experience_level  = o.experience_level
LEFT JOIN support s 
    ON b.friction_level = s.friction_level
    AND b.experience_level = s.experience_level
WHERE o.total_users >= 30 OR s.total_users >= 30
ORDER BY b.friction_level, b.experience_level;

-- Look at the personas and how this affects them:
-- Look at the effectiveness of the onboarding
WITH onboarding AS (
    SELECT
        persona,
        CASE
            WHEN experience_level IN ('Flawless', 'Mostly Successful') THEN 'Successful'
            WHEN experience_level IN ('High Friction', 'Failed') THEN 'Failed'
            ELSE 'Mixed'
        END AS experience_level,
        CASE
            WHEN friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
            ELSE 'Low Friction'
        END AS friction_level,
        onboarding_status,
        COUNT(user_id) AS total_users,
        SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
        ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
    FROM adora
    WHERE persona NOT IN ('Ghost', 'Hybrid')
    GROUP BY persona, onboarding_status,
        CASE
            WHEN experience_level IN ('Flawless', 'Mostly Successful') THEN 'Successful'
            WHEN experience_level IN ('High Friction', 'Failed') THEN 'Failed'
            ELSE 'Mixed'
        END,
        CASE
            WHEN friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
            ELSE 'Low Friction'
        END
),

-- Step 2: Compute the baseline
baseline AS (
    SELECT
        persona,
        CASE
            WHEN experience_level IN ('Flawless', 'Mostly Successful') THEN 'Successful'
            WHEN experience_level IN ('High Friction', 'Failed') THEN 'Failed'
            ELSE 'Mixed'
        END AS experience_level,
        CASE
            WHEN friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
            ELSE 'Low Friction'
        END AS friction_level,
        COUNT(user_id) AS total_users,
        SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
        ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS baseline_churn_rate
    FROM adora
    WHERE persona NOT IN ('Ghost', 'Hybrid')
    GROUP BY persona,
        CASE
            WHEN experience_level IN ('Flawless', 'Mostly Successful') THEN 'Successful'
            WHEN experience_level IN ('High Friction', 'Failed') THEN 'Failed'
            ELSE 'Mixed'
        END,
        CASE
            WHEN friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
            ELSE 'Low Friction'
        END
),
lift_calc AS (
    SELECT
        o.persona,
        o.onboarding_status,
        o.friction_level,
        o.experience_level,
        o.total_users,
        o.churned_users,
        o.churn_rate,
        b.baseline_churn_rate,
        ROUND(o.churn_rate - b.baseline_churn_rate, 4) AS lift_vs_baseline
    FROM onboarding o
    INNER JOIN baseline b
        ON o.friction_level = b.friction_level
        AND b.experience_level = o.experience_level
    WHERE o.total_users >= 30
)
SELECT
    persona,
    onboarding_status,
    friction_level,
    experience_level,
    total_users,
    churned_users,
    churn_rate,
    baseline_churn_rate,
    lift_vs_baseline,
    RANK() OVER (PARTITION BY persona, friction_level, experience_level ORDER BY lift_vs_baseline ASC) AS onboarding_rank
FROM lift_calc
ORDER BY persona, onboarding_status, friction_level, experience_level, onboarding_rank


-- Next stop: Personas and support
WITH churn_support AS (
    SELECT
        persona,
        CASE
            WHEN experience_level IN ('Flawless', 'Mostly Successful') THEN 'Successful'
            WHEN experience_level IN ('High Friction', 'Failed') THEN 'Failed'
            ELSE 'Mixed'
        END AS experience_level,
        CASE
            WHEN friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
            ELSE 'Low Friction'
        END AS friction_level,
        COALESCE(support_contact_category, 'No Help') AS support_contact_category,
        COUNT(user_id) AS total_users,
        SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
        ROUND(SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) * 1.0/COUNT(user_id),4) AS churn_rate
    FROM adora
    WHERE persona NOT IN ('Ghost', 'Hybrid')
    GROUP BY persona, support_contact_category,
        CASE
            WHEN experience_level IN ('Flawless', 'Mostly Successful') THEN 'Successful'
            WHEN experience_level IN ('High Friction', 'Failed') THEN 'Failed'
            ELSE 'Mixed'
        END,
        CASE
            WHEN friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
            ELSE 'Low Friction'
        END 
),


-- Step 2: Compute baseline churn per friction x experience (ignoring support)
baseline AS (
    SELECT
        persona,
        CASE
            WHEN experience_level IN ('Flawless', 'Mostly Successful') THEN 'Successful'
            WHEN experience_level IN ('High Friction', 'Failed') THEN 'Failed'
            ELSE 'Mixed'
        END AS experience_level,
        CASE
            WHEN friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
            ELSE 'Low Friction'
        END AS friction_level,
        COUNT(user_id) AS total_users,
        SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
        ROUND(SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) * 1.0 / COUNT(user_id), 4) AS baseline_churn_rate
    FROM adora
    WHERE persona NOT IN ('Ghost', 'Hybrid')
    GROUP BY persona, 
        CASE
            WHEN experience_level IN ('Flawless', 'Mostly Successful') THEN 'Successful'
            WHEN experience_level IN ('High Friction', 'Failed') THEN 'Failed'
            ELSE 'Mixed'
        END,
        CASE
            WHEN friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
            ELSE 'Low Friction'
        END
),
-- Step 3: Join to compute lift
lift_calc AS (
    SELECT
        c.persona,
        c.friction_level,
        c.experience_level,
        c.support_contact_category,
        c.total_users,
        c.churned_users,
        c.churn_rate,
        b.baseline_churn_rate,
        ROUND(c.churn_rate - b.baseline_churn_rate, 4) AS lift_vs_baseline
    FROM churn_support c
    INNER JOIN baseline b
        ON c.friction_level = b.friction_level
        AND c.experience_level = b.experience_level
        AND c.persona = b.persona
    WHERE c.total_users >= 30
)
SELECT
    persona,
    friction_level,
    experience_level,
    support_contact_category,
    total_users,
    churned_users,
    churn_rate,
    baseline_churn_rate,
    lift_vs_baseline,
    RANK () OVER (PARTITION BY persona, friction_level, experience_level ORDER BY lift_vs_baseline ASC) AS support_rank
FROM lift_calc
ORDER BY persona, friction_level, experience_level, support_rank;


-- Next stop: Look at the comparison between onboarding and support
-- Let us see how onboarding and support compare with intervention
WITH onboarding AS (
    SELECT
        persona,
        onboarding_status,
         CASE
            WHEN experience_level IN ('Flawless', 'Mostly Successful') THEN 'Successful'
            WHEN experience_level IN ('High Friction', 'Failed') THEN 'Failed'
            ELSE 'Mixed'
        END AS experience_level,
        CASE
            WHEN friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
            ELSE 'Low Friction'
        END AS friction_level,
        COUNT(user_id) AS total_users,
        SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
        ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS onboarding_churn_rate
    FROM adora
    WHERE persona NOT IN ('Ghost', 'Hybrid')
    GROUP BY persona, onboarding_status,
        CASE
            WHEN experience_level IN ('Flawless', 'Mostly Successful') THEN 'Successful'
            WHEN experience_level IN ('High Friction', 'Failed') THEN 'Failed'
            ELSE 'Mixed'
        END,
        CASE
            WHEN friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
            ELSE 'Low Friction'
        END
),

-- Step 2: Compute a table for support separately
support AS (
    SELECT
        persona,
        COALESCE(support_contact_category, 'No Help') AS support_contact_category,
        CASE
            WHEN experience_level IN ('Flawless', 'Mostly Successful') THEN 'Successful'
            WHEN experience_level IN ('High Friction', 'Failed') THEN 'Failed'
            ELSE 'Mixed'
        END AS experience_level,
        CASE
            WHEN friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
            ELSE 'Low Friction'
        END AS friction_level,
        COUNT(user_id) AS total_users,
        SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
        ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS support_churn_rate
    FROM adora
    WHERE persona NOT IN ('Ghost', 'Hybrid')
    GROUP BY persona, support_contact_category,
        CASE
            WHEN experience_level IN ('Flawless', 'Mostly Successful') THEN 'Successful'
            WHEN experience_level IN ('High Friction', 'Failed') THEN 'Failed'
            ELSE 'Mixed'
        END,
        CASE
            WHEN friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
            ELSE 'Low Friction'
        END
),
-- Set the baseline churn rate
baseline AS (
    SELECT
        persona,
        CASE
            WHEN experience_level IN ('Flawless', 'Mostly Successful') THEN 'Successful'
            WHEN experience_level IN ('High Friction', 'Failed') THEN 'Failed'
            ELSE 'Mixed'
        END AS experience_level,
        CASE
            WHEN friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
            ELSE 'Low Friction'
        END AS friction_level,
        COUNT(user_id) AS total_users,
        SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
        ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS baseline_churn_rate
    FROM adora
    WHERE persona NOT IN ('Ghost', 'Hybrid')
    GROUP BY persona,
        CASE
            WHEN experience_level IN ('Flawless', 'Mostly Successful') THEN 'Successful'
            WHEN experience_level IN ('High Friction', 'Failed') THEN 'Failed'
            ELSE 'Mixed'
        END,
        CASE
            WHEN friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
            ELSE 'Low Friction'
        END
)
-- Create a new table that includes both the onboarding and support
SELECT
    b.persona,
    b.friction_level,
    b.experience_level,

    -- Onboarding info,
    o.onboarding_status,
    o.total_users AS onboarding_total_users,
    o.churned_users AS onboarding_churned_users,
    o.onboarding_churn_rate,
    ROUND(o.onboarding_churn_rate - b.baseline_churn_rate, 4) AS onboarding_lift_vs_baseline,

    -- Support info
    s.support_contact_category,
    s.total_users,
    s.churned_users,
    s.support_churn_rate,
    ROUND(s.support_churn_rate - b.baseline_churn_rate,4) AS support_lift_vs_baseline,
    -- Shared baseline
    b.baseline_churn_rate
FROM baseline b
LEFT JOIN onboarding o
    ON b.friction_level = o.friction_level
    AND b.experience_level  = o.experience_level
    AND b.persona = o.persona
LEFT JOIN support s 
    ON b.friction_level = s.friction_level
    AND b.experience_level = s.experience_level
    AND b.persona = s.persona
WHERE o.total_users >= 30 AND s.total_users >= 30
ORDER BY b.persona, b.friction_level, b.experience_level;


-- Switch to product experience
-- For founders, look at their experience with deployments
SELECT
    persona,
    CASE
        WHEN total_deployments BETWEEN 1 AND 5 THEN '1-5'
        WHEN total_deployments BETWEEN 6 AND 10 THEN '6-10'
        WHEN total_deployments BETWEEN 11 AND 15 THEN '11-15'
        WHEN total_deployments BETWEEN 16 AND 20 THEN '16-20'
        ELSE '20+'
    END AS deployment_use,
    MIN(total_failed_deployments) AS min_failed_deployments,
    MAX(total_failed_deployments) AS max_failed_deployments,
    AVG(total_failed_deployments) AS avg_failed_deployments,
    usage_intensity,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM adora
WHERE persona = 'Founder'
GROUP BY persona, usage_intensity,
     CASE
        WHEN total_deployments BETWEEN 1 AND 5 THEN '1-5'
        WHEN total_deployments BETWEEN 6 AND 10 THEN '6-10'
        WHEN total_deployments BETWEEN 11 AND 15 THEN '11-15'
        WHEN total_deployments BETWEEN 16 AND 20 THEN '16-20'
        ELSE '20+'
    END
HAVING COUNT(user_id) >= 30
ORDER BY total_users DESC;

-- Is churn among founders determined by deployment success and failure?
SELECT
    CASE
        WHEN total_successful_deployments > 0 AND total_failed_deployments = 0 THEN 'Founders who deployed successfully'
        WHEN total_failed_deployments > 0 AND total_successful_deployments = 0 THEN 'Founders who never deployed successfully'
        ELSE 'In between'
    END AS deployment_case,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM adora
WHERE persona = 'Founder'
GROUP BY 
     CASE
        WHEN total_successful_deployments > 0 AND total_failed_deployments = 0 THEN 'Founders who deployed successfully'
        WHEN total_failed_deployments > 0 AND total_successful_deployments = 0 THEN 'Founders who never deployed successfully'
        ELSE 'In between'
    END
--HAVING COUNT(user_id) >= 30
ORDER BY total_users DESC;

-- Look at the founders with 100% successful deployments
SELECT
    persona,
    usage_intensity,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM adora
WHERE persona = 'Founder'
    AND total_successful_deployments > 0 AND total_failed_deployments = 0
GROUP BY persona, usage_intensity 
ORDER BY total_users DESC;

-- Look at their other tool use
SELECT
    persona,
    usage_intensity,
    deployment_focus,
    COALESCE(app_build_focus, 0) AS app_build_focus,
    COALESCE(code_export_focus, 0) AS code_export_focus,
    COALESCE(design_focus, 0) AS design_focus,
    COALESCE(AI_focus, 0) AS AI_focus,
      COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users
   -- ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM adora
WHERE persona = 'Founder'
    AND total_successful_deployments > 0 AND total_failed_deployments = 0 
GROUP BY 
     persona,
     usage_intensity,
    deployment_focus,
    app_build_focus,
    code_export_focus,
    design_focus,
    AI_focus
ORDER BY total_users DESC;

-- How many sessions do they do before they churn? 
SELECT
    persona,
    total_sessions,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM adora
WHERE persona = 'Founder'
    AND total_successful_deployments > 0 AND total_failed_deployments = 0
GROUP BY persona, total_sessions
ORDER BY total_users DESC;

-- 
SELECT
    persona,
    total_sessions,
    deployment_focus,
    COALESCE(app_build_focus, 0) AS app_build_focus,
    COALESCE(design_focus, 0) AS design_focus,
    COALESCE(AI_focus, 0) AS AI_focus,
    COALESCE(code_export_focus, 0) AS code_export_focus,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users 
FROM adora
WHERE persona = 'Founder'
    AND total_successful_deployments > 0 AND total_failed_deployments = 0
    AND total_sessions <= 4
GROUP BY 
     persona,
    total_sessions,
    deployment_focus,
    app_build_focus,
    design_focus,
    AI_focus,
    code_export_focus
ORDER BY total_users DESC;


-- How many deployments per session?
SELECT
    persona,
    total_sessions,
  CASE
        WHEN total_deployments BETWEEN 1 AND 5 THEN '1-5'
        WHEN total_deployments BETWEEN 6 AND 10 THEN '6-10'
        WHEN total_deployments BETWEEN 11 AND 15 THEN '11-15'
        WHEN total_deployments BETWEEN 16 AND 20 THEN '16-20'
        ELSE '20+'
    END AS total_deployments,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/ COUNT(user_id), 4) AS churn_rate
FROM adora
WHERE persona = 'Founder'
    AND total_sessions <= 2
    AND total_successful_deployments > 0 AND total_failed_deployments = 0
GROUP BY persona, total_sessions,
      CASE
        WHEN total_deployments BETWEEN 1 AND 5 THEN '1-5'
        WHEN total_deployments BETWEEN 6 AND 10 THEN '6-10'
        WHEN total_deployments BETWEEN 11 AND 15 THEN '11-15'
        WHEN total_deployments BETWEEN 16 AND 20 THEN '16-20'
        ELSE '20+'
    END

-- How many deployments do they do?
SELECT 
    persona,
    usage_intensity,
    CASE
        WHEN total_deployments BETWEEN 1 AND 5 THEN '1-5'
        WHEN total_deployments BETWEEN 6 AND 10 THEN '6-10'
        WHEN total_deployments BETWEEN 11 AND 15 THEN '11-15'
        WHEN total_deployments BETWEEN 16 AND 20 THEN '16-20'
        ELSE '20+'
    END AS deployment_count,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/ COUNT(user_id), 4) AS churn_rate
FROM adora
WHERE persona = 'Founder'
    AND total_successful_deployments > 0 AND total_failed_deployments = 0
GROUP BY persona, usage_intensity,
    CASE
        WHEN total_deployments BETWEEN 1 AND 5 THEN '1-5'
        WHEN total_deployments BETWEEN 6 AND 10 THEN '6-10'
        WHEN total_deployments BETWEEN 11 AND 15 THEN '11-15'
        WHEN total_deployments BETWEEN 16 AND 20 THEN '16-20'
        ELSE '20+'
    END
ORDER BY total_users DESC; 

-- Write a query showing the preference of github and supabase and their churn numbers
SELECT
    a.persona,
    f.feature_usage,
    COUNT(f.user_id) AS total_users,
    SUM(CASE WHEN a.churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN a.churned_flag = 1 THEN 1 ELSE 0 END)/ COUNT(a.user_id), 4) AS churn_rate
FROM adora a 
LEFT JOIN feature_usage f
    ON a.user_id = f.user_id
WHERE a.persona = 'Founder'
    AND a.total_successful_deployments > 0 AND a.total_failed_deployments = 0
    AND f.feature_usage IN ('GitHub', 'Supabase')
GROUP BY a.persona, f.feature_usage
ORDER BY total_users DESC;

-- How many users are both either GitHub or Supabase and how many are using both?
-- Step 1: Get a list of users who used them
WITH feature AS (
    SELECT
        a.user_id,
        a.persona,
        a.churned_flag,
        MAX(CASE WHEN f.feature_usage = 'GitHub' THEN 1 ELSE 0 END) AS github_use,
        MAX(CASE WHEN f.feature_usage = 'Supabase' THEN 1 ELSE 0 END) AS supabase_use
    FROM adora a
    LEFT JOIN feature_usage f
        ON a.user_id = f.user_id
    WHERE a.persona = 'Founder'
        AND a.total_successful_deployments > 0 AND a.total_failed_deployments = 0
    GROUP BY a.user_id, a.persona, a.churned_flag
)
SELECT
    persona,
    CASE
        WHEN github_use > 0 AND supabase_use = 0 THEN 'GitHub only'
        WHEN supabase_use > 0 AND github_use = 0 THEN 'Supabase only'
        WHEN github_use > 0 AND supabase_use > 0 THEN 'Both'
    END AS feature_category,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/ COUNT(user_id), 4) AS churn_rate
FROM feature
GROUP BY
    persona, CASE
        WHEN github_use > 0 AND supabase_use = 0 THEN 'GitHub only'
        WHEN supabase_use > 0 AND github_use = 0 THEN 'Supabase only'
        WHEN github_use > 0 AND supabase_use > 0 THEN 'Both'
    END
ORDER BY total_users DESC;

-- What of the total sessions?
WITH feature AS (
    SELECT
        a.user_id,
        a.persona,
        a.total_sessions,
        a.churned_flag,
        MAX(CASE WHEN f.feature_usage = 'GitHub' THEN 1 ELSE 0 END) AS github_use,
        MAX(CASE WHEN f.feature_usage = 'Supabase' THEN 1 ELSE 0 END) AS supabase_use
    FROM adora a
    LEFT JOIN feature_usage f
        ON a.user_id = f.user_id
    WHERE a.persona = 'Founder'
        AND a.total_successful_deployments > 0 AND a.total_failed_deployments = 0
        AND a.total_sessions <= 4
    GROUP BY a.user_id, a.persona, a.total_sessions, a.churned_flag
)
SELECT
    persona,
    total_sessions,
    CASE
        WHEN github_use > 0 AND supabase_use = 0 THEN 'GitHub only'
        WHEN supabase_use > 0 AND github_use = 0 THEN 'Supabase only'
        WHEN github_use > 0 AND supabase_use > 0 THEN 'Both'
    END AS feature_category,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/ COUNT(user_id), 4) AS churn_rate
FROM feature
GROUP BY
    persona, total_sessions, 
    CASE
        WHEN github_use > 0 AND supabase_use = 0 THEN 'GitHub only'
        WHEN supabase_use > 0 AND github_use = 0 THEN 'Supabase only'
        WHEN github_use > 0 AND supabase_use > 0 THEN 'Both'
    END
ORDER BY total_users DESC;

-- Check the total deployments
WITH feature AS (
    SELECT
        a.user_id,
        a.persona,
        a.total_sessions,
        a.churned_flag,
        CASE
        WHEN total_deployments BETWEEN 1 AND 5 THEN '1-5'
        WHEN total_deployments BETWEEN 6 AND 10 THEN '6-10'
        WHEN total_deployments BETWEEN 11 AND 15 THEN '11-15'
        WHEN total_deployments BETWEEN 16 AND 20 THEN '16-20'
        ELSE '20+'
    END AS deployment_count,
        MAX(CASE WHEN f.feature_usage = 'GitHub' THEN 1 ELSE 0 END) AS github_use,
        MAX(CASE WHEN f.feature_usage = 'Supabase' THEN 1 ELSE 0 END) AS supabase_use
    FROM adora a
    LEFT JOIN feature_usage f
        ON a.user_id = f.user_id
    WHERE a.persona = 'Founder'
        AND a.total_successful_deployments > 0 AND a.total_failed_deployments = 0
        AND a.total_sessions <= 4
    GROUP BY a.user_id, a.persona, a.total_sessions, a.churned_flag,
        CASE
        WHEN total_deployments BETWEEN 1 AND 5 THEN '1-5'
        WHEN total_deployments BETWEEN 6 AND 10 THEN '6-10'
        WHEN total_deployments BETWEEN 11 AND 15 THEN '11-15'
        WHEN total_deployments BETWEEN 16 AND 20 THEN '16-20'
        ELSE '20+'
    END
)
SELECT
    persona,
    total_sessions,
    deployment_count,
    CASE
        WHEN github_use > 0 AND supabase_use = 0 THEN 'GitHub only'
        WHEN supabase_use > 0 AND github_use = 0 THEN 'Supabase only'
        WHEN github_use > 0 AND supabase_use > 0 THEN 'Both'
    END AS feature_category,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/ COUNT(user_id), 4) AS churn_rate
FROM feature
GROUP BY
    persona, total_sessions, deployment_count, 
    CASE
        WHEN github_use > 0 AND supabase_use = 0 THEN 'GitHub only'
        WHEN supabase_use > 0 AND github_use = 0 THEN 'Supabase only'
        WHEN github_use > 0 AND supabase_use > 0 THEN 'Both'
    END
ORDER BY total_users DESC;


-- Create a safe flag for the users based on deployment volume
WITH feature AS (
    SELECT
        a.user_id,
        a.persona,
        a.total_sessions,
        a.churned_flag,
         CASE
        WHEN total_deployments BETWEEN 1 AND 5 THEN 'Safe'
        WHEN total_deployments BETWEEN 6 AND 10 THEN 'Moderate Risk'
        ELSE 'High Risk'
    END AS safe_deployment_category,
        MAX(CASE WHEN f.feature_usage = 'GitHub' THEN 1 ELSE 0 END) AS github_use,
        MAX(CASE WHEN f.feature_usage = 'Supabase' THEN 1 ELSE 0 END) AS supabase_use
    FROM adora a
    LEFT JOIN feature_usage f
        ON a.user_id = f.user_id
    WHERE a.persona = 'Founder'
        AND a.total_successful_deployments > 0 AND a.total_failed_deployments = 0
        AND a.total_sessions <= 4
    GROUP BY a.user_id, a.persona, a.total_sessions, a.churned_flag,
        CASE
        WHEN total_deployments BETWEEN 1 AND 5 THEN 'Safe'
        WHEN total_deployments BETWEEN 6 AND 10 THEN 'Moderate Risk'
        ELSE 'High Risk'
    END
)
SELECT
    persona,
    total_sessions,
    safe_deployment_category,
    CASE
        WHEN github_use > 0 AND supabase_use = 0 THEN 'GitHub only'
        WHEN supabase_use > 0 AND github_use = 0 THEN 'Supabase only'
        WHEN github_use > 0 AND supabase_use > 0 THEN 'Both'
    END AS feature_category,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/ COUNT(user_id), 4) AS churn_rate
FROM feature
GROUP BY
    persona, total_sessions, safe_deployment_category, 
    CASE
        WHEN github_use > 0 AND supabase_use = 0 THEN 'GitHub only'
        WHEN supabase_use > 0 AND github_use = 0 THEN 'Supabase only'
        WHEN github_use > 0 AND supabase_use > 0 THEN 'Both'
    END
ORDER BY total_users DESC;

SELECT
    total_deployments,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM adora
WHERE persona = 'Founder'
    AND total_successful_deployments > 0 AND total_failed_deployments  = 0
    AND total_sessions = 1
GROUP BY total_deployments
ORDER BY total_users DESC;

-- If a user used the app just once, at what point does the number of deployments become a risk factor?
SELECT
      CASE
        WHEN total_deployments BETWEEN 1 AND 5 THEN 'Safe'
        WHEN total_deployments BETWEEN 6 AND 10 THEN 'Moderate Risk'
        ELSE 'High Risk'
    END AS safe_deployment_category,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM adora
WHERE persona = 'Founder'
    AND total_successful_deployments > 0 AND total_failed_deployments  = 0
    AND total_sessions = 1
GROUP BY    
     CASE
        WHEN total_deployments BETWEEN 1 AND 5 THEN 'Safe'
        WHEN total_deployments BETWEEN 6 AND 10 THEN 'Moderate Risk'
        ELSE 'High Risk'
    END
ORDER BY total_users DESC;

-- Add usage_intensity
SELECT
      CASE
        WHEN total_deployments BETWEEN 1 AND 5 THEN 'Safe'
        WHEN total_deployments BETWEEN 6 AND 10 THEN 'Moderate Risk'
        ELSE 'High Risk'
    END AS safe_deployment_category,
    usage_intensity,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM adora
WHERE persona = 'Founder'
    AND total_successful_deployments > 0 AND total_failed_deployments  = 0
    AND total_sessions = 1
GROUP BY usage_intensity,  
     CASE
        WHEN total_deployments BETWEEN 1 AND 5 THEN 'Safe'
        WHEN total_deployments BETWEEN 6 AND 10 THEN 'Moderate Risk'
        ELSE 'High Risk'
    END
ORDER BY total_users DESC;


-- What is the feature usage like across all the sections
SELECT
    persona,
    total_sessions,
    usage_intensity,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/ COUNT(user_id), 4) AS churn_rate
FROM adora
WHERE persona = 'Founder'
    AND total_successful_deployments > 0 AND total_failed_deployments = 0
GROUP BY persona, total_sessions, usage_intensity
ORDER BY total_users DESC;



-- Look at founders with no successful deployments
SELECT
    persona,
    usage_intensity,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM adora
WHERE persona = 'Founder'
    AND total_successful_deployments = 0 AND total_failed_deployments > 0
GROUP BY persona, usage_intensity 
ORDER BY total_users DESC;

-- Look at the friction and experience level
SELECT
    persona,
    friction_level,
    experience_level,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM adora
WHERE persona = 'Founder'
    AND total_successful_deployments = 0 AND total_failed_deployments > 0
    AND usage_intensity = 'Heavy User'
GROUP BY persona, friction_level, experience_level
ORDER BY total_users DESC;

-- Do some grouping
SELECT
    persona,
    CASE
        WHEN experience_level IN ('Flawless', 'Mostly Successful') THEN 'Successful'
        WHEN experience_level IN ('High Friction', 'Failed') THEN 'Failed'
        ELSE 'Mixed'
    END AS experience_level,
    CASE
        WHEN friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
        ELSE 'Low Friction'
    END AS friction_level,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM adora
WHERE persona = 'Founder'
    AND total_successful_deployments = 0 AND total_failed_deployments > 0
    AND usage_intensity = 'Heavy User'
GROUP BY persona,
    CASE
        WHEN experience_level IN ('Flawless', 'Mostly Successful') THEN 'Successful'
        WHEN experience_level IN ('High Friction', 'Failed') THEN 'Failed'
        ELSE 'Mixed'
    END,
    CASE
        WHEN friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
        ELSE 'Low Friction'
    END
HAVING COUNT(user_id) > 1
ORDER BY total_users DESC;

-- Which one is more complex? GitHub or Supabase?
WITH features AS (
    SELECT
        a.user_id,
        a.persona,
        a.churned_flag,
        CASE
            WHEN a.friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
            ELSE 'Low Friction'
        END AS friction_level,
        MAX(CASE WHEN f.feature_usage = 'GitHub' THEN 1 ELSE 0 END) AS github_use,
        MAX(CASE WHEN f.feature_usage = 'Supabase' THEN 1 ELSE 0 END) AS supabase_use
    FROM adora a
        LEFT JOIN feature_usage f
            ON a.user_id = f.user_id
    WHERE a.persona = 'Founder'
        AND a.total_successful_deployments = 0 AND a.total_failed_deployments > 0
        AND a.usage_intensity = 'Heavy User'
    -- AND friction_level IN ('High Friction', 'System Breakdown')
    GROUP BY a.user_id, a.persona, a.churned_flag,
         CASE
            WHEN a.friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
            ELSE 'Low Friction'
        END        
)
SELECT
    persona,
    friction_level,
    CASE
        WHEN github_use > 0 AND supabase_use = 0 THEN 'GitHub only'
        WHEN supabase_use > 0 AND github_use = 0 THEN 'Supabase only'
        WHEN github_use > 0 AND supabase_use > 0 THEN 'Both'
    END AS feature_category,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM features
GROUP BY persona, friction_level,
     CASE
        WHEN github_use > 0 AND supabase_use = 0 THEN 'GitHub only'
        WHEN supabase_use > 0 AND github_use = 0 THEN 'Supabase only'
        WHEN github_use > 0 AND supabase_use > 0 THEN 'Both'
    END
ORDER BY total_users DESC;


-- Next step: Look at the relationship betweeen total sessions and churn for founders who couldn't churn
SELECT
    persona,
    total_sessions,
    CASE
        WHEN friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
        ELSE 'Low Friction'
    END AS friction_level,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM adora
WHERE persona = 'Founder'
    AND usage_intensity = 'Heavy User'
    AND total_successful_deployments = 0
    AND total_failed_deployments > 0
GROUP BY persona, total_sessions,
    CASE
        WHEN friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
        ELSE 'Low Friction'
    END
ORDER BY total_users DESC;

-- Next step: Look at the relationship between total sessions and deployment count for these founders who couldn't deploy
SELECT
    persona,
    total_sessions,
    CASE
        WHEN friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
        ELSE 'Low Friction'
    END AS friction_level,
    total_deployments,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM adora
WHERE persona = 'Founder'
    AND usage_intensity = 'Heavy User'
    AND total_successful_deployments = 0
    AND total_failed_deployments > 0
GROUP BY persona, total_sessions, total_deployments,
    CASE
        WHEN friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
        ELSE 'Low Friction'
    END
ORDER BY total_users DESC;

-- At what point do founders who couldn't deploy successfully become at risk of being churned?
SELECT
    persona,
    CASE
        WHEN friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
        ELSE 'Low Friction'
    END AS friction_level,
    total_sessions,
    CASE
        WHEN total_deployments BETWEEN 1 AND 5 THEN 'Safe'
        WHEN total_deployments BETWEEN 6 AND 10 THEN 'Moderate Risk'
        ELSE 'High Risk'
    END AS safe_deployment_category,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM adora
    WHERE persona = 'Founder'
    AND usage_intensity = 'Heavy User'
    AND total_successful_deployments = 0
    AND total_failed_deployments > 0
GROUP BY persona, total_sessions,
    CASE
        WHEN friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
        ELSE 'Low Friction'
    END,
    CASE
        WHEN total_deployments BETWEEN 1 AND 5 THEN 'Safe'
        WHEN total_deployments BETWEEN 6 AND 10 THEN 'Moderate Risk'
        ELSE 'High Risk'
    END
ORDER BY total_users DESC;

-- Now add GitHub and Supabase into the mix
WITH feature AS (
    SELECT
        a.user_id,
        a.persona,
        a.churned_flag,
        a.total_sessions,
        a.total_deployments,
        CASE
            WHEN a.friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
            ELSE 'Low Friction'
        END AS friction_level,
        MAX(CASE WHEN f.feature_usage = 'GitHub' THEN 1 ELSE 0 END) AS github_use,
        MAX(CASE WHEN f.feature_usage = 'Supabase' THEN 1 ELSE 0 END) AS supabase_use
    FROM adora a
    LEFT JOIN feature_usage f
        ON a.user_id = f.user_id
    WHERE a.persona = 'Founder'
        AND a.total_successful_deployments = 0
        AND a.total_failed_deployments > 0
        AND a.usage_intensity = 'Heavy User'
    GROUP BY a.user_id, a.total_sessions, a.persona, a.total_deployments, a.churned_flag,
        CASE
            WHEN a.friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
            ELSE 'Low Friction'
        END
)
SELECT
    persona,
    friction_level,
    total_sessions,
    CASE
        WHEN total_deployments BETWEEN 1 AND 5 THEN 'Safe'
        WHEN total_deployments BETWEEN 6 AND 10 THEN 'Moderate Risk'
        ELSE 'High Risk'
    END AS safe_deployment_category,
    CASE
        WHEN github_use > 0 AND supabase_use = 0 THEN 'GitHub only'
        WHEN github_use = 0 AND supabase_use > 0 THEN 'Supabase only'
        WHEN github_use > 0 AND supabase_use > 0 THEN 'Both'
    END AS feature_category,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM feature
GROUP BY persona, friction_level, total_sessions,
    CASE
        WHEN github_use > 0 AND supabase_use = 0 THEN 'GitHub only'
        WHEN github_use = 0 AND supabase_use > 0 THEN 'Supabase only'
        WHEN github_use > 0 AND supabase_use > 0 THEN 'Both'
    END,
    CASE
        WHEN total_deployments BETWEEN 1 AND 5 THEN 'Safe'
        WHEN total_deployments BETWEEN 6 AND 10 THEN 'Moderate Risk'
        ELSE 'High Risk'
    END
ORDER BY total_users DESC;

-- Put in a churn risk
WITH feature AS (
    SELECT
        a.user_id,
        a.persona,
        a.churned_flag,
        a.total_sessions,
        a.total_deployments,
        CASE
            WHEN a.friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
            ELSE 'Low Friction'
        END AS friction_level,
        MAX(CASE WHEN f.feature_usage = 'GitHub' THEN 1 ELSE 0 END) AS github_use,
        MAX(CASE WHEN f.feature_usage = 'Supabase' THEN 1 ELSE 0 END) AS supabase_use
    FROM adora a
    LEFT JOIN feature_usage f
        ON a.user_id = f.user_id
    WHERE a.persona = 'Founder'
        AND a.total_successful_deployments = 0
        AND a.total_failed_deployments > 0
        AND a.usage_intensity = 'Heavy User'
    GROUP BY a.user_id, a.total_sessions, a.persona, a.total_deployments, a.churned_flag,
        CASE
            WHEN a.friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
            ELSE 'Low Friction'
        END
)
SELECT
    persona,
    friction_level,
    total_sessions,
    CASE
        WHEN total_deployments BETWEEN 1 AND 5 THEN 'Safe'
        WHEN total_deployments BETWEEN 6 AND 10 THEN 'Moderate Risk'
        ELSE 'High Risk'
    END AS safe_deployment_category,
    CASE
        WHEN github_use > 0 AND supabase_use = 0 THEN 'GitHub only'
        WHEN github_use = 0 AND supabase_use > 0 THEN 'Supabase only'
        WHEN github_use > 0 AND supabase_use > 0 THEN 'Both'
    END AS feature_category,
    -- Churn risk based on friction level, session, and deployment category
    CASE
        -- High risk
        WHEN friction_level = 'High Friction'
            AND total_sessions <= 3
            AND total_deployments <= 10 
            THEN 'High'
        WHEN (friction_level = 'High Friction' AND total_sessions <= 3 AND total_deployments <= 5)
            OR (friction_level = 'Low Friction' AND total_sessions <= 2 AND total_deployments >= 6)
            THEN 'Moderate'
        ELSE 'Low'
    END AS churn_risk,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM feature
GROUP BY persona, friction_level, total_sessions,
    CASE
        WHEN github_use > 0 AND supabase_use = 0 THEN 'GitHub only'
        WHEN github_use = 0 AND supabase_use > 0 THEN 'Supabase only'
        WHEN github_use > 0 AND supabase_use > 0 THEN 'Both'
    END,
    CASE
        WHEN total_deployments BETWEEN 1 AND 5 THEN 'Safe'
        WHEN total_deployments BETWEEN 6 AND 10 THEN 'Moderate Risk'
        ELSE 'High Risk'
    END,
       CASE
        -- High risk
        WHEN friction_level = 'High Friction'
            AND total_sessions <= 3
            AND total_deployments <= 10 
            THEN 'High'
        WHEN (friction_level = 'High Friction' AND total_sessions <= 3 AND total_deployments <= 5)
            OR (friction_level = 'Low Friction' AND total_sessions <= 2 AND total_deployments >= 6)
            THEN 'Moderate'
        ELSE 'Low'
    END


-- Look at founders with mixed records
SELECT
    persona,
    usage_intensity,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/ COUNT(user_id), 4) AS churn_rate
FROM adora
WHERE persona = 'Founder'
    AND total_successful_deployments > 0 AND total_failed_deployments > 0
GROUP BY persona, usage_intensity
ORDER BY total_users DESC;

-- Next step: friction and experience level
SELECT
    persona,
    CASE
        WHEN friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
        ELSE 'Low Friction'
    END AS friction_level,
    CASE
        WHEN experience_level IN ('Flawless', 'Mostly Successful') THEN 'Successful'
        WHEN experience_level IN ('High Friction', 'Failed') THEN 'Failed'
        ELSE 'Mixed'
    END AS experience_level,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM adora
WHERE persona = 'Founder'
    AND usage_intensity = 'Heavy User'
    AND total_successful_deployments > 0 AND total_failed_deployments > 0
GROUP BY persona,
     CASE
        WHEN friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
        ELSE 'Low Friction'
    END,
    CASE
        WHEN experience_level IN ('Flawless', 'Mostly Successful') THEN 'Successful'
        WHEN experience_level IN ('High Friction', 'Failed') THEN 'Failed'
        ELSE 'Mixed'
    END
ORDER BY total_users DESC;

-- Add total sessions
SELECT
    persona,
    CASE
        WHEN friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
        ELSE 'Low Friction'
    END AS friction_level,
    CASE
        WHEN experience_level IN ('Flawless', 'Mostly Successful') THEN 'Successful'
        WHEN experience_level IN ('High Friction', 'Failed') THEN 'Failed'
        ELSE 'Mixed'
    END AS experience_level,
    total_sessions,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM adora
WHERE persona = 'Founder'
    AND usage_intensity = 'Heavy User'
    AND total_successful_deployments > 0 AND total_failed_deployments > 0
GROUP BY persona, total_sessions,
     CASE
        WHEN friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
        ELSE 'Low Friction'
    END,
    CASE
        WHEN experience_level IN ('Flawless', 'Mostly Successful') THEN 'Successful'
        WHEN experience_level IN ('High Friction', 'Failed') THEN 'Failed'
        ELSE 'Mixed'
    END
ORDER BY total_users DESC;

-- What of their deployments?
SELECT
    persona,
    CASE
        WHEN friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
        ELSE 'Low Friction'
    END AS friction_level,
    CASE
        WHEN experience_level IN ('Flawless', 'Mostly Successful') THEN 'Successful'
        WHEN experience_level IN ('High Friction', 'Failed') THEN 'Failed'
        ELSE 'Mixed'
    END AS experience_level,
    total_sessions,
    total_deployments,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM adora
WHERE persona = 'Founder'
    AND usage_intensity = 'Heavy User'
    AND total_successful_deployments > 0 AND total_failed_deployments > 0
GROUP BY persona, total_sessions, total_deployments,
     CASE
        WHEN friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
        ELSE 'Low Friction'
    END,
    CASE
        WHEN experience_level IN ('Flawless', 'Mostly Successful') THEN 'Successful'
        WHEN experience_level IN ('High Friction', 'Failed') THEN 'Failed'
        ELSE 'Mixed'
    END
ORDER BY total_users DESC;


-- Does GitHub and Supabase affect churn for these founders?
WITH features AS (
    SELECT
    a.user_id,
    a.persona,
    a.churned_flag,
    a.total_sessions,
    a.total_deployments,
     CASE
        WHEN a.friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
        ELSE 'Low Friction'
    END AS friction_level,
    MAX(CASE WHEN f.feature_usage = 'GitHub' THEN 1 ELSE 0 END) AS github_use,
    MAX(CASE WHEN f.feature_usage = 'Supabase' THEN 1 ELSE 0 END) AS supabase_use
    FROM adora a
    LEFT JOIN feature_usage f
        ON a.user_id = f.user_id
    WHERE a.persona = 'Founder'
        AND a.usage_intensity = 'Heavy User'
        AND a.total_successful_deployments > 0 AND total_failed_deployments > 0
    GROUP BY a.user_id, a.persona, a.churned_flag, a.total_sessions, a.total_deployments,
        CASE
        WHEN a.friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
        ELSE 'Low Friction'
    END
)
SELECT
    persona,
    friction_level,
        CASE
        WHEN total_deployments BETWEEN 1 AND 5 THEN 'Safe'
        WHEN total_deployments BETWEEN 6 AND 10 THEN 'Moderate Risk'
        ELSE 'High Risk'
    END AS safe_deployment_category,
    CASE
        WHEN github_use > 0 AND supabase_use = 0 THEN 'GitHub only'
        WHEN github_use = 0 AND supabase_use > 0 THEN 'Supabase only'
        WHEN github_use > 0 AND supabase_use > 0 THEN 'Both'
    END AS feature_category,
    total_sessions,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM features
GROUP BY persona, friction_level, total_sessions,
    CASE
        WHEN total_deployments BETWEEN 1 AND 5 THEN 'Safe'
        WHEN total_deployments BETWEEN 6 AND 10 THEN 'Moderate Risk'
        ELSE 'High Risk'
    END,
    CASE
        WHEN github_use > 0 AND supabase_use = 0 THEN 'GitHub only'
        WHEN github_use = 0 AND supabase_use > 0 THEN 'Supabase only'
        WHEN github_use > 0 AND supabase_use > 0 THEN 'Both'
    END
ORDER BY total_users DESC;

-- Set thresholds for deployments at friction level over sessions
SELECT
    persona,
    CASE
        WHEN friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
        ELSE 'Low Friction'
    END AS friction_level,
    total_sessions,
    CASE
        WHEN total_deployments BETWEEN 1 AND 5 THEN 'Safe'
        WHEN total_deployments BETWEEN 6 AND 10 THEN 'Moderate Risk'
        ELSE 'High Risk'
    END AS safe_deployment_category,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM adora
WHERE persona = 'Founder'
    AND usage_intensity = 'Heavy User'
    AND total_successful_deployments > 0 AND total_failed_deployments > 0
GROUP BY persona, total_sessions,
    CASE
        WHEN friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
        ELSE 'Low Friction'
    END,
    CASE
        WHEN total_deployments BETWEEN 1 AND 5 THEN 'Safe'
        WHEN total_deployments BETWEEN 6 AND 10 THEN 'Moderate Risk'
        ELSE 'High Risk'
    END 
ORDER BY total_users DESC;

-- With the analysis on the founders is completed.

-- Next step: Analyse the app builders
SELECT 
    persona,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id),4) AS churn_rate
FROM adora
WHERE persona = 'App Builder'
GROUP BY persona

-- Look at their engagement activity
SELECT
    persona,
    app_build_focus,
    deployment_focus,
    AI_focus,
    design_focus,
    code_export_focus,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 2) AS churn_rate
FROM adora
WHERE persona = 'App Builder'
GROUP BY persona, app_build_focus, deployment_focus, AI_focus, design_focus, code_export_focus
ORDER BY total_users DESC;

-- Now look into their usage intensity
SELECT
    persona,
    usage_intensity,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM adora
WHERE persona = 'App Builder'
GROUP BY persona, usage_intensity
ORDER BY total_users DESC;


-- Look at balanced users
SELECT
    persona,
    CASE
        WHEN experience_level IN ('Flawless', 'Mostly Successful') THEN 'Successful'
        WHEN experience_level IN ('High Friction', 'Failed') THEN 'Failed'
        ELSE 'Mixed'
    END AS experience_level,
    CASE
        WHEN friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
        ELSE 'Low Friction'
    END AS friction_level,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM adora
WHERE persona = 'App Builder'
    AND usage_intensity = 'Balanced User'
    AND experience_level IS NOT NULL
    AND friction_level IS NOT NULL
GROUP BY persona,
    CASE
        WHEN experience_level IN ('Flawless', 'Mostly Successful') THEN 'Successful'
        WHEN experience_level IN ('High Friction', 'Failed') THEN 'Failed'
        ELSE 'Mixed'
    END,
    CASE
        WHEN friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
        ELSE 'Low Friction'
    END
ORDER BY total_users DESC;

SELECT DISTINCT total_sessions FROM adora where persona = 'App Builder'

-- One more thing: Band sessions 
SELECT
    persona,
    CASE
        WHEN total_successful_app_builds > 0 AND total_failed_app_builds = 0 THEN 'Successful App Builders'
        WHEN total_successful_app_builds = 0 AND total_failed_app_builds > 0 THEN 'Failed App Builders'
        WHEN total_successful_app_builds > 0 AND total_failed_app_builds > 0 THEN 'Mixed'
    END AS app_builder_status,
    CASE
        WHEN total_sessions BETWEEN 1 AND 2 THEN 'Early Sessions'
        WHEN total_sessions BETWEEN 3 AND 5 THEN 'Mid Sessions'
        WHEN total_sessions > 5 THEN 'Deeper adopters'
    END AS session_status,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM adora
WHERE persona = 'App Builder'
GROUP BY persona,
    CASE
        WHEN total_successful_app_builds > 0 AND total_failed_app_builds = 0 THEN 'Successful App Builders'
        WHEN total_successful_app_builds = 0 AND total_failed_app_builds > 0 THEN 'Failed App Builders'
        WHEN total_successful_app_builds > 0 AND total_failed_app_builds > 0 THEN 'Mixed'
    END,
    CASE
        WHEN total_sessions BETWEEN 1 AND 2 THEN 'Early Sessions'
        WHEN total_sessions BETWEEN 3 AND 5 THEN 'Mid Sessions'
        WHEN total_sessions > 5 THEN 'Deeper adopters'
    END 
ORDER BY total_users DESC;

-- 
SELECT
    persona,
    CASE
        WHEN total_successful_app_builds > 0 AND total_failed_app_builds = 0 THEN 'Successful App Builders'
        WHEN total_successful_app_builds = 0 AND total_failed_app_builds > 0 THEN 'Failed App Builders'
        WHEN total_successful_app_builds > 0 AND total_failed_app_builds > 0 THEN 'Mixed'
    END AS app_builder_status,
    CASE
        WHEN total_sessions BETWEEN 1 AND 2 THEN 'Early Sessions'
        WHEN total_sessions BETWEEN 3 AND 5 THEN 'Mid Sessions'
        WHEN total_sessions > 5 THEN 'Deeper adopters'
    END AS session_status,
    total_app_build_attempts,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM adora
WHERE persona = 'App Builder'
GROUP BY persona, total_app_build_attempts,
    CASE
        WHEN total_successful_app_builds > 0 AND total_failed_app_builds = 0 THEN 'Successful App Builders'
        WHEN total_successful_app_builds = 0 AND total_failed_app_builds > 0 THEN 'Failed App Builders'
        WHEN total_successful_app_builds > 0 AND total_failed_app_builds > 0 THEN 'Mixed'
    END,
    CASE
        WHEN total_sessions BETWEEN 1 AND 2 THEN 'Early Sessions'
        WHEN total_sessions BETWEEN 3 AND 5 THEN 'Mid Sessions'
        WHEN total_sessions > 5 THEN 'Deeper adopters'
    END 
ORDER BY total_users DESC;

-- Check support tickets
SELECT
    a.persona,
    CASE
        WHEN a.total_successful_app_builds > 0 AND a.total_failed_app_builds = 0 THEN 'Successful App Builders'
        WHEN a.total_successful_app_builds = 0 AND a.total_failed_app_builds > 0 THEN 'Failed App Builders'
        WHEN a.total_successful_app_builds > 0 AND a.total_failed_app_builds > 0 THEN 'Mixed'
    END AS app_builder_status,
    COALESCE(t.issue_type, 'N/A') AS issue_type,
    COUNT(a.user_id) AS total_users,
    SUM(CASE WHEN a.churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN a.churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(a.user_id), 4) AS churn_rate
FROM adora a
LEFT JOIN tickets t
    ON a.user_id = t.user_id
WHERE a.persona = 'App Builder'
    AND a.total_sessions BETWEEN 1 AND 2
GROUP BY a.persona, t.issue_type,
    CASE
        WHEN a.total_successful_app_builds > 0 AND a.total_failed_app_builds = 0 THEN 'Successful App Builders'
        WHEN a.total_successful_app_builds = 0 AND a.total_failed_app_builds > 0 THEN 'Failed App Builders'
        WHEN a.total_successful_app_builds > 0 AND a.total_failed_app_builds > 0 THEN 'Mixed'
    END
ORDER BY total_users DESC;

-- Try to divide the app builders into successful and failed users
SELECT
    persona,
    usage_intensity,
    CASE
        WHEN total_successful_app_builds > 0 AND total_failed_app_builds = 0 THEN 'Successful App Builders'
        WHEN total_successful_app_builds = 0 AND total_failed_app_builds > 0 THEN 'Failed App Builders'
        WHEN total_successful_app_builds > 0 AND total_failed_app_builds > 0 THEN 'Mixed Performers'
    END AS app_performance,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM adora
WHERE persona = 'App Builder'
GROUP BY persona, usage_intensity,
       CASE
        WHEN total_successful_app_builds > 0 AND total_failed_app_builds = 0 THEN 'Successful App Builders'
        WHEN total_successful_app_builds = 0 AND total_failed_app_builds > 0 THEN 'Failed App Builders'
        WHEN total_successful_app_builds > 0 AND total_failed_app_builds > 0 THEN 'Mixed Performers'
    END
ORDER BY total_users DESC; 

-- Look to successful, balanced users
SELECT
    persona,
    total_sessions,
    total_app_build_attempts,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM adora
WHERE persona = 'App Builder'
    AND usage_intensity = 'Balanced User'
    AND total_successful_app_builds > 0 AND total_failed_app_builds = 0
GROUP BY persona, total_sessions, total_app_build_attempts
ORDER BY total_users DESC;

-- Look to failed, balanced users
SELECT
    persona,
    total_sessions,
    total_app_build_attempts,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM adora
WHERE persona = 'App Builder'
    AND usage_intensity = 'Balanced User'
    AND total_successful_app_builds = 0 AND total_failed_app_builds > 0
GROUP BY persona, total_sessions, total_app_build_attempts
ORDER BY total_users DESC;

-- Look at users based on their total sessions and app builds
SELECT
    persona,
    total_sessions,
    total_app_build_attempts,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM adora
WHERE persona = 'App Builder'
GROUP BY persona, total_sessions, total_app_build_attempts

-- Do it again for successful and failed app builders
SELECT
    persona,
    total_sessions,
    total_app_build_attempts,
    CASE
        WHEN total_successful_app_builds > 0 And total_failed_app_builds = 0 THEN 'Successful App Builders'
        WHEN total_successful_app_builds = 0 AND total_failed_app_builds > 0 THEN 'Failed App Builders'
        WHEN total_successful_app_builds > 0 AND total_failed_app_builds > 0 THEN 'Mixed'
    END AS app_builder_status,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM adora
WHERE persona = 'App Builder'
GROUP BY persona, total_sessions, total_app_build_attempts,
    CASE
        WHEN total_successful_app_builds > 0 And total_failed_app_builds = 0 THEN 'Successful App Builders'
        WHEN total_successful_app_builds = 0 AND total_failed_app_builds > 0 THEN 'Failed App Builders'
        WHEN total_successful_app_builds > 0 AND total_failed_app_builds > 0 THEN 'Mixed'
    END
ORDER BY total_users DESC;

-- Do it again for successful and failed app builders and look at usage_intensity
SELECT
    persona,
    total_sessions,
    total_app_build_attempts,
    usage_intensity,
    CASE
        WHEN total_successful_app_builds > 0 And total_failed_app_builds = 0 THEN 'Successful App Builders'
        WHEN total_successful_app_builds = 0 AND total_failed_app_builds > 0 THEN 'Failed App Builders'
        WHEN total_successful_app_builds > 0 AND total_failed_app_builds > 0 THEN 'Mixed'
    END AS app_builder_status,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM adora
WHERE persona = 'App Builder'
GROUP BY persona, total_sessions, total_app_build_attempts, usage_intensity,
    CASE
        WHEN total_successful_app_builds > 0 And total_failed_app_builds = 0 THEN 'Successful App Builders'
        WHEN total_successful_app_builds = 0 AND total_failed_app_builds > 0 THEN 'Failed App Builders'
        WHEN total_successful_app_builds > 0 AND total_failed_app_builds > 0 THEN 'Mixed'
    END
ORDER BY total_users DESC;

SELECT
    persona,
    total_sessions,
    total_app_build_attempts,
    CASE
        WHEN friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
        ELSE 'Low Friction'
    END AS friction_level,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM adora
WHERE persona = 'App Builder'
    AND usage_intensity = 'Balanced User'
    AND friction_level IS NOT NULL
    AND total_successful_app_builds = 0 AND total_failed_app_builds > 0 
GROUP BY persona, total_sessions, total_app_build_attempts,
    CASE
        WHEN friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
        ELSE 'Low Friction'
    END
ORDER BY total_users DESC;

--Analyse the designers
SELECT
    persona,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM adora
WHERE persona = 'Designer'
GROUP BY persona
ORDER BY total_users DESC;

-- Look at the usage_intensity
SELECT
    persona,
    usage_intensity,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM adora
WHERE persona = 'Designer'
GROUP BY persona, usage_intensity
ORDER BY total_users DESC;

-- Divide into designer performance
SELECT
    persona,
    CASE
        WHEN total_successful_designs > 0 AND total_failed_designs = 0 THEN 'Successful Designers'
        WHEN total_successful_designs = 0 AND total_failed_designs > 0 THEN 'Failed Designers'
        WHEN total_successful_designs > 0 AND total_failed_designs > 0 THEN 'Mixed Performers'
    END AS designer_performance,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id),4) AS churn_rate
FROM adora
WHERE persona = 'Designer'
GROUP BY 
 persona,
    CASE
        WHEN total_successful_designs > 0 AND total_failed_designs = 0 THEN 'Successful Designers'
        WHEN total_successful_designs = 0 AND total_failed_designs > 0 THEN 'Failed Designers'
        WHEN total_successful_designs > 0 AND total_failed_designs > 0 THEN 'Mixed Performers'
    END
ORDER BY total_users DESC;

-- If successful designers have a higher churn rate, what's the problem?
SELECT
    persona,
    total_sessions,
    usage_intensity,
    total_designs,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM adora
WHERE persona = 'Designer'
    AND total_successful_designs > 0 AND total_failed_designs = 0
GROUP BY persona, total_sessions, usage_intensity, total_designs
ORDER BY total_users DESC;



WITH designs AS (
    SELECT
        a.user_id,
        a.persona,
        MAX(CASE WHEN f.feature_usage = 'Theme Editor' THEN 1 ELSE 0 END) AS theme_editor_use,
        MAX(CASE WHEN f.feature_usage = 'Figma Import' THEN 1 ELSE 0 END) AS figma_import_use,
        a.churned_flag
    FROM adora a
    LEFT JOIN feature_usage f
        ON a.user_id = f.user_id
    WHERE a.persona = 'Designer'
        AND a.total_successful_designs > 0 AND a.total_failed_designs = 0
    GROUP BY a.user_id, a.persona, a.churned_flag
)
SELECT
    persona,
    CASE
        WHEN figma_import_use > 0 AND theme_editor_use = 0 THEN 'Figma Designers'
        WHEN figma_import_use = 0 AND theme_editor_use > 0 THEN 'Theme Editor Designers'
        WHEN figma_import_use > 0 AND theme_editor_use > 0 THEN 'Both'
    END AS designer_category,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM designs
GROUP BY persona,
    CASE
        WHEN figma_import_use > 0 AND theme_editor_use = 0 THEN 'Figma Designers'
        WHEN figma_import_use = 0 AND theme_editor_use > 0 THEN 'Theme Editor Designers'
        WHEN figma_import_use > 0 AND theme_editor_use > 0 THEN 'Both'
    END
ORDER BY total_users DESC;

-- One more thing: Look at the usage intensity
SELECT
    persona,
    usage_intensity,
    total_sessions,
    total_designs,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM adora
WHERE persona = 'Designer'
    AND total_successful_designs > 0 AND total_failed_designs = 0
GROUP BY persona, usage_intensity, total_sessions, total_designs
ORDER BY total_users DESC;

-- Do successful designers use other tools?
SELECT
    persona,
    design_focus,
    AI_focus,
    code_export_focus,
    app_build_focus,
    deployment_focus,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM adora
WHERE persona = 'Designer'
    AND total_successful_designs > 0 AND total_failed_designs = 0
GROUP BY persona, design_focus, AI_focus, code_export_focus, app_build_focus, deployment_focus
ORDER BY total_users DESC;


-- Check onboarding
SELECT
    persona,
    onboarding_status,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM adora
WHERE persona = 'Designer'
    AND total_successful_designs > 0 AND total_failed_designs = 0
GROUP BY persona, onboarding_status
ORDER BY total_users DESC; 

-- What of support_contact?
SELECT
    persona,
    COALESCE(support_contact_category, 'No Help') AS support_contact_category,
     COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM adora 
WHERE persona = 'Designer'
    AND total_successful_designs > 0 AND total_failed_designs = 0
GROUP BY persona, support_contact_category
ORDER BY total_users DESC;

-- Is credit proxy worth considering?
SELECT 
    persona,
    ROUND(total_credit_proxy, 2) AS total_credit_proxy,
    total_sessions,
    total_designs,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM adora
WHERE persona = 'Designer'
    AND total_successful_designs > 0 AND total_failed_designs = 0
GROUP BY persona, total_credit_proxy, total_sessions, total_designs
ORDER BY total_users DESC;

-- What of plan type
SELECT
    persona,
    plan_type_id,
    total_sessions,
    total_designs,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM adora
WHERE persona = 'Designer'
    AND total_successful_designs > 0 AND total_failed_designs = 0
GROUP BY persona, plan_type_id, total_sessions, total_designs
ORDER BY total_users DESC;

-- Results are incomprehensive. Move to the failed designers

SELECT
    persona,
    usage_intensity,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM adora
WHERE persona = 'Designer'
    AND total_successful_designs = 0 AND total_failed_designs > 0
GROUP BY persona, usage_intensity
ORDER BY total_users DESC;

-- Look at their friction and experience
SELECT
    persona,
    CASE
       WHEN friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
       ELSE 'Low Friction'
    END AS friction_level,
    CASE
        WHEN experience_level IN ('Flawed', 'Mostly Successful') THEN 'Successful'
        WHEN experience_level IN ('High Friction', 'Failed') THEN 'Failed'
        ELSE 'Mixed'
    END AS experience_level, 
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM adora
WHERE persona = 'Designer'
    AND usage_intensity = 'Heavy User'
    AND friction_level IS NOT NULL
    AND experience_level IS NOT NULL
    AND total_successful_designs = 0 AND total_failed_designs > 0
GROUP BY persona,
    CASE
       WHEN friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
       ELSE 'Low Friction'
    END,
    CASE
        WHEN experience_level IN ('Flawed', 'Mostly Successful') THEN 'Successful'
        WHEN experience_level IN ('High Friction', 'Failed') THEN 'Failed'
        ELSE 'Mixed'
    END
ORDER BY total_users DESC;

-- See how many sessions they get to before churning
SELECT
    persona,
    CASE
       WHEN friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
       ELSE 'Low Friction'
    END AS friction_level,
    CASE
        WHEN experience_level IN ('Flawed', 'Mostly Successful') THEN 'Successful'
        WHEN experience_level IN ('High Friction', 'Failed') THEN 'Failed'
        ELSE 'Mixed'
    END AS experience_level,
    total_sessions,
    total_designs, 
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM adora
WHERE persona = 'Designer'
    AND usage_intensity = 'Heavy User'
    AND friction_level IS NOT NULL
    AND experience_level IS NOT NULL
    AND total_successful_designs = 0 AND total_failed_designs > 0
GROUP BY persona,
    CASE
       WHEN friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
       ELSE 'Low Friction'
    END,
    CASE
        WHEN experience_level IN ('Flawed', 'Mostly Successful') THEN 'Successful'
        WHEN experience_level IN ('High Friction', 'Failed') THEN 'Failed'
        ELSE 'Mixed'
    END, total_sessions, total_designs
ORDER BY total_users DESC;

-- Which feature is an issue for failed designers
WITH designs AS (
    SELECT
        a.user_id,
        a.persona,
        a.churned_flag,
        MAX(CASE WHEN f.feature_usage = 'Theme Editor' THEN 1 ELSE 0 END) AS theme_editor_use,
        MAX(CASE WHEN f.feature_usage = 'Figma Import' THEN 1 ELSE 0 END) AS figma_import_use
    FROM adora a
    LEFT JOIN feature_usage f
        ON a.user_id = f.user_id
    WHERE a.persona = 'Designer'
        AND a.usage_intensity = 'Heavy User'
        AND a.total_failed_designs > 0 AND a.total_successful_designs = 0
    GROUP BY a.user_id, a.persona, a.churned_flag
)
SELECT
    persona,
    CASE
        WHEN theme_editor_use > 0 AND figma_import_use = 0 THEN 'Theme Editor Users only'
        WHEN theme_editor_use = 0 AND figma_import_use > 0 THEN 'Figma Import Users only'
        WHEN theme_editor_use > 0 AND figma_import_use > 0 THEN 'Mixed use'
    END AS design_use,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM designs
GROUP BY persona,
CASE
        WHEN theme_editor_use > 0 AND figma_import_use = 0 THEN 'Theme Editor Users only'
        WHEN theme_editor_use = 0 AND figma_import_use > 0 THEN 'Figma Import Users only'
        WHEN theme_editor_use > 0 AND figma_import_use > 0 THEN 'Mixed use'
    END
ORDER BY total_users DESC;

-- Look at the friction and experience level
WITH designs AS (
    SELECT
        a.user_id,
        a.persona,
        a.churned_flag,
        CASE
            WHEN a.friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
            ELSE 'Low Friction'
        END AS friction_level,
        CASE
            WHEN a.experience_level IN ('Flawless', 'Mostly Successful') THEN 'Successful'
            WHEN a.experience_level IN ('High Friction', 'Failed') THEN 'Failed'
            ELSE 'Mixed'
        END AS experience_level,
        MAX(CASE WHEN f.feature_usage = 'Theme Editor' THEN 1 ELSE 0 END) AS theme_editor_use,
        MAX(CASE WHEN f.feature_usage = 'Figma Import' THEN 1 ELSE 0 END) AS figma_import_use
    FROM adora a
    LEFT JOIN feature_usage f
        ON a.user_id = f.user_id
    WHERE a.persona = 'Designer'
        AND a.usage_intensity = 'Heavy User'
        AND a.total_successful_designs = 0 AND a.total_failed_designs > 0
        AND a.experience_level IS NOT NULL
        AND a.friction_level IS NOT NULL
    GROUP BY a.user_id, a.persona, a.churned_flag,
        CASE
            WHEN a.friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
            ELSE 'Low Friction'
        END,
        CASE
            WHEN a.experience_level IN ('Flawless', 'Mostly Successful') THEN 'Successful'
            WHEN a.experience_level IN ('High Friction', 'Failed') THEN 'Failed'
            ELSE 'Mixed'
        END
)
SELECT
    persona,
    friction_level,
    experience_level,
    CASE
        WHEN theme_editor_use > 0 AND figma_import_use = 0 THEN 'Theme Editor Users only'
        WHEN theme_editor_use = 0 AND figma_import_use > 0 THEN 'Figma Import Users only'
        WHEN theme_editor_use > 0 AND figma_import_use > 0 THEN 'Mixed use'
    END AS design_use,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM designs
GROUP BY persona, friction_level, experience_level,
    CASE
        WHEN theme_editor_use > 0 AND figma_import_use = 0 THEN 'Theme Editor Users only'
        WHEN theme_editor_use = 0 AND figma_import_use > 0 THEN 'Figma Import Users only'
        WHEN theme_editor_use > 0 AND figma_import_use > 0 THEN 'Mixed use'
    END
ORDER BY total_users DESC;

-- Look at issue types once again
WITH designs AS (
    SELECT DISTINCT
        a.user_id,
        a.persona,
        a.churned_flag,
        COALESCE(t.issue_type, 'N/A') AS issue_type,
        MAX(CASE WHEN f.feature_usage = 'Theme Editor' THEN 1 ELSE 0 END) AS theme_editor_use,
        MAX(CASE WHEN f.feature_usage = 'Figma Import' THEN 1 ELSE 0 END) AS figma_import_use
    FROM adora a
    LEFT JOIN feature_usage f 
        ON a.user_id = f.user_id
    LEFT JOIN tickets t
        ON a.user_id = t.user_id
    WHERE a.persona = 'Designer'
        AND a.usage_intensity = 'Heavy User'
        AND a.total_successful_designs = 0
        AND a.total_failed_designs > 0
    GROUP BY a.user_id, a.persona, a.churned_flag, t.issue_type
   -- HAVING COUNT(a.user_id) <= 1
)
SELECT
    persona,
    issue_type,
    CASE
        WHEN theme_editor_use > 0 AND figma_import_use = 0 THEN 'Theme Editor Users only'
        WHEN theme_editor_use = 0 AND figma_import_use > 0 THEN 'Figma Users only'
        WHEN theme_editor_use > 0 AND figma_import_use > 0 THEN 'Both'
    END AS design_use,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM designs
GROUP BY persona, issue_type,
    CASE
        WHEN theme_editor_use > 0 AND figma_import_use = 0 THEN 'Theme Editor Users only'
        WHEN theme_editor_use = 0 AND figma_import_use > 0 THEN 'Figma Users only'
        WHEN theme_editor_use > 0 AND figma_import_use > 0 THEN 'Both'
    END
ORDER BY total_users DESC;

-- Remove the theme editor and figma import segments
WITH designs AS (
    SELECT DISTINCT
        a.user_id,
        a.persona,
        COALESCE(t.issue_type, 'N/A') AS issue_type,
        a.churned_flag
    FROM adora a
    LEFT JOIN tickets  t 
        ON a.user_id = t.user_id
    WHERE a.persona = 'Designer'
        AND a.usage_intensity = 'Heavy User'
        AND a.total_successful_designs = 0 AND total_failed_designs > 0
)
SELECT
    persona,
    issue_type,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM designs
GROUP BY persona, issue_type
ORDER BY total_users DESC;

-- See if plan type is a factor
WITH designs AS (
    SELECT DISTINCT
        a.user_id,
        a.plan_type_id,
        a.persona,
        COALESCE(t.issue_type, 'N/A') AS issue_type,
        a.churned_flag
    FROM adora a
    LEFT JOIN tickets  t 
        ON a.user_id = t.user_id
    WHERE a.persona = 'Designer'
        AND a.usage_intensity = 'Heavy User'
        AND a.total_successful_designs = 0 AND total_failed_designs > 0
)
SELECT
    persona,
    plan_type_id,
    issue_type,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM designs
GROUP BY persona, plan_type_id, issue_type
ORDER BY total_users DESC;

-- How many sessions and designs do failed designers go to before churning?
SELECT
    persona,
    total_sessions,
    total_designs,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churn_rate,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/ COUNT(user_id), 4) AS churn_rate
FROM adora
WHERE persona = 'Designer'
    AND usage_intensity = 'Heavy User'
    AND total_successful_designs = 0
    AND total_failed_designs > 0
GROUP BY persona, total_sessions, total_designs
ORDER BY total_users DESC;



-- Have they been looking for other features
SELECT
    a.persona,
    t.issue_type AS issues_raised,
     COUNT(a.user_id) AS total_users,
    SUM(CASE WHEN a.churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN a.churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(a.user_id), 4) AS churn_rate
FROM adora a
LEFT JOIN tickets t
    ON a.user_id = t.user_id
WHERE a.persona = 'Designer'
    AND a.total_successful_designs > 0 AND a.total_failed_designs = 0
GROUP BY a.persona, t.issue_type
ORDER BY total_users DESC;

-- I think designers submit ticket requests. Let me check.
WITH designs AS (
    SELECT
        a.user_id,
        a.total_sessions,
        COALESCE(t.issue_type, 'No Issues') AS issue_type,
        a.total_designs,
        a.churned_flag,
        MAX(CASE WHEN f.feature_usage = 'Theme Editor' THEN 1 ELSE 0 END) AS theme_editor_use,
        MAX(CASE WHEN f.feature_usage = 'Figma Import' THEN 1 ELSE 0 END) AS figma_import_use
    FROM adora a
    LEFT JOIN tickets t
        ON a.user_id = t.user_id
    LEFT JOIN feature_usage f
        ON a.user_id = f.user_id
       -- AND f.user_id = t.user_id
    WHERE a.persona = 'Designer'
        AND a.total_successful_designs > 0 AND a.total_failed_designs = 0
    GROUP BY a.churned_flag, a.user_id, a.total_sessions, t.issue_type, a.total_designs
)
SELECT
    issue_type,
    total_sessions,
    total_designs,
    CASE
        WHEN theme_editor_use > 0 AND figma_import_use = 0 THEN 'Theme Editor Users only'
        WHEN figma_import_use > 0 AND theme_editor_use = 0 THEN 'Figma Users only'
        WHEN figma_import_use > 0 AND theme_editor_use > 0 THEN 'Mixed'
    END AS design_use_category,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM designs
GROUP BY issue_type,
    total_sessions,
    total_designs,
    CASE
        WHEN theme_editor_use > 0 AND figma_import_use = 0 THEN 'Theme Editor Users only'
        WHEN figma_import_use > 0 AND theme_editor_use = 0 THEN 'Figma Users only'
        WHEN figma_import_use > 0 AND theme_editor_use > 0 THEN 'Mixed'
    END
ORDER BY total_users DESC;

-- Without the total sessions
WITH designs AS (
    SELECT
        a.user_id,
        a.total_sessions,
        COALESCE(t.issue_type, 'No Issues') AS issue_type,
        a.total_designs,
        a.churned_flag,
        MAX(CASE WHEN f.feature_usage = 'Theme Editor' THEN 1 ELSE 0 END) AS theme_editor_use,
        MAX(CASE WHEN f.feature_usage = 'Figma Import' THEN 1 ELSE 0 END) AS figma_import_use
    FROM adora a
    LEFT JOIN tickets t
        ON a.user_id = t.user_id
    LEFT JOIN feature_usage f
        ON a.user_id = f.user_id
       -- AND f.user_id = t.user_id
    WHERE a.persona = 'Designer'
        AND a.total_successful_designs > 0 AND a.total_failed_designs = 0
    GROUP BY a.churned_flag, a.user_id, a.total_sessions, t.issue_type, a.total_designs
)
SELECT
    issue_type,
    CASE
        WHEN theme_editor_use > 0 AND figma_import_use = 0 THEN 'Theme Editor Users only'
        WHEN figma_import_use > 0 AND theme_editor_use = 0 THEN 'Figma Users only'
        WHEN figma_import_use > 0 AND theme_editor_use > 0 THEN 'Mixed'
    END AS design_use_category,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM designs
GROUP BY issue_type,
    CASE
        WHEN theme_editor_use > 0 AND figma_import_use = 0 THEN 'Theme Editor Users only'
        WHEN figma_import_use > 0 AND theme_editor_use = 0 THEN 'Figma Users only'
        WHEN figma_import_use > 0 AND theme_editor_use > 0 THEN 'Mixed'
    END
ORDER BY total_users DESC;

-- Now that I have a signal, which plan type complains the most for payments?
WITH designs AS (
    SELECT
        a.user_id,
        a.persona,
        a.plan_type_id,
        a.churned_flag,
        t.issue_type,
        MAX(CASE WHEN f.feature_usage = 'Theme Editor' THEN 1 ELSE 0 END) AS theme_editor_use,
        MAX(CASE WHEN f.feature_usage = 'Figma Import' THEN 1 ELSE 0 END) AS figma_import_use
    FROM adora a
    LEFT JOIN feature_usage f
        ON a.user_id = f.user_id
    LEFT JOIN tickets t
        ON a.user_id = t.user_id
    WHERE a.persona = 'Designer'
        AND t.issue_type = 'Payment'
        AND a.total_successful_designs > 0 AND a.total_failed_designs = 0
    GROUP BY a.user_id, t.issue_type, a.persona, a.plan_type_id, a.churned_flag
)
SELECT
    persona,
    plan_type_id,
    issue_type,
    CASE
        WHEN theme_editor_use > 0 AND figma_import_use = 0 THEN 'Theme Editor Users only'
        WHEN theme_editor_use = 0 AND figma_import_use > 0 THEN 'Figma Users only'
        WHEN theme_editor_use > 0 AND figma_import_use > 0 THEN 'Mixed'
    END AS design_use,
        COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM designs
GROUP BY plan_type_id, persona,
    issue_type,
    CASE
        WHEN theme_editor_use > 0 AND figma_import_use = 0 THEN 'Theme Editor Users only'
        WHEN theme_editor_use = 0 AND figma_import_use > 0 THEN 'Figma Users only'
        WHEN theme_editor_use > 0 AND figma_import_use > 0 THEN 'Mixed'
    END
ORDER BY total_users DESC;

-- Look at the issue types for theme editors again
SELECT
    a.persona,
    COALESCE(t.issue_type, 'N/A') AS issue_type,
    COUNT(a.user_id) AS total_users,
    SUM(CASE WHEN a.churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN a.churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(a.user_id), 4) AS churn_rate
FROM adora a 
LEFT JOIN feature_usage f
    ON a.user_id = f.user_id
LEFT JOIN tickets t
    ON a.user_id = t.user_id
WHERE a.persona = 'Designer'
    AND a.total_successful_designs > 0 AND a.total_failed_designs = 0
    AND f.feature_usage = 'Theme Editor'
GROUP BY a.persona, t.issue_type
ORDER BY total_users DESC;

-- Look at the designers with mixed performance
SELECT
    persona,
    usage_intensity,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/ COUNT(user_id), 4) AS churn_rate
FROM adora
WHERE persona = 'Designer'
    AND total_successful_designs > 0
    AND total_failed_designs > 0
GROUP BY persona, usage_intensity
ORDER BY total_users DESC;

-- Focus on the heavy users
SELECT
    persona,
    plan_type_id,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM adora
WHERE persona = 'Designer'
    AND total_successful_designs > 0
    AND total_failed_designs > 0
    AND usage_intensity = 'Heavy User'
GROUP BY persona, plan_type_id
ORDER BY total_users DESC;

-- Look at the friction and experience levels
SELECT
    persona,
    CASE
        WHEN friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
        ELSE 'Low Friction'
    END AS friction_level,
    CASE
        WHEN experience_level IN ('Flawless', 'Mostly Successful') THEN 'Successful'
        WHEN experience_level IN ('High Friction', 'Failed') THEN 'Failed'
        ELSE 'Mixed'
    END AS experience_level,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM adora
WHERE persona = 'Designer'
    AND total_successful_designs > 0
    AND total_failed_designs > 0
    AND usage_intensity = 'Heavy User'
    AND experience_level IS NOT NULL
    AND friction_level IS NOT NULL
GROUP BY persona,
    CASE
        WHEN friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
        ELSE 'Low Friction'
    END,
    CASE
        WHEN experience_level IN ('Flawless', 'Mostly Successful') THEN 'Successful'
        WHEN experience_level IN ('High Friction', 'Failed') THEN 'Failed'
        ELSE 'Mixed'
    END
ORDER BY total_users DESC;

-- Do some drilling. Look into Enterprise and Low-friction failed users. Find their design tools
WITH designs AS (
    SELECT
        a.user_id,
        a.persona,
        a.plan_type_id,
        a.churned_flag,
        MAX(CASE WHEN f.feature_usage = 'Theme Editor' THEN 1 ELSE 0 END) AS theme_editor_use,
        MAX(CASE WHEN f.feature_usage = 'Figma Import' THEN 1 ELSE 0 END) AS figma_import_use
    FROM adora a
    LEFT JOIN feature_usage f
        ON a.user_id = f.user_id
    WHERE a.persona = 'Designer'
        AND a.plan_type_id = 'Enterprise'
        AND a.friction_level NOT IN ('High Friction', 'System Breakdown')
        AND a.friction_level IS NOT NULL
        AND a.experience_level IN ('High Friction', 'Failed')
        AND a.experience_level IS NOT NULL
    GROUP BY a.user_id, a.persona, a.plan_type_id, a.churned_flag
)
SELECT
    persona,
    plan_type_id,
    CASE
        WHEN theme_editor_use > 0 AND figma_import_use = 0 THEN 'Theme Editor Users only'
        WHEN theme_editor_use = 0 AND figma_import_use > 0 THEN 'Figma Users only'
        WHEN theme_editor_use > 0 AND figma_import_use > 0 THEN 'Both'
    END AS design_use,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM designs
GROUP BY persona, plan_type_id,
    CASE
        WHEN theme_editor_use > 0 AND figma_import_use = 0 THEN 'Theme Editor Users only'
        WHEN theme_editor_use = 0 AND figma_import_use > 0 THEN 'Figma Users only'
        WHEN theme_editor_use > 0 AND figma_import_use > 0 THEN 'Both'
    END
ORDER BY total_users DESC;

-- See the issue types
WITH designs AS (
    SELECT DISTINCT
        a.user_id,
        a.persona,
        COALESCE(t.issue_type, 'N/A') AS issue_type,
        a.plan_type_id,
        a.churned_flag,
        MAX(CASE WHEN f.feature_usage = 'Theme Editor' THEN 1 ELSE 0 END) AS theme_editor_use,
        MAX(CASE WHEN f.feature_usage = 'Figma Import' THEN 1 ELSE 0 END) AS figma_import_use
    FROM adora a
    LEFT JOIN feature_usage f
        ON a.user_id = f.user_id
    LEFT JOIN tickets t
        ON a.user_id = t.user_id
    WHERE a.persona = 'Designer'
        AND a.plan_type_id = 'Enterprise'
        AND a.friction_level NOT IN ('High Friction', 'System Breakdown')
        AND a.friction_level IS NOT NULL
        AND a.experience_level IN ('High Friction', 'Failed')
        AND a.experience_level IS NOT NULL
    GROUP BY a.user_id, a.persona, a.plan_type_id, a.churned_flag, t.issue_type
)
SELECT
    persona,
    plan_type_id,
    issue_type,
    CASE
        WHEN theme_editor_use > 0 AND figma_import_use = 0 THEN 'Theme Editor Users only'
        WHEN theme_editor_use = 0 AND figma_import_use > 0 THEN 'Figma Users only'
        WHEN theme_editor_use > 0 AND figma_import_use > 0 THEN 'Both'
    END AS design_use,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM designs
GROUP BY persona, plan_type_id, issue_type,
    CASE
        WHEN theme_editor_use > 0 AND figma_import_use = 0 THEN 'Theme Editor Users only'
        WHEN theme_editor_use = 0 AND figma_import_use > 0 THEN 'Figma Users only'
        WHEN theme_editor_use > 0 AND figma_import_use > 0 THEN 'Both'
    END
ORDER BY total_users DESC;

-- Look at issue type
WITH designs AS (
    SELECT DISTINCT
        a.user_id,
        a.persona,
        a.plan_type_id,
        COALESCE(t.issue_type, 'N/A') AS issue_type,
        a.churned_flag,
        MAX(CASE WHEN f.feature_usage = 'Theme Editor' THEN 1 ELSE 0 END) AS theme_editor_use,
        MAX(CASE WHEN f.feature_usage = 'Figma Import' THEN 1 ELSE 0 END) AS figma_import_use
    FROM adora a
    LEFT JOIN feature_usage f
        ON a.user_id = f.user_id
    LEFT JOIN tickets t
        ON a.user_id = t.user_id
    WHERE a.persona = 'Designer'
        AND a.total_successful_designs > 0 AND a.total_failed_designs > 0
        AND a.plan_type_id NOT IN ('Enterprise')
        AND a.friction_level NOT IN ('Low Friction')
        AND a.friction_level IS NOT NULL
        AND a.experience_level NOT IN ('High Friction', 'Failed')
        AND a.experience_level IS NOT NULL
    GROUP BY a.user_id, a.persona, a.plan_type_id, t.issue_type, a.churned_flag
)
SELECT
    persona,
    plan_type_id,
    issue_type,
    CASE
        WHEN theme_editor_use > 0 AND figma_import_use = 0 THEN 'Theme Editor Users only'
        WHEN theme_editor_use = 0 AND figma_import_use > 0 THEN 'Figma Users only'
        WHEN theme_editor_use > 0 AND figma_import_use > 0 THEN 'Both'
    END AS design_use,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM designs
GROUP BY persona, plan_type_id, issue_type,
    CASE
        WHEN theme_editor_use > 0 AND figma_import_use = 0 THEN 'Theme Editor Users only'
        WHEN theme_editor_use = 0 AND figma_import_use > 0 THEN 'Figma Users only'
        WHEN theme_editor_use > 0 AND figma_import_use > 0 THEN 'Both'
    END
ORDER BY total_users DESC;

-- Look at the AI Users
SELECT
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users
FROM adora
WHERE persona = 'AI User'

-- Check if it is only AI they use it for
SELECT
    persona,
    AI_focus,
    deployment_focus,
    design_focus,
    code_export_focus,
    app_build_focus,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM adora
WHERE persona = 'AI User'
GROUP BY persona, AI_focus, deployment_focus, design_focus, code_export_focus, app_build_focus
ORDER BY total_users DESC;

-- Since they are not exclusively AI users, we'd do this.
SELECT
    persona,
    CASE
        WHEN AI_focus BETWEEN 0 AND 1 THEN 'Low'
        WHEN AI_focus BETWEEN 1.1 AND 5 THEN 'Medium'
        WHEN AI_focus > 5 THEN 'High'
        ELSE 'N/A'
    END AS AI_focus,
    CASE
        WHEN deployment_focus IS NULL THEN 'No use'
        WHEN deployment_focus BETWEEN 0 AND 1 THEN 'Low'
        WHEN deployment_focus BETWEEN 1.1 AND 5 THEN 'Medium'
        WHEN deployment_focus > 5 THEN 'High'
    END AS deployment_focus,
    CASE 
        WHEN design_focus IS NULL THEN 'No use'
        WHEN design_focus BETWEEN 0 AND 1 THEN 'Low'
        WHEN design_focus BETWEEN 1.1 AND 5 THEN 'Medium'
        WHEN design_focus > 5 THEN 'High'
    END AS design_focus,
    CASE
        WHEN code_export_focus IS NULL THEN 'No use'
        WHEN code_export_focus BETWEEN 0 AND 1 THEN 'Low'
        WHEN code_export_focus BETWEEN 1.1 AND 5 THEN 'Medium'
        WHEN code_export_focus > 5 THEN 'High'
    END AS code_export_focus,
    CASE
        WHEN app_build_focus IS NULL THEN 'No use'
        WHEN app_build_focus BETWEEN 0 AND 1 THEN 'Low'
        WHEN app_build_focus BETWEEN 1.1 AND 5 THEN 'Medium'
        WHEN app_build_focus > 5 THEN 'High'
    END AS app_build_focus,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM adora
WHERE persona = 'AI User'
GROUP BY persona,
    CASE
        WHEN AI_focus BETWEEN 0 AND 1 THEN 'Low'
        WHEN AI_focus BETWEEN 1.1 AND 5 THEN 'Medium'
        WHEN AI_focus > 5 THEN 'High'
        ELSE 'N/A'
    END,
    CASE
        WHEN deployment_focus IS NULL THEN 'No use'
        WHEN deployment_focus BETWEEN 0 AND 1 THEN 'Low'
        WHEN deployment_focus BETWEEN 1.1 AND 5 THEN 'Medium'
        WHEN deployment_focus > 5 THEN 'High'
    END,
    CASE 
        WHEN design_focus IS NULL THEN 'No use'
        WHEN design_focus BETWEEN 0 AND 1 THEN 'Low'
        WHEN design_focus BETWEEN 1.1 AND 5 THEN 'Medium'
        WHEN design_focus > 5 THEN 'High'
    END,
    CASE
        WHEN code_export_focus IS NULL THEN 'No use'
        WHEN code_export_focus BETWEEN 0 AND 1 THEN 'Low'
        WHEN code_export_focus BETWEEN 1.1 AND 5 THEN 'Medium'
        WHEN code_export_focus > 5 THEN 'High'
    END,
    CASE
        WHEN app_build_focus IS NULL THEN 'No use'
        WHEN app_build_focus BETWEEN 0 AND 1 THEN 'Low'
        WHEN app_build_focus BETWEEN 1.1 AND 5 THEN 'Medium'
        WHEN app_build_focus > 5 THEN 'High'
    END
ORDER BY total_users DESC;

-- Divide AI users based on their success
SELECT
    persona,
    CASE
        WHEN total_successful_AI_use_sessions > 0 AND total_failed_AI_use_sessions = 0 THEN 'Successful AI Users'
        WHEN total_successful_AI_use_sessions = 0 AND total_failed_AI_use_sessions > 0 THEN 'Failed AI Users'
        WHEN total_successful_AI_use_sessions > 0 AND total_failed_AI_use_sessions > 0 THEN 'Mixed Performance'
    END AS ai_performers,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM adora
WHERE persona = 'AI User'
GROUP BY persona,
    CASE
        WHEN total_successful_AI_use_sessions > 0 AND total_failed_AI_use_sessions = 0 THEN 'Successful AI Users'
        WHEN total_successful_AI_use_sessions = 0 AND total_failed_AI_use_sessions > 0 THEN 'Failed AI Users'
        WHEN total_successful_AI_use_sessions > 0 AND total_failed_AI_use_sessions > 0 THEN 'Mixed Performance'
    END
ORDER BY total_users DESC;

-- Focusing on failed AI users by looking at usage intensity.
SELECT
    persona,
    usage_intensity,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM adora
WHERE persona = 'AI User'
    AND total_successful_AI_use_sessions = 0
    AND total_failed_AI_use_sessions > 0
GROUP BY persona, usage_intensity
ORDER BY total_users DESC;

-- Are friction and experience the cause for churn?
SELECT
    persona,
    usage_intensity,
    CASE
        WHEN friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
        ELSE 'Low Friction'
    END AS friction_level,
    CASE
        WHEN experience_level IN ('Flawless', 'Mostly Successful') THEN 'Successful'
        WHEN experience_level IN ('High Friction', 'Failed') THEN 'Failed'
        ELSE 'Mixed'
    END AS experience_level,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM adora
WHERE persona = 'AI User'
    AND total_successful_AI_use_sessions = 0
    AND total_failed_AI_use_sessions > 0
GROUP BY persona, usage_intensity,
    CASE
        WHEN friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
        ELSE 'Low Friction'
    END,
    CASE
        WHEN experience_level IN ('Flawless', 'Mostly Successful') THEN 'Successful'
        WHEN experience_level IN ('High Friction', 'Failed') THEN 'Failed'
        ELSE 'Mixed'
    END
ORDER BY total_users DESC;

-- What of total sessions and AI use?
SELECT
    persona,
    total_sessions,
    total_AI_use,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM adora
WHERE persona = 'AI User'
    AND total_successful_AI_use_sessions = 0
    AND total_failed_AI_use_sessions > 0
GROUP BY persona, total_sessions, total_AI_use
ORDER BY total_users DESC;


-- What of tickets
WITH ai AS (
    SELECT DISTINCT
        a.user_id,
        a.persona,
        COALESCE(t.issue_type, 'N/A') AS issue_type,
        a.churned_flag
    FROM adora a
    LEFT JOIN tickets t 
        ON a.user_id = t.user_id
    WHERE a.total_successful_AI_use_sessions = 0
        AND a.persona = 'AI User'
        AND a.total_failed_AI_use_sessions > 0
)
SELECT 
    persona,
    issue_type,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM ai
GROUP BY persona, issue_type
ORDER BY total_users DESC;

-- Look at plan types
SELECT
    persona,
    plan_type_id,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM adora
WHERE persona = 'AI User'
    AND total_successful_AI_use_sessions = 0
    AND total_failed_AI_use_sessions > 0
GROUP BY persona, plan_type_id
ORDER BY total_users DESC;

-- Look at plan type and tickets
-- What of tickets
WITH ai AS (
    SELECT DISTINCT
        a.user_id,
        a.persona,
        a.plan_type_id,
        COALESCE(t.issue_type, 'N/A') AS issue_type,
        a.churned_flag
    FROM adora a
    LEFT JOIN tickets t 
        ON a.user_id = t.user_id
    WHERE a.total_successful_AI_use_sessions = 0
        AND a.persona = 'AI User'
        AND a.total_failed_AI_use_sessions > 0
)
SELECT 
    persona,
    issue_type,
    plan_type_id,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM ai
GROUP BY persona, issue_type, plan_type_id
ORDER BY total_users DESC;

-- Look at successful AI users
SELECT
    persona,
    usage_intensity,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM adora
WHERE persona = 'AI User'
    AND total_successful_AI_use_sessions > 0
    AND total_failed_AI_use_sessions = 0
GROUP BY persona, usage_intensity
ORDER BY total_users DESC;

-- Look at heavy users and their total sessions
SELECT
    persona,
    total_sessions,
    total_AI_use,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate 
FROM adora
WHERE persona = 'AI User'
    AND total_successful_AI_use_sessions > 0
    AND total_failed_AI_use_sessions = 0
    AND usage_intensity = 'Heavy User'
GROUP BY persona, total_sessions, total_AI_use
ORDER BY total_users DESC;

-- Do some binning
SELECT
    persona,
    total_sessions,
    CASE
        WHEN total_AI_use = 1 THEN '1'
        WHEN total_AI_use BETWEEN 2 AND 4 THEN '2-4'
        WHEN total_AI_use BETWEEN 5 AND 7 THEN '5-7'
        ELSE '8+'
    END AS AI_use_category,
    usage_intensity,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate 
FROM adora
WHERE persona = 'AI User'
    AND total_successful_AI_use_sessions > 0
    AND total_failed_AI_use_sessions = 0
    AND total_sessions BETWEEN 1 AND 2
GROUP BY persona, total_sessions, usage_intensity,
    CASE
        WHEN total_AI_use = 1 THEN '1'
        WHEN total_AI_use BETWEEN 2 AND 4 THEN '2-4'
        WHEN total_AI_use BETWEEN 5 AND 7 THEN '5-7'
        ELSE '8+'
    END
ORDER BY total_users DESC;

-- Look at the issue types and the problems they face
SELECT
    a.persona,
    a.plan_type_id,
    COALESCE(t.issue_type, 'N/A') AS issue_type,
    a.total_sessions,
    CASE
        WHEN a.total_AI_use = 1 THEN '1'
        WHEN a.total_AI_use BETWEEN 2 AND 4 THEN '2-4'
        WHEN a.total_AI_use BETWEEN 5 AND 7 THEN '5-7'
        ELSE '8+'
    END AS AI_use_category,
    COUNT(a.user_id) AS total_users,
    SUM(CASE WHEN a.churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN a.churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(a.user_id), 4) AS churn_rate 
FROM adora a
LEFT JOIN tickets t
    ON a.user_id = t.user_id
WHERE a.persona = 'AI User'
    AND a.total_successful_AI_use_sessions > 0
    AND a.total_failed_AI_use_sessions = 0
    AND a.total_sessions BETWEEN 1 AND 2
GROUP BY a.persona,
    a.plan_type_id,
    t.issue_type,
    a.total_sessions,
    CASE
        WHEN a.total_AI_use = 1 THEN '1'
        WHEN a.total_AI_use BETWEEN 2 AND 4 THEN '2-4'
        WHEN a.total_AI_use BETWEEN 5 AND 7 THEN '5-7'
        ELSE '8+'
    END
ORDER BY total_users DESC;

-- AI use category and plan type
SELECT
    persona,
    plan_type_id,
    CASE
        WHEN total_AI_use = 1 THEN '1'
        WHEN total_AI_use BETWEEN 2 AND 4 THEN '2-4'
        WHEN total_AI_use BETWEEN 5 AND 7 THEN '5-7'
        ELSE '8+'
    END AS AI_use_category,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate 
FROM adora
WHERE persona = 'AI User'
    AND total_successful_AI_use_sessions > 0
    AND total_failed_AI_use_sessions = 0
    AND total_sessions BETWEEN 1 AND 2
GROUP BY persona,
    plan_type_id,
    CASE
        WHEN total_AI_use = 1 THEN '1'
        WHEN total_AI_use BETWEEN 2 AND 4 THEN '2-4'
        WHEN total_AI_use BETWEEN 5 AND 7 THEN '5-7'
        ELSE '8+'
    END
ORDER BY total_users DESC;

--AI USe category and issue type
SELECT
    a.persona,
    COALESCE(t.issue_type, 'N/A') AS issue_type,
    CASE
        WHEN a.total_AI_use = 1 THEN '1'
        WHEN a.total_AI_use BETWEEN 2 AND 4 THEN '2-4'
        WHEN a.total_AI_use BETWEEN 5 AND 7 THEN '5-7'
        ELSE '8+'
    END AS AI_use_category,
    COUNT(a.user_id) AS total_users,
    SUM(CASE WHEN a.churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN a.churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(a.user_id), 4) AS churn_rate 
FROM adora a
LEFT JOIN tickets t
    ON a.user_id = t.user_id
WHERE a.persona = 'AI User'
    AND a.total_successful_AI_use_sessions > 0
    AND a.total_failed_AI_use_sessions = 0
    AND a.total_sessions BETWEEN 1 AND 2
GROUP BY a.persona,
    t.issue_type,
    CASE
        WHEN a.total_AI_use = 1 THEN '1'
        WHEN a.total_AI_use BETWEEN 2 AND 4 THEN '2-4'
        WHEN a.total_AI_use BETWEEN 5 AND 7 THEN '5-7'
        ELSE '8+'
    END
ORDER BY total_users DESC;

-- Plan vs issue type
SELECT
    a.persona,
    a.plan_type_id,
    COALESCE(t.issue_type, 'N/A') AS issue_type,
    COUNT(a.user_id) AS total_users,
    SUM(CASE WHEN a.churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN a.churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(a.user_id), 4) AS churn_rate 
FROM adora a
LEFT JOIN tickets t
    ON a.user_id = t.user_id
WHERE a.persona = 'AI User'
    AND a.total_successful_AI_use_sessions > 0
    AND a.total_failed_AI_use_sessions = 0
    AND a.total_sessions BETWEEN 1 AND 2
GROUP BY a.persona,
    t.issue_type, a.plan_type_id
ORDER BY total_users DESC;

-- Mixed performers
SELECT
    persona, 
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM adora
WHERE persona = 'AI User'
    AND total_successful_AI_use_sessions > 0
    AND total_failed_AI_use_sessions > 0
GROUP BY persona

-- Usage intensity first
SELECT
    persona,
    usage_intensity,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM adora
WHERE persona = 'AI User'
    AND total_successful_AI_use_sessions > 0
    AND total_failed_AI_use_sessions > 0
GROUP BY persona, usage_intensity
ORDER BY total_users DESC;

-- So we focus on the heavy users
SELECT
    persona,
    CASE
        WHEN friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
        ELSE 'Low Friction'
    END AS friction_level,
    CASE
        WHEN experience_level IN ('Flawless', 'Mostly Successful') THEN 'Successful'
        WHEN experience_level IN ('High Friction', 'Failed') THEN 'Failed'
        ELSE 'Mixed'
    END AS experience_level,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM adora 
WHERE persona = 'AI User'
    AND total_successful_AI_use_sessions > 0
    AND total_failed_AI_use_sessions > 0
    AND usage_intensity = 'Heavy User'
    AND experience_level IS NOT NULL
    AND friction_level IS NOT NULL
GROUP BY persona,
    CASE
        WHEN friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
        ELSE 'Low Friction'
    END,
    CASE
        WHEN experience_level IN ('Flawless', 'Mostly Successful') THEN 'Successful'
        WHEN experience_level IN ('High Friction', 'Failed') THEN 'Failed'
        ELSE 'Mixed'
    END
ORDER BY total_users DESC;

-- Next step: Look at the total sessions
SELECT
    persona,
    total_sessions,
    total_AI_use,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM adora
WHERE persona = 'AI User'
    AND total_successful_AI_use_sessions > 0
    AND total_failed_AI_use_sessions > 0
    AND usage_intensity = 'Heavy User'
    AND experience_level IS NOT NULL
    AND friction_level IS NOT NULL
GROUP BY persona, total_sessions, total_AI_use
ORDER BY total_users DESC;

SELECT
    persona,
    total_sessions,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM adora
WHERE persona = 'AI User'
    AND total_successful_AI_use_sessions > 0
    AND total_failed_AI_use_sessions > 0
    AND usage_intensity = 'Heavy User'
    AND experience_level IS NOT NULL
    AND friction_level IS NOT NULL
GROUP BY persona, total_sessions
ORDER BY total_users DESC;

-- Look at the relationship between plan type and issue type
SELECT
    a.persona,
    a.total_sessions,
    a.plan_type_id,
    t.issue_type,
    COUNT(a.user_id) AS total_users,
    SUM(CASE WHEN a.churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN a.churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(a.user_id), 4) AS churn_rate
FROM adora a
LEFT JOIN tickets t
    ON a.user_id = t.[user_id]
WHERE a.persona = 'AI User'
    AND a.total_successful_AI_use_sessions > 0
    AND a.total_failed_AI_use_sessions > 0
    AND a.usage_intensity = 'Heavy User'
    AND a.experience_level IS NOT NULL
    AND a.friction_level IS NOT NULL
GROUP BY a.persona, a.total_sessions, a.plan_type_id, t.issue_type
ORDER BY total_users DESC;

-- Back to founders
SELECT
    a.persona,
    a.total_sessions,
    t.issue_type,
    COUNT(a.[user_id]) AS total_users,
    SUM(CASE WHEN a.churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN a.churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(a.[user_id]), 4) AS churn_rate
FROM adora a
LEFT JOIN tickets t 
    ON a.user_id = t.user_id
WHERE a.persona = 'Founder'
    AND a.total_successful_deployments > 0 AND total_failed_deployments = 0
GROUP BY a.persona, a.total_sessions, t.issue_type
ORDER BY total_users DESC;

SELECT
    a.persona,
    a.total_sessions,
    a.total_deployments,
    t.issue_type,
    COUNT(a.[user_id]) AS total_users,
    SUM(CASE WHEN a.churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN a.churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(a.[user_id]), 4) AS churn_rate
FROM adora a
LEFT JOIN tickets t 
    ON a.user_id = t.user_id
WHERE a.persona = 'Founder'
    AND a.total_successful_deployments > 0 AND total_failed_deployments = 0
GROUP BY a.persona, a.total_sessions, t.issue_type, a.total_deployments
ORDER BY total_users DESC;

-- Remember GitHub and Supabase
WITH deployments AS (
    SELECT DISTINCT
        a.user_id,
        a.persona,
        MAX(CASE WHEN f.feature_usage = 'GitHub' THEN 1 ELSE 0 END) AS github_use,
        MAX(CASE WHEN f.feature_usage = 'Supabase' THEN 1 ELSE 0 END) AS supabase_use,
        t.issue_type,
        a.total_sessions,
        a.churned_flag,
        a.total_deployments
    FROM adora a
    LEFT JOIN tickets t
        ON a.user_id = t.[user_id]
    LEFT JOIN feature_usage f
        ON a.user_id = f.[user_id]
    WHERE a.persona = 'Founder'
        AND a.total_successful_deployments > 0
        AND a.total_failed_deployments = 0
    GROUP BY a.user_id, a.persona, t.issue_type, a.total_sessions, a.churned_flag, a.total_deployments
)
SELECT
    persona,
    issue_type,
    total_sessions,
    total_deployments,
    CASE
        WHEN github_use > 0 AND supabase_use = 0 THEN 'GitHub users only'
        WHEN supabase_use > 0 AND github_use = 0 THEN 'Supabase users only'
        WHEN github_use > 0 AND supabase_use > 0 THEN 'Both'
    END AS deployment_feature,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM deployments
GROUP BY persona, issue_type, total_sessions, total_deployments,
    CASE
        WHEN github_use > 0 AND supabase_use = 0 THEN 'GitHub users only'
        WHEN supabase_use > 0 AND github_use = 0 THEN 'Supabase users only'
        WHEN github_use > 0 AND supabase_use > 0 THEN 'Both'
    END
ORDER BY total_users DESC;

-- Go to Devs
SELECT
    persona,
    CASE 
         WHEN total_code_export_successful_sessions > 0 AND total_failed_code_export_sessions = 0 THEN 'Successful Devs'
         WHEN total_code_export_successful_sessions = 0 AND total_failed_code_export_sessions > 0 THEN 'Failed Devs'
         WHEN total_code_export_successful_sessions > 0 AND total_failed_code_export_sessions > 0 THEN 'Mixed'
    END AS dev_performance,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM adora
WHERE persona = 'Dev'
GROUP BY persona,
    CASE 
         WHEN total_code_export_successful_sessions > 0 AND total_failed_code_export_sessions = 0 THEN 'Successful Devs'
         WHEN total_code_export_successful_sessions = 0 AND total_failed_code_export_sessions > 0 THEN 'Failed Devs'
         WHEN total_code_export_successful_sessions > 0 AND total_failed_code_export_sessions > 0 THEN 'Mixed'
    END
ORDER BY total_users DESC;

-- Focus first on successful Devs
SELECT
    persona,
    usage_intensity,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM adora
WHERE persona = 'Dev'
    AND total_code_export_successful_sessions > 0 AND total_failed_code_export_sessions = 0
GROUP BY persona, usage_intensity
ORDER BY total_users DESC;

-- Look at their total sessions and code exports
SELECT
    persona,
    total_sessions,
    total_code_exports,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM adora
WHERE persona = 'Dev'
    AND usage_intensity = 'Heavy User'
    AND total_code_export_successful_sessions > 0 AND total_failed_code_export_sessions = 0
GROUP BY persona, total_sessions, total_code_exports
ORDER BY total_users DESC;

-- Bin the total code exports
SELECT
    persona,
    total_sessions,
    CASE
        WHEN total_code_exports BETWEEN 1 AND 2 THEN 'Opportunistic Extraction'
        WHEN total_code_exports BETWEEN 3 AND 5 THEN 'Task Completion'
        WHEN total_code_exports BETWEEN 6 AND 9 THEN 'Iterative Development'
        ELSE 'Industrial Scale Usage'
    END AS dev_status,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM adora
WHERE persona = 'Dev'
    AND usage_intensity = 'Heavy User'
    AND total_code_export_successful_sessions > 0 AND total_failed_code_export_sessions = 0
GROUP BY persona,total_sessions,
    CASE
        WHEN total_code_exports BETWEEN 1 AND 2 THEN 'Opportunistic Extraction'
        WHEN total_code_exports BETWEEN 3 AND 5 THEN 'Task Completion'
        WHEN total_code_exports BETWEEN 6 AND 9 THEN 'Iterative Development'
        ELSE 'Industrial Scale Usage'
    END
ORDER BY total_users DESC;

-- Issue types
SELECT
    a.persona,
    a.plan_type_id,
    COALESCE(t.issue_type, 'N/A') AS issue_type,
    COUNT(a.user_id) AS total_users,
    SUM(CASE WHEN a.churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN a.churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(a.user_id), 4) AS churn_rate
FROM adora a
LEFT JOIN tickets t 
    ON a.user_id = t.user_id
WHERE a.persona = 'Dev'
    AND a.total_code_export_successful_sessions > 0 AND total_failed_code_export_sessions = 0
    AND a.usage_intensity = 'Heavy User'
GROUP BY a.persona, t.issue_type, a.plan_type_id
ORDER BY total_users DESC;

-- See the relationship between dev_status and issue_type
SELECT
    a.persona,
     CASE
        WHEN a.total_code_exports BETWEEN 1 AND 2 THEN 'Opportunistic Extraction'
        WHEN a.total_code_exports BETWEEN 3 AND 5 THEN 'Task Completion'
        WHEN a.total_code_exports BETWEEN 6 AND 9 THEN 'Iterative Development'
        ELSE 'Industrial Scale Usage'
    END AS dev_status,
    COALESCE(t.issue_type, 'N/A') AS issue_type,
    COUNT(a.user_id) AS total_users,
    SUM(CASE WHEN a.churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN a.churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(a.user_id), 4) AS churn_rate
FROM adora a
LEFT JOIN tickets t 
    ON a.user_id = t.user_id
WHERE a.persona = 'Dev'
    AND a.total_code_export_successful_sessions > 0 AND total_failed_code_export_sessions = 0
    AND a.usage_intensity = 'Heavy User'
GROUP BY a.persona, t.issue_type, a.plan_type_id,
    CASE
        WHEN a.total_code_exports BETWEEN 1 AND 2 THEN 'Opportunistic Extraction'
        WHEN a.total_code_exports BETWEEN 3 AND 5 THEN 'Task Completion'
        WHEN a.total_code_exports BETWEEN 6 AND 9 THEN 'Iterative Development'
        ELSE 'Industrial Scale Usage'
    END
ORDER BY total_users DESC;

-- Include average 
SELECT
    a.persona,
     CASE
        WHEN a.total_code_exports BETWEEN 1 AND 2 THEN 'Opportunistic Extraction'
        WHEN a.total_code_exports BETWEEN 3 AND 5 THEN 'Task Completion'
        WHEN a.total_code_exports BETWEEN 6 AND 9 THEN 'Iterative Development'
        ELSE 'Industrial Scale Usage'
    END AS dev_status,
    COALESCE(t.issue_type, 'N/A') AS issue_type,
    AVG(total_code_exports) AS average_code_exports,
    COUNT(a.user_id) AS total_users,
    SUM(CASE WHEN a.churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN a.churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(a.user_id), 4) AS churn_rate
FROM adora a
LEFT JOIN tickets t 
    ON a.user_id = t.user_id
WHERE a.persona = 'Dev'
    AND a.total_code_export_successful_sessions > 0 AND total_failed_code_export_sessions = 0
    AND a.usage_intensity = 'Heavy User'
GROUP BY a.persona, t.issue_type, a.plan_type_id,
    CASE
        WHEN a.total_code_exports BETWEEN 1 AND 2 THEN 'Opportunistic Extraction'
        WHEN a.total_code_exports BETWEEN 3 AND 5 THEN 'Task Completion'
        WHEN a.total_code_exports BETWEEN 6 AND 9 THEN 'Iterative Development'
        ELSE 'Industrial Scale Usage'
    END
ORDER BY total_users DESC;

-- What is making failed devs go?
SELECT
    persona,
    usage_intensity,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM adora
WHERE persona = 'Dev'
    AND total_failed_code_export_sessions > 0 AND total_code_export_successful_sessions = 0
GROUP BY persona, usage_intensity
ORDER BY total_users DESC;

-- Look at friction and experience level
SELECT
    persona,
    CASE
        WHEN friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
        ELSE 'Low Friction'
    END AS friction_level,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM adora
WHERE persona = 'Dev'
    AND friction_level IS NOT NULL
    AND total_failed_code_export_sessions > 0 AND total_code_export_successful_sessions = 0
GROUP BY persona,
    CASE
        WHEN friction_level IN ('High Friction', 'System Breakdown') THEN 'High Friction'
        ELSE 'Low Friction'
    END
ORDER BY total_users DESC;

-- Look at their total sessions
SELECT
    persona,
    total_sessions,
    total_code_exports,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag =1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM adora
WHERE persona = 'Dev'
    AND total_failed_code_export_sessions > 0 
    AND total_code_export_successful_sessions = 0
GROUP BY persona, total_sessions, total_code_exports
ORDER BY total_users DESC;

-- Look at issue types instead
SELECT
    a.persona,
    COALESCE(t.issue_type, 'N/A') AS issue_type,
    COUNT(DISTINCT a.user_id) AS total_users,
    SUM(CASE WHEN a.churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN a.churned_flag =1 THEN 1 ELSE 0 END)/COUNT(a.user_id), 4) AS churn_rate
FROM adora a
LEFT JOIN tickets t
    ON a.user_id = t.user_id
WHERE a.persona = 'Dev'
    AND a.total_failed_code_export_sessions > 0 
    AND a.total_code_export_successful_sessions = 0
GROUP BY a.persona, t.issue_type
ORDER BY total_users DESC;

-- To look at multiple complaints
WITH user_issues AS (
    SELECT
        a.user_id,
        a.persona,
        a.churned_flag,
        t.issue_type
    FROM adora a
    LEFT JOIN tickets t
        ON a.user_id = t.user_id
    WHERE a.persona = 'Dev'
        AND a.total_failed_code_export_sessions > 0 
        AND a.total_code_export_successful_sessions = 0
)
, issue_summary AS (
    SELECT
        persona,
        COALESCE(issue_type, 'N/A') AS issue_type,
        COUNT(DISTINCT user_id) AS total_users,
        SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users
    FROM user_issues
    GROUP BY persona, COALESCE(issue_type, 'N/A')
)
SELECT
    persona,
    issue_type,
    total_users,
    churned_users,
    ROUND(1.0 * churned_users / total_users, 4) AS churn_rate
FROM issue_summary
ORDER BY total_users DESC;

-- Look at multiple complaints
WITH user_issue_counts AS (
    SELECT
        a.user_id,
        a.persona,
        a.churned_flag,
        COUNT(DISTINCT t.issue_type) AS distinct_issue_count
    FROM adora a
    LEFT JOIN tickets t
        ON a.user_id = t.user_id
    WHERE a.persona = 'Dev'
        AND a.total_failed_code_export_sessions > 0 
        AND a.total_code_export_successful_sessions = 0
    GROUP BY a.user_id, a.persona, a.churned_flag
)
SELECT
    distinct_issue_count AS number_of_issue_types_reported,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(1.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) / COUNT(user_id), 4) AS churn_rate
FROM user_issue_counts
GROUP BY distinct_issue_count
ORDER BY distinct_issue_count;

-- Churn per issue type, counting each user once per type
WITH user_issues AS (
    SELECT DISTINCT
        a.user_id,
        CAST(a.churned_flag AS INT) AS churned_flag,
        t.issue_type
    FROM adora a
    JOIN tickets t
        ON a.user_id = t.user_id
    WHERE a.persona = 'Dev'
        AND a.total_failed_code_export_sessions > 0 
        AND a.total_code_export_successful_sessions = 0
)

SELECT
    issue_type,
    COUNT(user_id) AS total_users,
    SUM(churned_flag) AS churned_users,
    CAST(SUM(churned_flag) AS FLOAT)/COUNT(user_id) AS churn_rate
FROM user_issues
GROUP BY issue_type
ORDER BY total_users DESC;

SELECT
    t.issue_type,
    COUNT(DISTINCT a.user_id) AS total_users,
    SUM(CASE WHEN a.churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    CAST(SUM(CASE WHEN a.churned_flag = 1 THEN 1 ELSE 0 END) AS FLOAT) 
        / COUNT(DISTINCT a.user_id) AS churn_rate
FROM adora a
JOIN tickets t
    ON a.user_id = t.user_id
WHERE a.persona = 'Dev'
AND a.total_failed_code_export_sessions > 0 
        AND a.total_code_export_successful_sessions = 0
GROUP BY t.issue_type
ORDER BY total_users DESC;

WITH user_issues AS (
    SELECT
        a.user_id,
        t.issue_type,
        MAX(a.churned_flag) AS churned_flag
    FROM adora a
    JOIN tickets t
        ON a.user_id = t.user_id
    WHERE a.persona = 'Dev'
      AND a.total_failed_code_export_sessions > 0
      AND a.total_code_export_successful_sessions = 0
    GROUP BY a.user_id, t.issue_type;

    -- Do this instead
WITH features AS (
        SELECT
            a.user_id,
            a.persona,
            a.churned_flag,
            MAX(CASE WHEN t.issue_type = 'Payment' THEN 1 ELSE 0 END) AS payment_ticket,
            MAX(CASE WHEN t.issue_type = 'Misprompt' THEN 1 ELSE 0 END) AS Misprompt_ticket,
            MAX(CASE WHEN t.issue_type = 'Feature Request' THEN 1 ELSE 0 END) AS feature_request_ticket,
            MAX(CASE WHEN t.issue_type = 'Bug' THEN 1 ELSE 0 END) AS bug_ticket,
            MAX(CASE WHEN t.issue_type = 'UI Issue' THEN 1 ELSE 0 END) AS ui_issue_ticket
        FROM adora a
        LEFT JOIN tickets t
            ON a.user_id = t.user_id
        WHERE a.persona = 'Dev'
            AND a.total_failed_code_export_sessions > 0
            AND a.total_code_export_successful_sessions = 0
        GROUP BY a.user_id, a.persona, a.churned_flag
),
issue_combos AS (
    SELECT
        *,
        CONCAT(
            CASE WHEN payment_ticket = 1 THEN 'Payment + ' ELSE '' END,
            CASE WHEN misprompt_ticket = 1 THEN 'Misprompt + ' ELSE '' END,
            CASE WHEN feature_request_ticket = 1 THEN 'Feature Request + ' ELSE '' END,
            CASE WHEN bug_ticket = 1 THEN  'Bu + ' ELSE '' END,
            CASE WHEN ui_issue_ticket = 1 THEN 'UI Issue + ' ELSE '' END
        ) AS issue_combo_raw
    FROM features
),
cleaned_combos AS (
    SELECT
        user_id,
        persona,
        churned_flag,
        LEFT(issue_combo_raw, LEN(issue_combo_raw) - 3) AS issue_combo
    FROM issue_combos
)
SELECT
        issue_combo,
        COUNT(*) AS total_users,
        SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
        ROUND(SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(user_id), 4) AS churn_rate
FROM cleaned_combos
GROUP BY issue_combo
ORDER BY total_users DESC;

WITH features AS (
    SELECT
        a.user_id,
        a.persona,
        a.churned_flag,
        MAX(CASE WHEN t.issue_type = 'Payment' THEN 1 ELSE 0 END) AS payment_ticket,
        MAX(CASE WHEN t.issue_type = 'Misprompt' THEN 1 ELSE 0 END) AS misprompt_ticket,
        MAX(CASE WHEN t.issue_type = 'Feature Request' THEN 1 ELSE 0 END) AS feature_request_ticket,
        MAX(CASE WHEN t.issue_type = 'Bug' THEN 1 ELSE 0 END) AS bug_ticket,
        MAX(CASE WHEN t.issue_type = 'UI Issue' THEN 1 ELSE 0 END) AS ui_issue_ticket
    FROM adora a
    LEFT JOIN tickets t
        ON a.user_id = t.user_id
    WHERE a.persona = 'Dev'
        AND a.total_failed_code_export_sessions > 0
        AND a.total_code_export_successful_sessions = 0
    GROUP BY a.user_id, a.persona, a.churned_flag
),
issue_combos AS (
    SELECT
        *,
        CONCAT(
            CASE WHEN payment_ticket = 1 THEN 'Payment + ' ELSE '' END,
            CASE WHEN misprompt_ticket = 1 THEN 'Misprompt + ' ELSE '' END,
            CASE WHEN feature_request_ticket = 1 THEN 'Feature Request + ' ELSE '' END,
            CASE WHEN bug_ticket = 1 THEN 'Bug + ' ELSE '' END,
            CASE WHEN ui_issue_ticket = 1 THEN 'UI Issue + ' ELSE '' END
        ) AS issue_combo_raw
    FROM features
),
cleaned_combos AS (
    SELECT
        user_id,
        persona,
        churned_flag,
        -- Prevents negative length errors if issue_combo_raw is empty
        CASE 
            WHEN issue_combo_raw = '' THEN 'No Tickets'
            ELSE LEFT(issue_combo_raw, LEN(issue_combo_raw) - 3) 
        END AS issue_combo
    FROM issue_combos
)
SELECT
    issue_combo,
    COUNT(*) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    -- Multiplying by 1.0 prevents integer division (returning 0)
    ROUND(SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) * 1.0 / COUNT(user_id), 4) AS churn_rate
FROM cleaned_combos
GROUP BY issue_combo
ORDER BY total_users DESC;

WITH features AS (
    SELECT
        a.user_id,
        a.persona,
        a.churned_flag,
        MAX(CASE WHEN t.issue_type = 'Payment' THEN 1 ELSE 0 END) AS payment_ticket,
        MAX(CASE WHEN t.issue_type = 'Misprompt' THEN 1 ELSE 0 END) AS misprompt_ticket,
        MAX(CASE WHEN t.issue_type = 'Feature Request' THEN 1 ELSE 0 END) AS feature_request_ticket,
        MAX(CASE WHEN t.issue_type = 'Bug' THEN 1 ELSE 0 END) AS bug_ticket,
        MAX(CASE WHEN t.issue_type = 'UI Issue' THEN 1 ELSE 0 END) AS ui_issue_ticket
    FROM adora a
    LEFT JOIN tickets t
        ON a.user_id = t.user_id
    WHERE a.persona = 'Dev'
        AND a.total_failed_code_export_sessions > 0
        AND a.total_code_export_successful_sessions = 0
    GROUP BY a.user_id, a.persona, a.churned_flag
),
issue_combos AS (
    SELECT
        *,
        -- Added a space BEFORE the plus to make trimming easier
        CONCAT(
            CASE WHEN payment_ticket = 1 THEN 'Payment + ' ELSE '' END,
            CASE WHEN misprompt_ticket = 1 THEN 'Misprompt + ' ELSE '' END,
            CASE WHEN feature_request_ticket = 1 THEN 'Feature Request + ' ELSE '' END,
            CASE WHEN bug_ticket = 1 THEN 'Bug + ' ELSE '' END,
            CASE WHEN ui_issue_ticket = 1 THEN 'UI Issue + ' ELSE '' END
        ) AS issue_combo_raw
    FROM features
),
cleaned_combos AS (
    SELECT
        user_id,
        persona,
        churned_flag,
        CASE 
            WHEN issue_combo_raw = '' THEN 'No Tickets'
            -- RTRIM removes trailing spaces, then TRIM(TRAILING '+'...) removes the last plus
            ELSE RTRIM(RTRIM(issue_combo_raw), '+')
        END AS issue_combo
    FROM issue_combos
)
SELECT
    issue_combo,
    COUNT(*) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) * 1.0 / COUNT(user_id), 4) AS churn_rate
FROM cleaned_combos
GROUP BY issue_combo
ORDER BY total_users DESC;


WITH features AS (
    SELECT
        a.user_id,
        a.persona,
        a.total_sessions,
        a.total_code_exports,
        a.churned_flag,
        MAX(CASE WHEN t.issue_type = 'Payment' THEN 1 ELSE 0 END) AS payment_ticket,
        MAX(CASE WHEN t.issue_type = 'Misprompt' THEN 1 ELSE 0 END) AS misprompt_ticket,
        MAX(CASE WHEN t.issue_type = 'Feature Request' THEN 1 ELSE 0 END) AS feature_request_ticket,
        MAX(CASE WHEN t.issue_type = 'Bug' THEN 1 ELSE 0 END) AS bug_ticket,
        MAX(CASE WHEN t.issue_type = 'UI Issue' THEN 1 ELSE 0 END) AS ui_issue_ticket
    FROM adora a
    LEFT JOIN tickets t
        ON a.user_id = t.user_id
    WHERE a.persona = 'Dev'
        AND a.total_failed_code_export_sessions > 0
        AND a.total_code_export_successful_sessions = 0
    GROUP BY a.user_id, a.persona, a.churned_flag, a.total_code_exports, a.total_sessions
),
issue_combos AS (
    SELECT
        *,
        -- Added a space BEFORE the plus to make trimming easier
        CONCAT(
            CASE WHEN payment_ticket = 1 THEN 'Payment + ' ELSE '' END,
            CASE WHEN misprompt_ticket = 1 THEN 'Misprompt + ' ELSE '' END,
            CASE WHEN feature_request_ticket = 1 THEN 'Feature Request + ' ELSE '' END,
            CASE WHEN bug_ticket = 1 THEN 'Bug + ' ELSE '' END,
            CASE WHEN ui_issue_ticket = 1 THEN 'UI Issue + ' ELSE '' END
        ) AS issue_combo_raw
    FROM features
),
cleaned_combos AS (
    SELECT
        user_id,
        persona,
        total_sessions,
        total_code_exports,
        churned_flag,
        CASE 
            WHEN issue_combo_raw = '' THEN 'No Tickets'
            -- RTRIM removes trailing spaces, then TRIM(TRAILING '+'...) removes the last plus
            ELSE RTRIM(RTRIM(issue_combo_raw), '+')
        END AS issue_combo
    FROM issue_combos
)
SELECT
    persona,
    total_sessions,
    total_code_exports,
    issue_combo,
    COUNT(*) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) * 1.0 / COUNT(user_id), 4) AS churn_rate
FROM cleaned_combos
GROUP BY persona, total_code_exports, total_sessions, issue_combo
ORDER BY total_users DESC;

-- Bin the total sessions and the issue types to bugs vs no bugs.
WITH features AS (
    SELECT
        a.user_id,
        a.persona,
        a.total_code_exports,
        a.churned_flag,
        MAX(CASE WHEN t.issue_type = 'Payment' THEN 1 ELSE 0 END) AS payment_ticket,
        MAX(CASE WHEN t.issue_type = 'Misprompt' THEN 1 ELSE 0 END) AS misprompt_ticket,
        MAX(CASE WHEN t.issue_type = 'Feature Request' THEN 1 ELSE 0 END) AS feature_request_ticket,
        MAX(CASE WHEN t.issue_type = 'Bug' THEN 1 ELSE 0 END) AS bug_ticket,
        MAX(CASE WHEN t.issue_type = 'UI Issue' THEN 1 ELSE 0 END) AS ui_issue_ticket
    FROM adora a
    LEFT JOIN tickets t
        ON a.user_id = t.user_id
    WHERE a.persona = 'Dev'
        AND a.total_failed_code_export_sessions > 0
        AND a.total_code_export_successful_sessions = 0
    GROUP BY a.user_id, a.persona, a.churned_flag, a.total_code_exports
),
issue_combos AS (
    SELECT
        *,
        -- Added a space BEFORE the plus to make trimming easier
        CONCAT(
            CASE WHEN payment_ticket = 1 THEN 'Payment + ' ELSE '' END,
            CASE WHEN misprompt_ticket = 1 THEN 'Misprompt + ' ELSE '' END,
            CASE WHEN feature_request_ticket = 1 THEN 'Feature Request + ' ELSE '' END,
            CASE WHEN bug_ticket = 1 THEN 'Bug + ' ELSE '' END,
            CASE WHEN ui_issue_ticket = 1 THEN 'UI Issue + ' ELSE '' END
        ) AS issue_combo_raw
    FROM features
),
cleaned_combos AS (
    SELECT
        user_id,
        persona,
        total_code_exports,
        churned_flag,
        CASE 
            WHEN issue_combo_raw = '' THEN 'No Tickets'
            -- RTRIM removes trailing spaces, then TRIM(TRAILING '+'...) removes the last plus
            ELSE RTRIM(RTRIM(issue_combo_raw), '+')
        END AS issue_combo
    FROM issue_combos
)
SELECT
    persona,
    CASE
        WHEN total_code_exports = 1 THEN '1'
        WHEN total_code_exports BETWEEN 2 AND 3 THEN '2-3'
        ELSE '4+'
    END AS code_export_zone,
    CASE
        WHEN issue_combo LIKE '%Bug%' THEN 'Bug-involved'
        ELSE 'Bug-free'
    END AS bug_category,
    COUNT(*) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    ROUND(SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) * 1.0 / COUNT(user_id), 4) AS churn_rate
FROM cleaned_combos
GROUP BY persona, total_code_exports, 
    CASE
        WHEN total_code_exports = 1 THEN '1'
        WHEN total_code_exports BETWEEN 2 AND 3 THEN '2-3'
        ELSE '4+'
    END,
    CASE
        WHEN issue_combo LIKE '%Bug%' THEN 'Bug-involved'
        ELSE 'Bug-free'
    END
ORDER BY total_users DESC;



-- Wasn't expecting the numbers, so I am doing
SELECT
    persona
    total_tickets, 
    ignored_ticket_ratio,
    responded_tickets_ratio,
    resolved_ticket_ratio,
    unresolved_ticket_ratio,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users
FROM adora
WHERE persona NOT IN ('Hybrid', 'Ghost')
AND support_contact_category = 'Single Agent'
GROUP BY  persona,
    total_tickets, 
    ignored_ticket_ratio,
    responded_tickets_ratio,
    resolved_ticket_ratio,

    unresolved_ticket_ratio



-- Do resolution bands
SELECT
    persona,
    CASE
        WHEN resolved_ticket_ratio BETWEEN 0 AND 0.49 THEN 'Low Resolution'
        WHEN resolved_ticket_ratio BETWEEN 0.5 AND 0.79 THEN 'Medium Resolution'
        WHEN resolved_ticket_ratio >= 0.8 THEN 'High Resolution'
        ELSE 'N/A'
    END AS resolution_band,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    CONCAT(ROUND(100.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/ COUNT(user_id), 2), '%') AS churn_rate
FROM adora
WHERE persona NOT IN ('Ghost', 'Hybrid')
    AND support_contact_category = 'Single Agent'
    AND resolved_ticket_ratio IS NOT NULL
GROUP BY  persona,
    CASE
        WHEN resolved_ticket_ratio BETWEEN 0 AND 0.49 THEN 'Low Resolution'
        WHEN resolved_ticket_ratio BETWEEN 0.5 AND 0.79 THEN 'Medium Resolution'
        WHEN resolved_ticket_ratio >= 0.8 THEN 'High Resolution'
        ELSE 'N/A'
    END
ORDER BY churn_rate DESC;


-- Look at the support contact categories
SELECT
    persona,
    support_contact_category,
    CASE
        WHEN resolved_ticket_ratio BETWEEN 0 AND 0.49 THEN 'Low Resolution'
        WHEN resolved_ticket_ratio BETWEEN 0.5 AND 0.79 THEN 'Medium Resolution'
        WHEN resolved_ticket_ratio >= 0.8 THEN 'High Resolution'
        ELSE 'N/A'
    END AS resolution_band,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    CONCAT(ROUND(100.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/ COUNT(user_id), 2), '%') AS churn_rate
FROM adora
WHERE persona NOT IN ('Ghost', 'Hybrid')
    AND resolved_ticket_ratio IS NOT NULL
GROUP BY  persona, support_contact_category,
    CASE
        WHEN resolved_ticket_ratio BETWEEN 0 AND 0.49 THEN 'Low Resolution'
        WHEN resolved_ticket_ratio BETWEEN 0.5 AND 0.79 THEN 'Medium Resolution'
        WHEN resolved_ticket_ratio >= 0.8 THEN 'High Resolution'
        ELSE 'N/A'
    END
ORDER BY churn_rate DESC;

-- Find users with repeat complaints
SELECT *
FROM tickets

-- How many customers have repeat complaints?
WITH repeat AS (
    SELECT
        user_id,
        issue_type,
        COUNT(*) AS total_tickets,
        CASE WHEN COUNT(*) > 1 THEN 1 ELSE 0 END AS repeat_ticket
    FROM tickets
    GROUP BY user_id, issue_type
)
SELECT
    COUNT(user_id) AS customers_with_repeat_complaints
FROM repeat
WHERE repeat_ticket = 1

-- Which issue types are producing the most repeat complaints?
WITH repeat AS (
    SELECT
        user_id,
        issue_type,
        COUNT(*) AS tickets_per_issue_type
    FROM tickets
    GROUP BY user_id, issue_type
),
repeat_flags AS (
    SELECT
        user_id,
        issue_type
    FROM repeat
    WHERE tickets_per_issue_type > 1
)
SELECT
    issue_type,
    COUNT(user_id) AS customers_with_repeat_complaints
FROM repeat_flags
GROUP BY issue_type
ORDER BY customers_with_repeat_complaints DESC;

-- Onboarding
-- Is there a link between activation and churn?
SELECT
    a.persona,
    CASE
        WHEN o.activation_time_days IS NULL THEN 'No Activation'
        WHEN o.activation_time_days <= 3 THEN 'Fast Activation'
        WHEN o.activation_time_days BETWEEN 4 AND 7 THEN 'Moderate Activation'
        ELSE 'Slow Activation'
    END AS activation_status,
    COUNT(a.user_id) AS total_customers,
    SUM(CASE WHEN a.churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    CONCAT(ROUND(100.0 * SUM(CASE WHEN a.churned_flag = 1 THEN 1 ELSE 0 END)/ COUNT(a.user_id), 2), '%') AS churn_rate
FROM onboarding o
INNER JOIN adora a
    ON o.user_id = a.user_id
WHERE a.persona NOT IN ('Ghost', 'Hybrid')
GROUP BY a.persona,
      CASE
        WHEN o.activation_time_days IS NULL THEN 'No Activation'
        WHEN o.activation_time_days <= 3 THEN 'Fast Activation'
        WHEN o.activation_time_days BETWEEN 4 AND 7 THEN 'Moderate Activation'
        ELSE 'Slow Activation'
    END
ORDER BY churn_rate DESC;

-- So what about the product is making them churn?

SELECT
    persona,
    total_sessions,
    COUNT(*) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    CONCAT(ROUND(100.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/ COUNT(user_id), 2),'%') AS churn_rate
FROM adora
WHERE total_sessions IS NOT NULL
    AND persona NOT IN('Ghost', 'Hybrid')
GROUP BY persona, total_sessions
ORDER BY churn_rate DESC;

-- Look at the usage intensity
SELECT
    persona,
    usage_intensity,
    total_sessions,
    COUNT(*) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    CONCAT(ROUND(100.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/ COUNT(user_id), 2),'%') AS churn_rate
FROM adora
WHERE total_sessions IS NOT NULL
    AND persona NOT IN('Ghost', 'Hybrid')
GROUP BY persona, usage_intensity, total_sessions
ORDER BY churn_rate DESC;

-- Look at friction and frustration level
SELECT
    persona,
    usage_intensity,
    friction_level,
    experience_level,
    total_sessions,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    CONCAT(ROUND(100.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/ COUNT(user_id), 2),'%') AS churn_rate
FROM adora 
WHERE total_sessions IS NOT NULL
    AND persona NOT IN('Ghost', 'Hybrid')
GROUP BY persona, usage_intensity, total_sessions, friction_level, experience_level
ORDER BY churn_rate DESC;

-- Look at each persona (Founder first)
SELECT
    a.persona,
    a.usage_intensity,
    f.friction_level,
    f.frustration_level,
    a.total_sessions,
    COUNT(*) AS total_users,
    SUM(CASE WHEN a.churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    CONCAT(ROUND(100.0 * SUM(CASE WHEN a.churned_flag = 1 THEN 1 ELSE 0 END)/ COUNT(user_id), 2),'%') AS churn_rate
FROM adora a
INNER JOIN feature_usage f
    ON a.user_id = f.user_id
WHERE a.total_sessions IS NOT NULL
    AND a.persona = 'Founder'
GROUP BY a.persona, a.usage_intensity, a.total_sessions, f.friction_level, f.frustration_level
ORDER BY total_users DESC;

-- Include support contact
SELECT
    a.persona,
    a.usage_intensity,
    f.friction_level,
    f.frustration_level,
    a.support_contact_category,
    a.total_sessions,
    COUNT(*) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    CONCAT(ROUND(100.0 * SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/ COUNT(user_id), 2),'%') AS churn_rate
FROM adora a
INNER JOIN feature_usage f
    ON a.user_id = f.user_id
WHERE total_sessions IS NOT NULL
    AND persona = 'Founder'
    AND support_contact_category IS NOT NULL
GROUP BY persona, usage_intensity, support_contact_category, total_sessions, friction_level, frustration_level
ORDER BY total_users DESC;


-- Bin total sessions
SELECT
    a.persona,
    a.usage_intensity,
    f.friction_level,
    f.frustration_level,
    a.support_contact_category,
    CASE
        WHEN a.total_sessions BETWEEN 1 AND 3 THEN '1-3'
        WHEN a.total_sessions BETWEEN 4 AND 6 THEN '4-6'
        ELSE '7+'
    END AS session_segment,
    COUNT(a.user_id) AS total_users,
    SUM(CASE WHEN a.churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    CONCAT(ROUND(100.0 * SUM(CASE WHEN a.churned_flag = 1 THEN 1 ELSE 0 END)/ COUNT(a.user_id), 2),'%') AS churn_rate
FROM adora a
INNER JOIN feature_usage f
    ON a.user_id = f.user_id
WHERE total_sessions IS NOT NULL
    AND a.persona = 'Founder'
    AND a.support_contact_category IS NOT NULL
GROUP BY a.persona, a.usage_intensity, a.support_contact_category,
    CASE
        WHEN a.total_sessions BETWEEN 1 AND 3 THEN '1-3'
        WHEN a.total_sessions BETWEEN 4 AND 6 THEN '4-6'
        ELSE '7+'
    END, 
    a.friction_level, f.frustration_level
ORDER BY total_users DESC;

SELECT 
    DISTINCT frustration_level
FROM feature_usage