
### 统计

```js
    db.lit_orders.aggregate([
        {
            $lookup: {
                from: "lit_transactions",
                localField: "id",
                foreignField: "reqId",
                as: "lit_transactions"
            }
        },
		{
			$unwind: "$lit_transactions"
		},
        {
            $project: {
                _id: 0,
                id: 1,
                symbol: 1,
                status: 1,
                submitTime: 1,
                modify_time: 1,
                "lit_transactions.time": 1
            }
        },
		{
			$count: "id"
		}
    ])
```
	
```sql
    SELECT count(*) FROM lit_orders AS o
        INNER JOIN lit_transactions AS t
            ON o."id" = t."reqId"::BIGINT;
```

### 筛选

注意，`symbol` 有变化:
```js
    db.lit_orders.aggregate([
        {
            $lookup: {
                from: "lit_transactions",
                localField: "id",
                foreignField: "reqId",
                as: "lit_transactions"
            }
        },
		{
			$unwind: "$lit_transactions"
		},
        {
            $match: {
                $and: [
                    { symbol: { $in: [603217, 887, 2743, 600768] } },
                    { status: { $in: [4, 7] } }
                ]
            }
        },
        {
            $sort: {
                submitTime: 1,
                modify_time: -1,
				"lit_transactions.id": 1
            }
        },
        {
            $project: {
                _id: 0,
                id: 1,
                symbol: 1,
                status: 1,
                submitTime: 1,
                modify_time: 1,
                "lit_transactions.id": 1
            }
        }
    ])
```
	
```sql
    SELECT o."id",o."symbol",o."status",o."submitTime",o."modify_time",t."id" FROM lit_orders AS o
        INNER JOIN lit_transactions AS t
            ON o."id" = t."reqId"::BIGINT
                WHERE o."symbol" IN ('603217', '000887', '002743', '600768')
                    AND o."status" IN (4, 7)
						ORDER BY o."submitTime" ASC, o."modify_time" DESC, t."id" ASC;
```

### 分页

```js
    db.lit_orders.aggregate([
        {
            $lookup: {
                from: "lit_transactions",
                localField: "id",
                foreignField: "reqId",
                as: "lit_transactions"
            }
        },
		{
			$unwind: "$lit_transactions"
		},
        {
            $match: {
                $and: [
                    { symbol: { $in: [603217, 887, 2743, 600768] } },
                    { status: { $in: [4, 7] } }
                ]
            }
        },
        {
            $sort: {
                submitTime: 1,
                modify_time: -1,
				"lit_transactions.id": 1
            }
        },
        {
            $skip: 10
        },
        {
            $limit: 5
        },
        {
            $project: {
                _id: 0,
                id: 1,
                symbol: 1,
                status: 1,
                submitTime: 1,
                modify_time: 1,
                "lit_transactions.id": 1
            }
        }
    ])
```

```sql
    SELECT o."id",o."symbol",o."status",o."submitTime",o."modify_time",t."id" FROM lit_orders AS o
        INNER JOIN lit_transactions AS t
            ON o."id" = t."reqId"::BIGINT
                WHERE o."symbol" IN ('603217', '000887', '002743', '600768')
                    AND o."status" IN (4, 7)
						ORDER BY o."submitTime" ASC, o."modify_time" DESC, t."id" ASC
							OFFSET 10 LIMIT 5;
```
