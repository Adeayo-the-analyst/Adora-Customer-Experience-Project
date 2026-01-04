
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