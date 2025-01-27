import * as functions from "firebase-functions";
import {Pool} from "pg";
import * as dotenv from "dotenv";

// データベース接続情報
const dbConfig = {
  // user: "postgres",
  // host: "35.185.152.107",
  // database: "test_boulder_app_db",
  // password: "d8@q]kI|HJD&6G|I",
  // port: 5432,
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_DATABASE,
  password: process.env.DB_PASSWORD,
  port: process.env.DB_PORT,
};

// 接続プールを定義
const pool = new Pool(dbConfig);

// エントリポイント
// データベースからデータを取得
exports.getData = functions.https.onRequest(async (req, res) => {
  // どのようなデータが送られてきたのかを把握する
  const requestId = Number(req.query.request_id);

  switch(requestId) {
    // テスト作成：ユーザー情報を取得する処理
    case 1:
      try {
        // フロントエンドからクエリパラメータを取得
        const {gym_id} = req.query;

        // gym_idがないとき，エラーコード400とgym_idがない旨を返信して終了
        if(!gym_id){
            res.status(400).send("gym_id パラメータが必要です");
            return;
        } else {
          // DB接続
          const client = await pool.connect();

          // gym_idを使ったクエリ
          const result = await client.query(
            "SELECT * FROM climbingtypes WHERE gym_id = $1",
            [gym_id]    // パラメータをプレースホルダで安全に渡す
          );

          // DB接続を解放
          client.release();

          // 指定のgym_idが見つからないとき：エラーコード404と見つからない旨を返信
          if(result.rows.length === 0) {
            res.status(404).send(`gym_id: ${gym_id}のデータは見つかりませんでした．`);
            return;
          }

          // 見つかったときの結果を返信
          res.status(200).json(result.rows);
        }
      } catch (error) {
        console.error("Error querying database:", error);
        res.status(500).send("Error querying database");
      }
      break;

    // ツイートを最新順から取得する処理
    case 2:
      try {
        // DB接続
        const client = await pool.connect();

        // クエリ問い合わせ
        const limit = 20;
        const offset = 0;

        const result = await client.query(`
          SELECT
            BLT.tweet_id,
            U.user_name,
            BLT.visited_date,
            BLT.tweeted_date,
            BLT.tweet_contents,
            BLT.liked_counts,
            BLT.movie_url,
            GI.gym_name,
            GI.prefecture
          FROM
            boullogtweet AS BLT
          INNER JOIN
            users AS U
            ON BLT.user_id = U.user_id
          INNER JOIN
            gyminfo AS GI
            ON BLT.gym_id = GI.gym_id
          ORDER BY
            BLT.tweeted_date DESC
          LIMIT ${limit}
          OFFSET ${offset};
        `);

        // DB接続を解放
        client.release();

        // データが見つからないとき：エラーコード404と見つからない旨を返信
        if(result.rows.length === 0) {
          res.status(404).send('データは見つかりませんでした');
          return;
        }

        // 見つかったときの結果を返信
        res.status(200).json(result.rows);
      } catch(error) {
        console.error("Error querying database:", error);
        res.status(500).send("Error querying database");
      }
      break;

    // ユーザー情報を取得する処理
    case 3:
      try{
        // フロントエンドからクエリパラメータを取得
        const {user_id} = req.query;

        // user_idがないとき、エラーコード400とuser_idが送られてきていない旨を返信して終了
        if(!user_id) {
          res.status(400).send("user_idパラメータが必要です");
          return;

        // ユーザー情報取得成功
        } else {
          // DB接続
          const client = await pool.connect();

          // user_idが使ったクエリ
          const result = await client.query(`
            SELECT
              users.user_name,
              users.user_icon_url,
              users.user_introduce,
              users.favorite_gym,
              users.boul_start_date,
              users.email
            FROM
              users;
          `);

          // DB接続を解放
          client.release();

          // データが見つからないとき：エラーコード404と見つからない旨を返信
          if(result.rows.length === 0) {
            res.status(404).send('データは見つかりませんでした');
            return;
          }

          // 見つかった時の結果を返信
          res.status(200).json(result.rows);
        }
      } catch(error) {
        console.error("Error querying database: ", error);
        res.status(500).send("Error querying database");
      }
      break;

    // お気に入りしている人を返す処理
    // DB仕様追加：その関係が作られた時をcreated_atとしてカラム追加
    // 理由)フォローされた順で古参は下に、新規は上になるようにする必要がある
    case 4:
      try{
        // フロントエンドからクエリパラメータを取得
        const {user_id} = req.query;

        // user_idがないとき、エラーコード400と、user_idが送られてきていない旨を返信して終了
        if(!user_id){
          res.status(400).send("user_idパラメータが必要です");
          return;
        } else {
          // DB接続
          const client = await pool.connect();

          // user_idを使った食える
          const result = await client.query(`
            SELECT
              FUR.likee_user_id,
              FUR.created_at, -- 不要かもしれない
              U.user_name,
              GI.gym_id,
              GI.gym_name
            FROM
              favorite_user_relation AS FUR
            INNER JOIN
              users AS U
              ON FUR.likee_user_id = U.user_id
            INNER JOIN
              gyminfo AS GI
              ON U.home_gym_id = GI.gym_id
            WHERE
              FUR.liker_user_id = $1
            ORDER BY
              FUR.created_at DESC;
            `, [user_id]);

            // DB接続を解放
            client.release();

            // データが見つからないとき：エラーコード404と見つからない旨を返信
            if(result.rows.length === 0){
              res.status(404).send("データは見つかりませんでした");
              return;
            }

            // 見つかった時の結果を返信
            res.status(200).json(result.rows);
          }
        } catch(error) {
          console.error("Error querying database: ", error);
          res.status(500).send("Error querying database");
        }
        break;

    // お気に入りされている人(=自分のことをお気に入り登録している人)を返す処理
    // DB仕様追加：その関係が作られた時をcreated_atとしてカラム追加
    // 理由)フォローされた順で古参は下に、新規は上になるようにする必要がある
    case 5:
      try{
        // フロントエンドからクエリパラメータを取得
        const {user_id} = req.query;

        // user_idがないとき、エラーコード400と、user_idが送られてきていない旨を返信して終了
        if(!user_id){
          res.status(400).send("user_idパラメータが必要です");
          return;
        } else {
          // DB接続
          const client = await pool.connect();

          // user_idを使ったクエリ
          const result = await client.query(`
            SELECT
              FUR.liker_user_id,
              FUR.created_at,
              U.user_name,
              GI.gym_id,
              GI.gym_name
            FROM
              favorite_user_relation AS FUR
            INNER JOIN
              users AS U
              ON FUR.liker_user_id = U.user_id
            INNER JOIN
              gyminfo AS GI
              ON U.home_gym_id = GI.gym_id
            WHERE
              FUR.likee_user_id = $1
            ORDER BY
              FUR.created_at DESC;
            `, [user_id]);

          // DB接続を解放
          client.release();

          // データが見つからないとき：エラーコード404と見つからない旨を返信
          if(result.rows.length === 0) {
            res.status(404).send("データは見つかりませんでした");
            return;
          }

          // 見つかった時の結果を返信
          res.status(200).json(result.rows);
        }
      } catch(error) {
        console.error("Error querying database: ", error);
        res.status(500).send("Error querying database");
      }
      break;

    // ツイート情報のうち特にお気に入りユーザー情報を取得する処理
    case 6:
      try{
        // フロントエンドからクエリパラメータを取得
        const {user_id} = req.query;

        // user_idがないとき、エラーコード409とuser_idが送られてきていない旨を返信して終了
        if(!user_id){
          // ログインしていないときは、user_idはnullである(と予想される)
          // ので、この部分の処理はしっかり実装する必要がありそう。。。
          res.status(400).send("user_idパラメータが必要です");
          return;
        } else {
          // DB接続
          const client = await pool.connect();

          // クエリ問い合わせ
          const limit = 20;
          const offset = 0;

          // user_idを使ったクエリ
          const result = await client.query(`
            SELECT
              BLT.tweet_id,
              U.user_name,
              FUR.likee_user_id,
              BLT.visited_date,
              BLT.tweeted_date,
              BLT.tweet_contents,
              BLT.liked_counts,
              BLT.movie_url,
              GI.gym_name,
              GI.prefecture
            FROM
              boullogtweet AS BLT
            INNER JOIN
              users AS U
              ON BLT.user_id = U.user_id
            INNER JOIN
              gyminfo AS GI
              ON BLT.gym_id = GI.gym_id
            INNER JOIN
              favorite_user_relation AS FUR
              ON FUR.likee_user_id = BLT.user_id
            WHERE
              FUR.liker_user_id = $1
            ORDER BY
              BLT.tweeted_date DESC
            LIMIT ${limit}
            OFFSET ${offset};
            `, [user_id]);

            // DB接続を解放
            client.release();

            // データが見つからないとき：エラーコード404と見つからない旨を返信
            if(result.rows.length === 0) {
              res.status(404).send("データは見つかりませんでした");
              return;
            }

            // 見つかった時の結果を返信
            res.status(200).json(result.rows);
          }
        } catch(error){
          console.error("Error querying database: ",error);
          res.status(500).send("Error querying database");
        }
        break;

      // 無効なIDが送られてきたとき
      default:
        try {
          // gym_idがないとき，エラーコード400とgym_idがない旨を返信して終了
          res.status(400).send("無効なリクエストIDです.");
          return;
        } catch (error) {
          console.error("Error querying database:", error);
          res.status(500).send("Error querying database");
        }
        break;
  }
});
