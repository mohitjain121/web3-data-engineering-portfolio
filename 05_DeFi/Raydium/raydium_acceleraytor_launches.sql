/* Description: Solana account activity query */
SELECT
  `block_date` AS datex,
  CASE
    -- Hawk
    WHEN address = 'J8SYuY4PHJ8Z5FGDUvmzREKqXRSMY9zr88D6szpbMKNg' THEN 'HAWK'
    -- prANA
    WHEN address = '3XJpeTMso92CxkNEKp9n6cBtRu89FsC3cUerkGUGtsSp' THEN 'prANA'
    -- ZBC
    WHEN address = '3dzFshf1hTJ4xLt8uG87cGFA3fzBmUtT1hoVFc3vNPbN' THEN 'ZBC'
    -- YAW
    WHEN address = 'ELmdR1aviPeBcJPPSA3UcKHZKBKgSoCrAKyUbXCfFW9H' THEN 'YAW'
    -- FCON
    WHEN address = '3Ebtuv5yEqMGLFXmt1eESwCa28pkwnkJXKr1FxrvLtiV' THEN 'FCON'
    -- REAL
    WHEN address = 'J4FwTbrLf4xMu6QMHFbmFRxv3KbZmsA2oUVEoXrR61a2' THEN 'REAL'
    -- RUN
    WHEN address = 'BnoL9CM6FFRV3fyYAdfpvLnXkgRGXC1MkYFAriDXGuiX' THEN 'RUN'
    -- TTT
    WHEN address = '6vr62dLQL1Cwc8gP5RvPUqQ1JxAeP5kDayzghfLbCo7A' THEN 'TTT'
    -- DFL
    WHEN address = 'DTfvaFt5bZiS1Ak8S7dbviTvj5Gwamb4NZewV1prdPzN' THEN 'DFL'
    -- GENE
    WHEN address = 'DGBnb4xRW3oZNa14F8h8WgsDWPFZQoX9Ffem9pPL8t1g' THEN 'GENE'
    -- GRAPE
    WHEN address = 'E4CvLEhwih2BekPtoAExKg4hFDxAnKGehC8nsEiKVoJy' THEN 'GRAPE'
    -- ATLAS
    WHEN address = '5VUvtxLeEZhqw22gLb47oKT4zi9MfnD9Lm8wtoXoxXe2' THEN 'ATLAS'
    -- POLIS
    WHEN address = 'FzwVZtojkp2PMhReaqmw1a42pz9rvk9vE9MunCNUkDvM' THEN 'POLIS'
    -- LIKE
    WHEN address = '6tVhfpkvg4JTYpDCrDgjb5tAEFSzvpZXLgPtAos5xThD' THEN 'LIKE'
    -- SLRS
    WHEN address = '6djgqw4EXwjGJMPuxH43RdCih5DQgwop1UK5Wk2FDvWt' THEN 'SLRS'
    -- SNY
    WHEN address = '9aAMMBcRVfPEa7quoRyofR3rG7qF4QJTehUhV3o1mPzf' THEN 'SNY'
  END AS Project_Name,
  COUNT(tx_id) AS txns
FROM
  `solana`.`account_activity`
WHERE
  tx_success = TRUE
  AND block_time >= '2021-06-29'
  AND address IN (
    'J8SYuY4PHJ8Z5FGDUvmzREKqXRSMY9zr88D6szpbMKNg',
    '3XJpeTMso92CxkNEKp9n6cBtRu89FsC3cUerkGUGtsSp',
    '3dzFshf1hTJ4xLt8uG87cGFA3fzBmUtT1hoVFc3vNPbN',
    'ELmdR1aviPeBcJPPSA3UcKHZKBKgSoCrAKyUbXCfFW9H',
    '3Ebtuv5yEqMGLFXmt1eESwCa28pkwnkJXKr1FxrvLtiV',
    'J4FwTbrLf4xMu6QMHFbmFRxv3KbZmsA2oUVEoXrR61a2',
    'BnoL9CM6FFRV3fyYAdfpvLnXkgRGXC1MkYFAriDXGuiX',
    '6vr62dLQL1Cwc8gP5RvPUqQ1JxAeP5kDayzghfLbCo7A',
    'DTfvaFt5bZiS1Ak8S7dbviTvj5Gwamb4NZewV1prdPzN',
    'DGBnb4xRW3oZNa14F8h8WgsDWPFZQoX9Ffem9pPL8t1g',
    'E4CvLEhwih2BekPtoAExKg4hFDxAnKGehC8nsEiKVoJy',
    '5VUvtxLeEZhqw22gLb47oKT4zi9MfnD9Lm8wtoXoxXe2',
    'FzwVZtojkp2PMhReaqmw1a42pz9rvk9vE9MunCNUkDvM',
    '6tVhfpkvg4JTYpDCrDgjb5tAEFSzvpZXLgPtAos5xThD',
    '6djgqw4EXwjGJMPuxH43RdCih5DQgwop1UK5Wk2FDvWt',
    '9aAMMBcRVfPEa7quoRyofR3rG7qF4QJTehUhV3o1mPzf'
  )
GROUP BY
  `block_date`,
  Project_Name