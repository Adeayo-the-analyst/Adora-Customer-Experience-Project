-- Adora Diagnostic Project
-- To understand the factors behind customer churn for adora
SELECT
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users
FROM adora

-- What are the numbers for the personas?
SELECT
    persona,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users
FROM adora
GROUP BY persona

-- Now I want to examine the friction
SELECT
    persona,
    friction_level,
    onboarding_status,
    COUNT(*) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users
FROM adora
--WHERE friction_level = null
GROUP BY persona, friction_level, onboarding_status

SELECT
    persona,
    fail_rate,
    COUNT(*) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users,
    CONCAT(ROUND(SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END)/COUNT(*), 2), '%') AS churn_rate
FROM adora
WHERE fail_rate IS NOT NULL
GROUP BY persona, fail_rate

--Look at the friction level per persona and see if there is a link to onboarding status
SELECT
    persona,
    friction_level,
    onboarding_status,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users
FROM adora
GROUP BY persona, friction_level, onboarding_status
ORDER BY total_users DESC;

-- See where the signup channel plays a role in churn
SELECT
    persona,
    signup_channel_id,
    onboarding_status,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users
FROM adora
WHERE persona <> 'ghost'
GROUP BY persona, signup_channel_id, onboarding_status
ORDER BY total_users

SELECT
    persona,
    usage_intensity,
    onboarding_status,
    friction_level,
    signup_channel_id,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users
FROM adora 
WHERE persona <> 'ghost'
AND usage_intensity <> 'N/A'
AND friction_level <> 'null'
GROUP BY persona, usage_intensity, onboarding_status, friction_level, signup_channel_id

SELECT
    persona, 
    onboarding_status,
    fail_rate,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users
FROM adora
WHERE persona <> 'ghost'
AND usage_intensity <> 'N/A'
AND fail_rate IS NOT NULL
GROUP BY persona, onboarding_status, fail_rate
ORDER BY total_users DESC;


SELECT
    persona,
    error_rate,
    fail_rate,
    onboarding_status,
    signup_channel_id,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users
FROM adora
WHERE persona <> 'ghost'
    AND fail_rate IS NOT NULL
    AND error_rate IS NOT NULL
GROUP BY persona, fail_rate, onboarding_status, error_rate, signup_channel_id
ORDER BY total_users DESC;

SELECT
    persona,
    usage_intensity,
    ROUND(AVG(average_session_duration), 2) AS avg_session_duration,
    friction_level,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users
FROM adora
WHERE persona <> 'ghost'
AND friction_level <> 'null'
GROUP BY persona, usage_intensity, friction_level
ORDER BY total_users DESC;

SELECT
    persona,
    error_rate,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users
FROM adora
WHERE persona <> 'ghost'
    AND error_rate IS NOT NULL
GROUP BY persona, error_rate
ORDER BY total_users DESC;

SELECT
    persona,
    error_rate,
    fail_rate,
    usage_intensity,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users
FROM adora
WHERE persona <> 'ghost'
    AND error_rate IS NOT NULL
    AND fail_rate IS NOT NULL
    AND usage_intensity <> 'null'
GROUP BY persona, error_rate, fail_rate, usage_intensity
ORDER BY total_users DESC;

SELECT
    persona,
    error_rate,
    fail_rate,
    usage_intensity,
    support_contact_category,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users
FROM adora
WHERE persona <> 'ghost'
    AND error_rate IS NOT NULL
    AND fail_rate IS NOT NULL
    AND usage_intensity <> 'null'
    AND support_contact_category IS NOT NULL
GROUP BY persona, error_rate, fail_rate, usage_intensity, support_contact_category
ORDER BY total_users DESC;

SELECT
    persona,
    plan_type_id AS plan_type,
    onboarding_status,
    usage_intensity,
    fail_rate,
    error_rate,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users
FROM adora
WHERE persona <> 'ghost'
    AND onboarding_status <> 'null'
    AND fail_rate IS NOT NULL
    AND error_rate IS NOT NULL
    AND usage_intensity <> 'null'
GROUP BY persona, plan_type_id, onboarding_status, usage_intensity, fail_rate, error_rate
ORDER BY total_users DESC;

SELECT
    persona,
    ROUND(deployment_focus, 2) AS deployment_focus,
    ROUND(code_export_focus, 2) AS code_focus,
    ROUND(app_build_focus, 2) AS app_build_focus,
    ROUND(design_focus, 2) AS design_focus,
    ROUND(AI_focus, 2) AS AI_focus,
    fail_rate,
    error_rate,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users
FROM adora
WHERE deployment_focus IS NOT NULL
    AND code_export_focus IS NOT NULL
    AND app_build_focus IS NOT NULL
    AND design_focus IS NOT NULL
    AND AI_focus IS NOT NULL
GROUP BY 
    persona, 
    code_export_focus, 
    app_build_focus, deployment_focus, design_focus, AI_focus,
    error_rate, fail_rate
ORDER BY total_users;

SELECT
    persona,
    deployment_focus,
    error_rate,
    fail_rate,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users
FROM adora
WHERE persona = 'Founder'
    AND deployment_focus IS NOT NULL
    AND error_rate IS NOT NULL
    AND fail_rate IS NOT NULL
GROUP BY persona, deployment_focus, error_rate, fail_rate
SELECT
FROM adora
WHERE persona <> 'ghost'

SELECT
    persona,
    app_build_focus,
    error_rate,
    fail_rate,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users
FROM adora
WHERE persona = 'Founder'
    AND app_build_focus IS NOT NULL
    AND error_rate IS NOT NULL
    AND fail_rate IS NOT NULL
GROUP BY persona, app_build_focus, error_rate, fail_rate
ORDER BY total_users DESC;


SELECT
    persona,
    app_build_focus,
    deployment_focus,
    AI_focus,
    design_focus,
    code_export_focus,
    error_rate,
    fail_rate,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users
FROM adora
WHERE persona = 'Founder'
    AND error_rate IS NOT NULL
    AND fail_rate IS NOT NULL
GROUP BY persona, app_build_focus, error_rate, fail_rate, deployment_focus,
    AI_focus,
    design_focus,
    code_export_focus
ORDER BY total_users DESC;

SELECT 
    persona,
    total_deployments,
    total_failed_deployments,
    churned_flag
FROM adora
WHERE persona = 'Founder'
    AND total_deployments IS NOT NULL

SELECT
    persona,
    app_build_focus,
    deployment_focus,
    AI_focus,
    design_focus,
    code_export_focus,
    error_rate,
    fail_rate,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users
FROM adora
WHERE persona = 'App Builder'
    AND error_rate IS NOT NULL
    AND fail_rate IS NOT NULL
GROUP BY persona, app_build_focus, error_rate, fail_rate, deployment_focus,
    AI_focus,
    design_focus,
    code_export_focus
ORDER BY total_users DESC;

SELECT
    persona,
    app_build_focus,
    deployment_focus,
    AI_focus,
    design_focus,
    code_export_focus,
    error_rate,
    fail_rate,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users
FROM adora
WHERE persona = 'Designer'
    AND error_rate IS NOT NULL
    AND fail_rate IS NOT NULL
GROUP BY persona, app_build_focus, error_rate, fail_rate, deployment_focus,
    AI_focus,
    design_focus,
    code_export_focus
ORDER BY total_users DESC;

SELECT
    persona,
    app_build_focus,
    deployment_focus,
    usage_intensity,
    total_sessions,
    AI_focus,
    design_focus,
    code_export_focus,
    error_rate,
    fail_rate,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users
FROM adora
WHERE persona = 'Designer'
    AND error_rate IS NOT NULL
    AND fail_rate IS NOT NULL
GROUP BY persona, app_build_focus, error_rate, fail_rate, deployment_focus,
    AI_focus,
    design_focus,
    code_export_focus, usage_intensity, total_sessions
ORDER BY total_users DESC;

SELECT
    persona,
    total_deployments,
    total_failed_deployments,
    total_successful_deployments,
    COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users
FROM adora
WHERE persona <> 'Ghost'
    AND persona = 'Founder'
    AND total_deployments IS NOT NULL
GROUP BY persona, total_deployments, total_failed_deployments, total_successful_deployments
ORDER BY total_users DESC;

SELECT
    persona,
    total_deployments,
    total_failed_deployments,
    total_code_exports,
    total_failed_code_export_sessions,
    total_AI_use,
    total_failed_AI_use_sessions,
    total_designs,
    total_failed_designs,
    total_app_build_attempts,
    total_failed_app_builds,
        COUNT(user_id) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users
FROM adora
WHERE persona = 'Founder'
    AND total_deployments = 0
GROUP BY     persona,
    total_deployments,
    total_failed_deployments,
    total_code_exports,
    total_failed_code_export_sessions,
    total_AI_use,
    total_failed_AI_use_sessions,
    total_designs,
    total_failed_designs,
    total_app_build_attempts,
    total_failed_app_builds

SELECT
    persona,
    total_app_build_attempts,
    total_failed_app_builds,
    total_AI_use,
    total_failed_AI_use_sessions,
    total_code_exports,
    total_failed_code_export_sessions,
    total_designs,
    total_failed_designs,
    COUNT(*) AS total_users,
    SUM(CASE WHEN churned_flag = 1 THEN 1 ELSE 0 END) AS churned_users
FROM adora
WHERE persona = 'Founder'
GROUP BY persona,
    total_app_build_attempts,
    total_failed_app_builds,
    total_AI_use,
    total_failed_AI_use_sessions,
    total_code_exports,
    total_failed_code_export_sessions,
    total_designs,
    total_failed_designs


SELECT
FROM adora
WHERE persona <> 'ghost'