-- Create Admin Accounts for Darghos TFS
-- Handles existing accounts by deleting and recreating

-- Delete existing accounts if they exist (CASCADE will delete characters too)
DELETE FROM accounts WHERE name IN ('bruno', 'ninao', 'yves');

-- Insert accounts
INSERT INTO `accounts` VALUES
(NULL,'bruno',SHA1('bruno'),'',365,UNIX_TIMESTAMP(),'bruno@darghos.com','0',0,0,1,0,0),
(NULL,'ninao',SHA1('ninao'),'',365,UNIX_TIMESTAMP(),'ninao@darghos.com','0',0,0,1,0,0),
(NULL,'yves',SHA1('yves'),'',365,UNIX_TIMESTAMP(),'yves@darghos.com','0',0,0,1,0,0);

-- Get account IDs
SET @bruno_id = (SELECT id FROM accounts WHERE name = 'bruno');
SET @ninao_id = (SELECT id FROM accounts WHERE name = 'ninao');
SET @yves_id = (SELECT id FROM accounts WHERE name = 'yves');

-- Insert players (exact format from test account)
INSERT INTO `players` VALUES
-- Bruno's characters
(NULL,'Bruno Knight',0,1,@bruno_id,8,4,185,185,4200,68,76,78,58,131,0,0,35,35,0,100,1,95,117,7,_binary '',470,1,0,0,1,0,0,0,'',0,31,0,151200000,2,100,100,100,100,100,0,0,0,0,0,'',0,1,0),
(NULL,'Bruno Sorc',0,1,@bruno_id,200,1,1400,1400,364619811,113,115,95,39,138,0,100,8000,8000,500000000,100,1,95,117,7,_binary '',430,1,0,0,1,0,0,0,'',0,31,0,151200000,2,100,100,100,100,100,0,0,0,0,0,'',0,1,0),
(NULL,'GOD Bruno',0,9,@bruno_id,500,0,50000,50000,2058474800,0,0,0,0,302,0,200,50000,50000,0,200,1,1997,1849,7,_binary '',50000,1,0,0,1,0,0,0,'',0,31,0,151200000,2,100,100,100,100,100,0,0,0,0,0,'',0,1,0),
-- Ninao's characters (female)
(NULL,'Ninao Knight',0,1,@ninao_id,8,4,185,185,4200,68,76,78,58,139,0,0,35,35,0,100,1,95,117,7,_binary '',470,0,0,0,1,0,0,0,'',0,31,0,151200000,2,100,100,100,100,100,0,0,0,0,0,'',0,1,0),
(NULL,'Ninao Sorc',0,1,@ninao_id,200,1,1400,1400,364619811,113,115,95,39,138,0,100,8000,8000,500000000,100,1,95,117,7,_binary '',430,0,0,0,1,0,0,0,'',0,31,0,151200000,2,100,100,100,100,100,0,0,0,0,0,'',0,1,0),
(NULL,'GOD Ninao',0,9,@ninao_id,500,0,50000,50000,2058474800,0,0,0,0,302,0,200,50000,50000,0,200,1,1997,1849,7,_binary '',50000,0,0,0,1,0,0,0,'',0,31,0,151200000,2,100,100,100,100,100,0,0,0,0,0,'',0,1,0),
-- Yves' characters
(NULL,'Yves Knight',0,1,@yves_id,8,4,185,185,4200,68,76,78,58,131,0,0,35,35,0,100,1,95,117,7,_binary '',470,1,0,0,1,0,0,0,'',0,31,0,151200000,2,100,100,100,100,100,0,0,0,0,0,'',0,1,0),
(NULL,'Yves Sorc',0,1,@yves_id,200,1,1400,1400,364619811,113,115,95,39,138,0,100,8000,8000,500000000,100,1,95,117,7,_binary '',430,1,0,0,1,0,0,0,'',0,31,0,151200000,2,100,100,100,100,100,0,0,0,0,0,'',0,1,0),
(NULL,'GOD Yves',0,9,@yves_id,500,0,50000,50000,2058474800,0,0,0,0,302,0,200,50000,50000,0,200,1,1997,1849,7,_binary '',50000,1,0,0,1,0,0,0,'',0,31,0,151200000,2,100,100,100,100,100,0,0,0,0,0,'',0,1,0);

-- Add player skills (use INSERT IGNORE to handle any existing skills)
INSERT IGNORE INTO `player_skills` (`player_id`, `skillid`, `value`, `count`)
SELECT p.id, s.skillid, IF(p.group_id = 9, 100, 10), 0
FROM players p
CROSS JOIN (
    SELECT 0 AS skillid UNION SELECT 1 UNION SELECT 2 UNION
    SELECT 3 UNION SELECT 4 UNION SELECT 5 UNION SELECT 6
) s
WHERE p.account_id IN (@bruno_id, @ninao_id, @yves_id);

-- Summary
SELECT 'Admin accounts created successfully!' as Status;
SELECT a.name as Account, COUNT(p.id) as Characters, a.premdays as 'Premium Days'
FROM accounts a
LEFT JOIN players p ON p.account_id = a.id
WHERE a.name IN ('bruno', 'ninao', 'yves')
GROUP BY a.name;
