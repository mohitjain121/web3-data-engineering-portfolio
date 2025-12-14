/* Description: Calculate Ido hours, number of projects, average filled ratio, and median filled ratio. */

WITH 
    acceleraytor_shini (
        project_name,
        token_name,
        price_per_token_usdc,
        raised_amount_usdc,
        ratio_filled,
        program_id,
        token_id,
        start_time,
        end_time,
        token_amount,
        total_tickets_deposited,
        allocation,
        max_win_lotteries
    ) AS (
        VALUES 
            ('Hawksight', 'HAWK', '0.012', '360000', '61.59', 'J8SYuY4PHJ8Z5FGDUvmzREKqXRSMY9zr88D6szpbMKNg', 'BKipkearSqAUdNKa1WDstvcMjoPsSKBuNyvKDQDDu9WE', '1650448800', '1650492000', '30000000', '369553', '60', '6000'),
            ('Nirvana', 'prANA', '2', '250000', '45.53', '3XJpeTMso92CxkNEKp9n6cBtRu89FsC3cUerkGUGtsSp', 'PRAxfbouRoJ9yZqhyejEAH6RvjJ86Y82vfiZTBSM3xG', '1649124000', '1649167200', '125000', '227657', '50', '5000'),
            ('Zebec', 'ZBC', '0.021', '1050000', '25.71', '3dzFshf1hTJ4xLt8uG87cGFA3fzBmUtT1hoVFc3vNPbN', 'zebeczgi5fSEtbpfQKVZKCJ3WgYXxjkMUkNNx7fLKAF', '1647316800', '1647360000', '50000000', '257075', '105', '10000'),
            ('Yawww', 'YAW', '0.2', '1500000', '26.38', 'ELmdR1aviPeBcJPPSA3UcKHZKBKgSoCrAKyUbXCfFW9H', 'YAWtS7vWCSRPckx1agB6sKidVXiXiDUfehXdEUSRGKE', '1646834400', '1646877600', '7500000', '316566', '125', '12000'),
            ('Space Falcon', 'FCON', '0.002', '500000', '31.4', '3Ebtuv5yEqMGLFXmt1eESwCa28pkwnkJXKr1FxrvLtiV', 'HovGjrBGTfna4dvg6exkMxXuexB3tUfEZKcut8AWowXj', '1643025600', '1643068800', '250000000', '313968', '50', '10000'),
            ('Realy', 'REAL', '1', '500000', '25.63', 'J4FwTbrLf4xMu6QMHFbmFRxv3KbZmsA2oUVEoXrR61a2', 'AD27ov5fVU2XzwsbvnFvb1JpCBaCB5dRXrczV9CqSVGb', '1639051200', '1639108800', '500000', '256342', '50', '10000'),
            ('RunNode', 'RUN', '0.06', '1000000.02', '18.08', 'BnoL9CM6FFRV3fyYAdfpvLnXkgRGXC1MkYFAriDXGuiX', '6F9XriABHfWhit6zmMUYAQBSy6XK5VF1cHXuW5LDpRtC', '1638792000', '1638835200', '16666667', '226001', '80', '12500'),
            ('TabTrader', 'TTT', '0.1', '1000000', '20.36', '6vr62dLQL1Cwc8gP5RvPUqQ1JxAeP5kDayzghfLbCo7A', 'FNFKRV3V8DtA3gVJN6UshMiLGYA8izxFwkNWmJbFjmRj', '1638360000', '1638403200', '10000000', '203597', '100', '10000'),
            ('DeFi Land', 'DFL', '0.005', '350000', '32.63', 'DTfvaFt5bZiS1Ak8S7dbviTvj5Gwamb4NZewV1prdPzN', 'DFL1zNkaGPWm1BqAVqRjCZvHmwTFrEaJtbzJWgseoNJh', '1637679600', '1637766000', '70000000', '163130', '70', '5000'),
            ('Genopets', 'GENE', '0.8', '400000', '28.23', 'DGBnb4xRW3oZNa14F8h8WgsDWPFZQoX9Ffem9pPL8t1g', 'GENEtH5amGSi8kHAtQoezp1XEXwZJ8vcuePYnXdKrMYz', '1637150400', '1637193600', '500000', '141165', '80', '5000'),
            ('Grape Protocol', 'GRAPE', '0.02', '600000', '13.8', 'E4CvLEhwih2BekPtoAExKg4hFDxAnKGehC8nsEiKVoJy', '8upjSpvjcdpuzhfR1zriwg5NXkwDruejqNE9WNbPRtyA', '1631016000', '1631059200', '30000000', '82795', '100', '6000'),
            ('Star Atlas', 'ATLAS', '0.00138', '248400', '34.37', '5VUvtxLeEZhqw22gLb47oKT4zi9MfnD9Lm8wtoXoxXe2', 'ATLASXmbPQxBUYbxPsV97usA3fPQYEqzQBUHgiFCUsXx', '1630497600', '1630540800', '180000000', '123743', '69', '3600'),
            ('Star Atlas X', 'POLIS', '0.138', '248400.', '33.73', 'FzwVZtojkp2PMhReaqmw1a42pz9rvk9vE9MunCNUkDvM', 'poLisWXnNRwC6oBu1vHiuKQzFjGL4XDSu4g9qjz9qVk', '1630497600', '1630540800', '1800000', '121426', '69', '3600'),
            ('Only1', 'LIKE', '0.06', '100000.02', '34.55', '6tVhfpkvg4JTYpDCrDgjb5tAEFSzvpZXLgPtAos5xThD', '3bRTivrVsitbmCTGtqwp7hxXPsybkjn4XLNtPsHqa3zR', '1627905600', '1627920000', '1666667', '69093', '50', '2000'),
            ('Solrise', 'SLRS', '0.05', '100000', '27.34', '6djgqw4EXwjGJMPuxH43RdCih5DQgwop1UK5Wk2FDvWt', 'SLRSSpSLUTP7okbCUBYStWCo1vUgyt775faPqz8HUMr', '1625486400', '1625500800', '2000000', '54684', '50', '2000'),
            ('Synthetify', 'SNY', '1.5', '1050000', '5.26', '9aAMMBcRVfPEa7quoRyofR3rG7qF4QJTehUhV3o1mPzf', '4dmKkXNHdgYsXqBHCuMikNQWwVomZURhYvkkX5c4pQ7y', '1624968000', '1624982400', '700000', '55188', '100', '10500')
    )
SELECT 
    CONCAT(ROUND((end_time - start_time) / 3600), ' Hours') AS ido_hours,
    COUNT(project_name) AS number_projects,
    AVG(ratio_filled) AS avg_filled,
    PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY ratio_filled) AS med_filled
FROM 
    acceleraytor_shini
GROUP BY 1;