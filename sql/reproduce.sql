-- umamusume succession factor full extraction (device master.mdb, hlpatch /mdb/raw)
-- 全部只读查询，游戏运行中执行；SO 会自动追加 LIMIT 1000，大表按主键区间分页。

-- 1) 因子类型分布（校验总数 = 2577）
SELECT factor_type, COUNT(*) AS n, MIN(factor_id) AS lo, MAX(factor_id) AS hi
FROM succession_factor GROUP BY factor_type ORDER BY factor_type;

-- 2) 全因子行（按类型分页）
SELECT * FROM succession_factor WHERE factor_type = 1;
SELECT * FROM succession_factor WHERE factor_type = 2;
SELECT * FROM succession_factor WHERE factor_id BETWEEN 2000000 AND 2999999;           -- type4 分页1
SELECT * FROM succession_factor WHERE factor_id BETWEEN 2000000 AND 2999999
  AND factor_id > <上页最后一个id>;                                                     -- type4 分页2..
SELECT * FROM succession_factor WHERE factor_id BETWEEN 3000000 AND 3999999;
SELECT * FROM succession_factor WHERE factor_id >= 4000000;
SELECT * FROM succession_factor WHERE factor_id BETWEEN 10000000 AND 19999999;         -- type3 固有

-- 3) 效果表（属性类直接全取；技能提示类 41 按需）
SELECT * FROM succession_factor_effect WHERE target_type IN (1,2,3,4,5,6,7,51)
ORDER BY target_type, factor_group_id, effect_id;
SELECT * FROM succession_factor_effect WHERE factor_group_id BETWEEN 50001 AND 50021;  -- 遗传子/目覚め
-- 技能提示类（target 41，6674 行中的大头）：
SELECT * FROM succession_factor_effect WHERE target_type = 41
  AND factor_group_id BETWEEN 20000 AND 29999;   -- 白技能因子，分页同理
SELECT * FROM succession_factor_effect WHERE factor_group_id >= 100000;                -- 固有因子(绿)

-- 4) 名称/说明/技能名
SELECT "index", text FROM text_data WHERE category = 147 AND "index" BETWEEN 1 AND 1999999;
SELECT "index", text FROM text_data WHERE category = 147 AND "index" BETWEEN 2000000 AND 2999999;
SELECT "index", text FROM text_data WHERE category = 147 AND "index" BETWEEN 2038202 AND 2999999;
SELECT "index", text FROM text_data WHERE category = 147 AND "index" BETWEEN 3000000 AND 3999999;
SELECT "index", text FROM text_data WHERE category = 147 AND "index" BETWEEN 4000000 AND 5999999;
SELECT "index", text FROM text_data WHERE category = 147 AND "index" BETWEEN 10000000 AND 19999999;
SELECT "index", text FROM text_data WHERE category = 172;                              -- 因子说明
SELECT "index", text FROM text_data WHERE category = 47;                               -- 技能名

-- 5) 任意单个因子速查
SELECT * FROM succession_factor WHERE factor_id = 2004902;
SELECT * FROM succession_factor_effect WHERE factor_group_id =
  (SELECT factor_group_id FROM succession_factor WHERE factor_id = 2004902);
SELECT text FROM text_data WHERE category = 147 AND "index" = 2004902;                 -- 名称
SELECT text FROM text_data WHERE category = 172 AND "index" = 2004902;                 -- 说明

-- 注意事项
-- * 非 ASCII 字面量会被 SO 的 URL 解码破坏：用 hex(text) 比较代替中文/日文常量。
-- * text_data 的实体 ID 在 index 列；id 列多数情况下只是 category 的重复。
-- * factor_id = factor_group_id*100 + star（カーニバルボーナス 40001 组除外，组内 effect_id=等级1-7）。
