import * as functions from "firebase-functions";
import {Pool} from "pg";
import * as dotenv from "dotenv";

/// ■ 定数
/// - DBアクセス情報を定義
const dbConfig = {
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_DATABASE,
  password: process.env.DB_PASSWORD,
  port: process.env.DB_PORT,
};

/// ■定数定義
/// - 接続プールを定義
const pool = new Pool(dbConfig);

/// ■ 関数
/// - エントリポイント
/// - データベースからデータを取得する
///
/// 引数：
/// - [req] リクエスト情報
/// - [res] レスポンス
exports.getData = functions.https.onRequest(async (req, res) => {
  // リクエストの種別を確認
  const requestId = Number(req.query.request_id);

  switch(requestId) {
    // requestId：1
    // - ユーザー情報を取得する処理
    //
    // クエリパラメータ：
    // gym_id：ジムを識別するID
    case 1:
      try {
        // クエリパラメータを取得
        const {gym_id} = req.query;

        // gym_idがない(null)ケース
        if(!gym_id) {
            // エラーコード400, gym_idがない旨を返信して終了する
            res.status(400).send("gym_id パラメータが必要です");
            return;
        } else {
          // DB接続
          const client = await pool.connect();

          // gym_idに該当するジムの種別を取得
          const result = await client.query(
            "SELECT * FROM climbing_type WHERE gym_id = $1",
            [gym_id]    // パラメータをプレースホルダで安全に渡す
          );

          // DB接続を解放
          client.release();

          // 指定したgym_idが見つからない
          if(result.rows.length === 0) {
            // エラーコード404, gym_idが見つからない旨を返信
            res.status(404).send('gym_id: ${gym_id}のデータは見つかりませんでした．');
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

    // requestId：2
    // ツイートを最新順から取得する処理
    case 2:
      try {
        // DB接続
        const client = await pool.connect();

        // ツイート数を取得するパラメータ
        const limit = 20;
        const offset = 0;

        // ツイートを最新順から時系列順に取得
        const result = await client.query(`
          SELECT
            BLT.tweet_id,
            B.user_name,
            BLT.visited_date,
            BLT.tweeted_date,
            BLT.tweet_contents,
            BLT.liked_counts,
            BLT.movie_url,
            GI.gym_name,
            GI.prefecture
          FROM
            boul_log_tweet AS BLT
          INNER JOIN
            boulder AS B
            ON BLT.user_id = B.user_id
          INNER JOIN
            gym_info AS GI
            ON BLT.gym_id = GI.gym_id
          ORDER BY
            BLT.tweeted_date DESC
          LIMIT ${limit}
          OFFSET ${offset};
        `);

        // DB接続を解放
        client.release();

        // データが見つからないケース
        if(result.rows.length === 0) {
          // エラーコード404,  見つからない旨を返信
          res.status(404).send('データは見つかりませんでした');
          return;
        }

        // 結果を返信
        res.status(200).json(result.rows);
      } catch(error) {
        console.error("Error querying database:", error);
        res.status(500).send("Error querying database");
      }
      break;

    // requestId：3
    // ログイン時に(自身の)ユーザーデータを取得する
    //
    // クエリパラメータ：
    // user_id：ユーザーを識別するID
    case 3:
      try{
        // クエリパラメータを取得
        const {user_id} = req.query;

        // user_idがないケース
        if(!user_id) {
          // エラーコード400, user_idが送られてきていない旨を返信して終了
          res.status(400).send("user_idパラメータが必要です");
          return;
        } else {
          // DB接続
          const client = await pool.connect();
          //
          const result = await client.query(`
            SELECT
              B.user_id,
              B.user_name,
              B.user_icon_url,
              B.user_introduce,
              B.favorite_gym,
              B.boul_start_date,
              B.home_gym_id,
              GI.gym_name,
              B.email,
              B.created_at,
              B.updated_at
            FROM
              boulder AS B
            INNER JOIN
              gym_info AS GI
              ON B.home_gym_id = GI.gym_id
            WHERE
             user_id = $1;
          `,[user_id]);
          // DB接続を解放
          client.release();
          // データが見つからないケース
          if(result.rows.length === 0) {
            // エラーコード404, 見つからない旨を返信
            res.status(404).send('データは見つかりませんでした');
            return;
          }
          // 結果を返信
          res.status(200).json(result.rows);
        }
      } catch(error) {
        console.error("Error querying database: ", error);
        res.status(500).send("Error querying database");
      }
      break;

    // requestId：4
    // マイページのお気に入りで，お気に入りしている人をリストアップする
    //
    // クエリパラメータ：
    // user_id：ユーザーを識別するID
    case 4:
      try{
        // クエリパラメータを取得
        const {user_id} = req.query;

        // user_idがない(null)のケース
        if(!user_id){
          // エラーコード400, user_idが送られてきていない旨を返信して終了
          res.status(400).send("user_idパラメータが必要です");
          return;
        } else {
          // DB接続
          const client = await pool.connect();

          // お気に入りしているユーザー情報を時系列順に取得
          const result = await client.query(`
            SELECT
              FUR.likee_user_id,
              FUR.created_at,
              B.user_name,
              B.user_icon_url,
              GI.gym_id,
              GI.gym_name
            FROM
              favorite_user_relation AS FUR
            INNER JOIN
              boulder AS B
              ON FUR.likee_user_id = B.user_id
            INNER JOIN
              gym_info AS GI
              ON B.home_gym_id = GI.gym_id
            WHERE
              FUR.liker_user_id = $1
            ORDER BY
              FUR.created_at DESC;
            `, [user_id]);

            // DB接続を解放
            client.release();

            // データが見つからないケース
            if(result.rows.length === 0){
              // エラーコード404と見つからない旨を返信
              res.status(404).send("データは見つかりませんでした");
              return;
            }

            // 結果を返信
            res.status(200).json(result.rows);
          }
        } catch(error) {
          console.error("Error querying database: ", error);
          res.status(500).send("Error querying database");
        }
        break;

    // requestId：5
    // お気に入りされている人(=自分のことをお気に入り登録している人)を取得する
    //
    // クエリパラメータ：
    // user_id：ユーザーを識別するID
    case 5:
      try{
        // クエリパラメータを取得
        const {user_id} = req.query;


        // user_idがないケース
        if(!user_id){
          // エラーコード400, user_idが送られてきていない旨を返信して終了
          res.status(400).send("user_idパラメータが必要です");
          return;
        } else {
          // DB接続
          const client = await pool.connect();

          // 自分をお気に入りしている人のレコードを取得する
          const result = await client.query(`
            SELECT
              FUR.liker_user_id,
              FUR.created_at,
              B.user_name,  -- 新規追加
              B.user_icon_url,
              GI.gym_id,
              GI.gym_name
            FROM
              favorite_user_relation AS FUR
            INNER JOIN
              boulder AS B
              ON FUR.liker_user_id = B.user_id
            INNER JOIN
              gym_info AS GI
              ON B.home_gym_id = GI.gym_id
            WHERE
              FUR.likee_user_id = $1
            ORDER BY
              FUR.created_at DESC;
            `, [user_id]);

          // DB接続を解放
          client.release();

          // データが見つからないケース
          if(result.rows.length === 0) {
            //エラーコード404と見つからない旨を返信
            res.status(404).send("データは見つかりませんでした");
            return;
          }

          // 結果を返信
          res.status(200).json(result.rows);
        }
      } catch(error) {
        console.error("Error querying database: ", error);
        res.status(500).send("Error querying database");
      }
      break;

    // requestId：6
    // お気に入り登録しているユーザーのツイートを取得する処理
    //
    // クエリパラメータ：
    // user_id：ユーザーを識別するID
    case 6:
      try{
        // クエリパラメータを取得
        const {user_id} = req.query;

        // user_idがない(null)ケース
        if(!user_id){
          // エラーコード400とuser_idが送られてきていない旨を返信して終了
          // (ToDo)
          // ログインしていないときは、user_idはnullである(と予想される)ので
          // お気に入りユーザーのツイートを出力するタブでどう実装するかを考える必要あり
          res.status(400).send("user_idパラメータが必要です");
          return;
        } else {
          // DB接続
          const client = await pool.connect();

          // ツイート数を取得するパラメータ
          const limit = 20;
          const offset = 0;

          // お気に入りユーザーのツイートを最新順から時系列順に取得
          const result = await client.query(`
            SELECT
              BLT.tweet_id,
              B.user_name,
              FUR.likee_user_id,
              BLT.visited_date,
              BLT.tweeted_date,
              BLT.tweet_contents,
              BLT.liked_counts,
              BLT.movie_url,
              GI.gym_name,
              GI.prefecture
            FROM
              boul_log_tweet AS BLT
            INNER JOIN
              boulder AS B
              ON BLT.user_id = B.user_id
            INNER JOIN
              gym_info AS GI
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
            `, [user_id]
          );

          // DB接続を解放
          client.release();

          // データが見つからないケース
          if(result.rows.length === 0) {
            // エラーコード404, 見つからない旨を返信
            res.status(404).send("データは見つかりませんでした");
            return;
          }

          // 結果を返信
          res.status(200).json(result.rows);
        }
      } catch(error){
        console.error("Error querying database: ",error);
        res.status(500).send("Error querying database");
      }
      break;

    // TO DO：requestId
    // requestId：7
    // 新規登録時にユーザー情報をDBに追加する
    //
    // クエリパラメータ：
    // user_id：ユーザーを識別するID
    // email：メールアドレス
    case 7:
      try{
        // クエリパラメータを取得
        const {user_id, email} = req.query;

        // user_idがないケース
        if(!user_id){
          // エラーコード400, user_idが送られてきていない旨を返信して終了
          res.status(400).send("user_idパラメータが必要です");
          return;
        } else{
          // DB接続
          const client = await pool.connect();

          // 新規登録時にユーザー情報を登録する
          const result = await client.query(`
            INSERT INTO boulder
              (
                user_id,
                user_name,
                user_icon_url,
                self_introduce,
                favorite_gyms,
                boul_start_date,
                home_gym_id,
                email,
                created_at,
                updated_at
              )
            VALUES
              (
                $1,
                '駆け出しボルダー',
                'test-url(みんなが同じURL, つまり同じ画像)からスタートする',
                'はじめまして！',
                '好きなジムを登録してください！'
                NULL,
                NULL,
                $2,
                CURRENT_TIMESTAMP,
                CURRENT_TIMESTAMP
              )
              RETURNING *;
          `, [user_id, email]);

          // DB接続を解放
          client.release();

          // ユーザー情報の挿入が成功されたかを確認する
          // TO DO：正常時，異常時の処理が適切なのかを確認する
          if((result.rowCount ?? 0) === 0)  {
            res.status(201).send("データが正常に挿入されました");
          } else {
            res.status(400).send("データ挿入に失敗しました");
          }
        }
      } catch(error){
        console.error("データ挿入エラー:", error);
        res.status(500).send("サーバーエラーが発生しました");
      }
      break;

    // requestId：8
    // ツイート内容をDBに登録する
    //
    // クエリパラメータ：
    // user_id：ユーザーを識別するID
    // tweet_contents：ツイートの内容
    // visited_date：ジムを訪問した日時
    // gym_id：ジムを識別するID
    case 8:
      try {
        // クエリパラメータを取得
        const {user_id, tweet_contents, visited_date, gym_id} = req.query;

        // user_idがないケース
        if(!user_id){
          // エラーコード400, user_idが送られてきていない旨を返信して終了
          res.status(400).send("user_idパラメータが必要です");
          return;

        } else {
          // DB接続
          const client = await pool.connect();

          // ツイートをDBに登録(挿入, INSERT)する
          const result = await client.query(`
            INSERT INTO boul_log_tweet
              (
                user_id,
                visited_date,
                tweeted_date,
                gym_id,
                tweet_contents,
                liked_count,
                movie_url
              )
            VALUES
              (
                $1,
                $2,
                CURRENT_TIMESTAMP,
                $3,
                $4,
                0,
                NULL
              )
            RETURNING *;
          `, [user_id, visited_date, gym_id, tweet_contents]);

          // DB接続を解放
          client.release();

          // 挿入が成功されたかを確認する
          // TO DO：正常時，異常時の処理が適切なのかを確認する
          if((result.rowCount ?? 0) === 0)  {
            res.status(201).send("データが正常に挿入されました");
          } else {
            res.status(400).send("データ挿入に失敗しました");
          }
        }
      } catch(error){
        console.error("データ挿入エラー:", error);
        res.status(500).send("サーバーエラーが発生しました");
      }
      break;

    // requestId：9
    // ユーザーをお気に入りに登録する
    //
    // クエリパラメータ：
    // liker_user_id：ユーザーを識別するID, お気に入り登録している側のユーザー.
    // likee_user_id：ユーザーを識別するID, お気に入り登録されている側のユーザー．
    case 9:
      try{
        // クエリパラメータを取得
        const {liker_user_id, likee_user_id} = req.query;

        // liker_user_id, likee_user_idがないケース
        if(!liker_user_id || !likee_user_id) {
          // エラーコード400, user_idが送られてきていない旨を返信して終了
          res.status(400).send("liker_user_id, またはlikee_user_idパラメータがありません");
          return;

        } else {
          // DB接続
          const client = await pool.connect();

          // お気に入りしたユーザーのIDを
          // お気に入り関係をまとめたユーザー情報のテーブルに登録する
          const result = await client.query(`
            INSERT INTO favorite_user_relation
              (
                liker_user_id,
                likee_user_id,
                created_at
              )
            VALUES
              (
                $1,
                $2,
                CURRENT_TIMESTAMP
              )
            RETURNING *;
          `, [liker_user_id, likee_user_id]);

          // DB接続を解放
          client.release();

          // 挿入が成功されたかを確認する
          // TO DO：正常時，異常時の処理が適切なのかを確認する
          if((result.rowCount ?? 0) === 0)  {
            res.status(201).send("データが正常に挿入されました");
          } else {
            res.status(400).send("データ挿入に失敗しました");
          }
        }
      } catch(error) {
        console.error("データ挿入エラー:", error);
        res.status(500).send("サーバーエラーが発生しました");
      }
      break;

    // requestId：10
    // 行きたいと思ったジムを. "イキタイ施設"として登録する
    //
    // クエリパラメータ：
    // user_id：ユーザーを識別するID
    // gym_id：ジムを識別する
      case 10:
        try{
          // クエリパラメータを取得
          const {user_id, gym_id} = req.query;

          // user_id, gym_idがないケース
          if(!user_id || !gym_id) {
            // エラーコード400, user_id, gym_igがない旨を返信して終了
            res.status(400).send("user_id, gym_idパラメータがありません");
            return;
          } else{
            // DB接続
            const client = await pool.connect();

            // 行きたいジムを登録する
            const result = await client.query(`
            INSERT INTO wanna_go_relation
              (
                user_id,
                gym_id,
                created_at
              )
            VALUES
              (
                $1,
                $2,
                CURRENT_TIMESTAMP
              )
            RETURNING *;
          `, [user_id, gym_id]);

            // DB接続を解放
            client.release();

            // 挿入が成功されたかを確認する
            // TO DO：
            if((result.rowCount ?? 0) === 0)  {
              res.status(201).send("データが正常に挿入されました");
            } else {
              res.status(400).send("データ挿入に失敗しました");
            }
          }
        } catch(error) {
          console.error("データ挿入エラー:", error);
          res.status(500).send("サーバーエラーが発生しました");
        }
        break;

    // requestId：11
    // 新規登録(サインアップ)時の処理
    // 登録したユーザー情報を, ユーザーテーブル(boulder)に登録する
    //
    // クエリパラメータ：
    // user_id：ユーザーを識別するID
    // email：メールアドレス
    case 11:
      try{
        // クエリパラメータを取得
        const {user_id, email} = req.query;

        // user_idがないケース
        if(!user_id || !email) {
          // エラーコード400, user_id, emailがない旨を返信して終了
          res.status(400).send("user_id, またはemailパラメータがありません");
          return;
        } else{
          // DB接続
          const client = await pool.connect();

          // ユーザー情報を登録する
          const result = await client.query(`
          INSERT INTO boulder
          (
            user_id,
            user_name,
            user_icon_url, -- カラム名確認
            self_introduce,
            favorite_gyms,
            boul_start_date,
            home_gym_id,
            email,
            created_at,
            updated_at
          )
          VALUES
          (
            $1,
            '駆け出しボルダー',
            NULL,
            設定から自己紹介を記入しましょう！,
            設定から好きなジムを記入しましょう！,
            CURRENT_TIMESTAMP,
            NULL,
            $2,
            CURRENT_TIMESTAMP,
            CURRENT_TIMESTAMP
          )
          RETURNING *;
          `, [user_id, email]);

          // DB接続を解放
          client.release();

          // 挿入が成功されたかを確認する
          // TO DO：
          if((result.rowCount ?? 0) === 0)  {
            res.status(201).send("データが正常に挿入されました");
          } else {
            res.status(400).send("データ挿入に失敗しました");
          }
        }
      } catch(error) {
        console.error("データ挿入エラー:", error);
        res.status(500).send("サーバーエラーが発生しました");
      }
      break;

    // requestId：12
    // - 自分のツイートを取得する
    // - マイページで使うことを想定
    //
    // クエリパラメータ：
    // user_id：ユーザーを識別するID
    case 12:
      try{
        // クエリパラメータを取得
        const {user_id} = req.query;

        // user_idがない(null)ケース
        if(!user_id){
          // エラーコード400とuser_idが送られてきていない旨を返信して終了
          res.status(400).send("user_idパラメータが必要です");
          return;
        } else {
          // DB接続
          const client = await pool.connect();

          // ツイート数を取得するパラメータ
          const limit = 20;
          const offset = 0;

          // お気に入りユーザーのツイートを最新順から時系列順に取得
          const result = await client.query(`
            SELECT
              BLT.tweet_id,
              BLT.tweetcontents,
              BLT.visited_date,
              BLT.tweeted_date,
              BLT.liked_count,
              BLT.movie_url,
              B.user_id,
              B.user_name,
              B.user_icon_url,
              GI.gym_id,
              GI.gym_name,
              GI.prefecture,
            FROM
              boul_log_tweet AS BLT
            INNER JOIN
              boulder AS B
              ON BLT.user_id = B.user_id
            INNER JOIN
              gym_info AS GI
              ON BLT.gym_id = GI.gym_id
            WHERE
              BLT.user_id = $1
            ORDER BY
              BLT.visited_date DESC
            LIMIT ${limit}
            OFFSET ${offset};
            `, [user_id]
          );

          // DB接続を解放
          client.release();

          // データが見つからないケース
          if(result.rows.length === 0) {
            // エラーコード404, 見つからない旨を返信
            res.status(404).send("データは見つかりませんでした");
            return;
          }

          // 結果を返信
          res.status(200).json(result.rows);
        }
      } catch(error){
        console.error("Error querying database: ",error);
        res.status(500).send("Error querying database");
      }
      break;

    // request_id: 13
    // -ジムの情報を取得する
    // - アプリ起動時に実行し，アプリ全体で参照する
    //
    // クエリパラメータ：
    // なし
    case 13:
      try{
        // DB接続
        const client = await pool.connect();

        // すべてのジムの情報を取得する
        const result = await client.query(`
          SELECT
            gym_id,
            gym_name,
            latitude,
            longitude
          FROM
            gym_info
        `);

        // DB接続を解放
        client.release();


        // データが見つからないケース
        if(result.rows.length === 0){
          // エラーコード404, 見つからない旨を返信
          res.status(404).send("データは見つかりませんでした");
          return;
        }

        // 結果を返信
        res.status(200).json(result.rows);
      } catch(error) {
        console.error("Error querying database: ", error);
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
