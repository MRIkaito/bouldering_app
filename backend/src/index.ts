import * as functions from "firebase-functions";
import {Pool} from "pg";
import { PoolClient } from 'pg';


// データベース接続情報
const dbConfig = {
  user: "postgres",
  host: "35.185.152.107",
  database: "test_boulder_app_db",
  password: "d8@q]kI|HJD&6G|I",
  port: 5432,
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
    case 1:
      try {
        const { liker_user_id, likee_user_id } = req.query;

        // パラメータが揃っているか確認
        if (!liker_user_id || !likee_user_id) {
          res.status(400).send("liker_user_id または likee_user_id が不足しています");
          return;
        }

        // DB接続
        const client = await pool.connect();

        // お気に入り関係が存在するか確認
        const result = await client.query(`
          SELECT * FROM favorite_user_relation
          WHERE liker_user_id = $1 AND likee_user_id = $2
        `, [liker_user_id, likee_user_id]);

        client.release();

        res.status(200).json(result.rows); // 存在するなら1件、なければ空配列
      } catch (error) {
        console.error("お気に入り確認中にエラー:", error);
        res.status(500).send("サーバーエラーが発生しました");
      }
      break;

    // requestId：2
    // ツイートを最新順から取得する処理
    case 2:
      try {
        // クエリパラメータを取得
        const {limit = 20, cursor} = req.query;

        // DB接続
        const client = await pool.connect();

        // DBに投げるクエリを入れる変数
        let query;
        let params;

        if(cursor) {
          // カーソル(tweeted_date)を使ってページネーション
          query =`
          SELECT
            BLT.tweet_id,
            BLT.tweet_contents,
            BLT.visited_date,
            BLT.tweeted_date,
            BLT.liked_counts,
            BLT.movie_url,
            B.user_id,
            B.user_name,
            B.user_icon_url,
            GI.gym_id,
            GI.gym_name,
            GI.prefecture,
            COALESCE(
              (
                SELECT json_agg(media_url)
                FROM boul_log_tweet_media
                WHERE tweet_id = BLT.tweet_id
              ), '[]'
            ) AS media_urls
          FROM
            boul_log_tweet AS BLT
          INNER JOIN
            boulder AS B ON BLT.user_id = B.user_id
          INNER JOIN
            gym_info AS GI ON BLT.gym_id = GI.gym_id
          WHERE BLT.tweeted_date < $1
          ORDER BY BLT.tweeted_date DESC
          LIMIT $2
          `;
          params = [cursor, limit];

        } else {
          // 最初の取得(カーソル無し)
          query =`
          SELECT
            BLT.tweet_id,
            BLT.tweet_contents,
            BLT.visited_date,
            BLT.tweeted_date,
            BLT.liked_counts,
            BLT.movie_url,
            B.user_id,
            B.user_name,
            B.user_icon_url,
            GI.gym_id,
            GI.gym_name,
            GI.prefecture,
            COALESCE(
              (
                SELECT json_agg(media_url)
                FROM boul_log_tweet_media
                WHERE tweet_id = BLT.tweet_id
              ), '[]'
            ) AS media_urls
          FROM
            boul_log_tweet AS BLT
          INNER JOIN
            boulder AS B ON BLT.user_id = B.user_id
          INNER JOIN
            gym_info AS GI ON BLT.gym_id = GI.gym_id
          ORDER BY BLT.tweeted_date DESC
          LIMIT $1;
          `;
          params = [limit];
        }

        // クエリ実行：ツイートを最新準から取得
        const result = await client.query(query, params);

        // DB接続を解放
        client.release();

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

        if(!user_id) {
          // user_idがnullのケース
          // エラーコード400, user_idが送られてきていない旨を返信して終了
          res.status(400).send("user_idパラメータが必要です");
          return;
        } else {
          // DB接続
          const client = await pool.connect();
          // DBからデータ取得
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
              B.updated_at,
              B.birthday,
              B.gender
            FROM
              boulder AS B
            LEFT JOIN
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
              B.user_name,
              B.user_name,
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
        const {user_id, limit = 20, cursor} = req.query;

        // user_idがない(null)ケース
        if(user_id == null){
          // エラーコード400とuser_idが送られてきていない旨を返信して終了
          res.status(400).send("user_idパラメータが必要です");
          return;
        }
        // DB接続
        const client = await pool.connect();

        // DBに投げるクエリを入れる変数
        let query;
        let params;

        if(cursor) {
          // カーソルを使ってpagination
          query =`
            SELECT
              BLT.tweet_id,
              B.user_name,
              B.user_icon_url,
              FUR.likee_user_id AS user_id,
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
            WHERE FUR.liker_user_id = $1
            AND BLT.tweeted_date < $2
            ORDER BY
              BLT.tweeted_date DESC
            LIMIT $3;
          `;
          params = [user_id, cursor, limit];
        } else {
          // 最初の取得(カーソル無し)
          query =`
            SELECT
              BLT.tweet_id,
              B.user_name,
              B.user_icon_url,
              FUR.likee_user_id AS user_id,
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
            LIMIT $2;
          `;
          params = [user_id, limit];
        }

        // お気に入りユーザーのツイートを最新順から時系列順に取得
        const result = await client.query(query, params);

        // DB接続を解放
        client.release();

        // 結果を返信
        res.status(200).json(result.rows);

      } catch(error){
        console.error("Error querying database: ",error);
        res.status(500).send("Error querying database");
      }
      break;

    // requestId：7
    // ツイート内容に紐づくメディア(写真・動画)URLをDBに登録する
    //
    // クエリパラメータ；
    // tweet_id: ツイートID
    // media_url: 写真，または動画のURL
    // meidia_type: 'photo' または 'video'
    case 7:
      try{
        // クエリパラメータ取得
        const {tweet_id, media_url, media_type} = req.query;

        // DB接続
        const client = await pool.connect();

        // メディアURLをDBに登録(挿入・INSERT)
        const result = await client.query(`
          INSERT INTO boul_log_tweet_media
            (
              tweet_id,
              media_url,
              media_type
            )
          VALUES
            (
              $1,
              $2,
              $3
            )
          RETURNING *;
        `, [tweet_id, media_url, media_type]);

        // DB接続を解放
        client.release();

        // 挿入が成功されたか確認
        if((result.rowCount ?? 0) > 0)  {
          res.status(200).json("データが正常に挿入されました");
        } else {
          res.status(400).send("データ挿入に失敗しました");
        }
      } catch(error) {
        console.error("データ挿入エラー：", error);
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
        const {user_id, visited_date, gym_id, tweet_contents,} = req.query;

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
                liked_counts,
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
          if((result.rowCount ?? 0) > 0)  {
            // tweet_idを取得
            const insertedTweetId = result.rows[0].tweet_id;

            // JSON形式で返す
            res.status(200).json({
              message: "データが正常に挿入されました",
              tweet_id: insertedTweetId
            });
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
          if((result.rowCount ?? 0) > 0)  {
            res.status(200).send("データが正常に挿入されました");
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
    // ユーザーのお気に入り登録を解除する
    //
    // クエリパラメータ：
    // liker_user_id：お気に入りしていた側のユーザーID
    // likee_user_id：お気に入りされていた側のユーザーID
    case 10:
      try {
        const { liker_user_id, likee_user_id } = req.query;

        // パラメータが不足している場合
        if (!liker_user_id || !likee_user_id) {
          res
            .status(400)
            .send("liker_user_id または likee_user_id パラメータが不足しています");
          return;
        }

        // DB接続
        const client = await pool.connect();

        // 該当するお気に入り関係を削除
        const result = await client.query(
          `
            DELETE FROM favorite_user_relation
            WHERE liker_user_id = $1 AND likee_user_id = $2
          `,
          [liker_user_id, likee_user_id]
        );

        // DB接続を解放
        client.release();

        // 削除が成功したかを確認
        if ((result.rowCount ?? 0) > 0) {
          res.status(200).send("お気に入りを解除しました");
        } else {
          res.status(404).send("該当するデータが見つかりませんでした");
        }
      } catch (error) {
        console.error("お気に入り解除エラー:", error);
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
            user_introduce,
            favorite_gym,
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
            '設定から自己紹介を記入しましょう！',
            '設定から好きなジムを記入しましょう！',
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
          if((result.rowCount ?? 0) > 0)  {
            res.status(200).send("データが正常に挿入されました");
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
        const {user_id, limit = 20, cursor} = req.query;

        // user_idがない(null)ケース
        if(user_id == null){
          // エラーコード400とuser_idが送られてきていない旨を返信して終了
          res.status(400).send("user_idパラメータが必要です");
          return;
        }

        // DB接続
        const client = await pool.connect();

        // DBに投げるクエリを入れる変数
        let query;
        let params;

        if(cursor) {
          // カーソル（tweeted_date）を使ってページネーション
            query =`
            SELECT
              BLT.tweet_id,
              BLT.tweet_contents,
              BLT.visited_date,
              BLT.tweeted_date,
              BLT.liked_counts,
              BLT.movie_url,
              B.user_id,
              B.user_name,
              B.user_icon_url,
              GI.gym_id,
              GI.gym_name,
              GI.prefecture,
              COALESCE(
                  (
                  SELECT json_agg(media_url)
                  FROM boul_log_tweet_media
                  WHERE tweet_id = BLT.tweet_id
                  ), '[]'
              ) AS media_urls
            FROM boul_log_tweet AS BLT
            INNER JOIN boulder AS B ON BLT.user_id = B.user_id
            INNER JOIN gym_info AS GI ON BLT.gym_id = GI.gym_id
            WHERE BLT.user_id = $1
              AND BLT.tweeted_date < $2
            ORDER BY BLT.tweeted_date DESC
            LIMIT $3;
          `;
          params = [user_id, cursor, limit];
        } else {
          // 最初の取得（カーソルなし）
          query =`
            SELECT
              BLT.tweet_id,
              BLT.tweet_contents,
              BLT.visited_date,
              BLT.tweeted_date,
              BLT.liked_counts,
              BLT.movie_url,
              B.user_id,
              B.user_name,
              B.user_icon_url,
              GI.gym_id,
              GI.gym_name,
              GI.prefecture,
              COALESCE(
                  (
                  SELECT json_agg(media_url)
                  FROM boul_log_tweet_media
                  WHERE tweet_id = BLT.tweet_id
                  ), '[]'
              ) AS media_urls
            FROM boul_log_tweet AS BLT
            INNER JOIN boulder AS B ON BLT.user_id = B.user_id
            INNER JOIN gym_info AS GI ON BLT.gym_id = GI.gym_id
            WHERE BLT.user_id = $1
            ORDER BY BLT.tweeted_date DESC
            LIMIT $2;
          `;
          params = [user_id, limit];
        }

        // クエリ実行
        const result = await client.query(query, params);

        // DB接続を解放
        client.release();

        // 結果を返信
        res.status(200).json(result.rows);
      } catch(error){
        console.error("Error querying database: ",error);
        res.status(500).send("Error querying database");
      }
      break;


    // request_id: 13
    // - ジムの情報を取得する
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
            GI.gym_id,
            GI.gym_name,
            GI.hp_link,
            GI.prefecture,
            GI.city,
            GI.address_line,
            GI.latitude,
            GI.longitude,
            GI.tel_no,
            GI.fee,
            GI.minimum_fee,
            GI.equipment_rental_fee,
            (SELECT COUNT(*) FROM wanna_go_relation WGR WHERE WGR.gym_id = GI.gym_id) AS ikitai_count,
            (SELECT COUNT(*) FROM boul_log_tweet BLT WHERE BLT.gym_id = GI.gym_id) AS boul_count,
            CT.is_bouldering_gym,
            CT.is_lead_gym,
            CT.is_speed_gym,
            GH.sun_open,
            GH.sun_close,
            GH.mon_open,
            GH.mon_close,
            GH.tue_open,
            GH.tue_close,
            GH.wed_open,
            GH.wed_close,
            GH.thu_open,
            GH.thu_close,
            GH.fri_open,
            GH.fri_close,
            GH.sat_open,
            GH.sat_close
          FROM gym_info GI
          INNER JOIN climbing_types CT ON CT.gym_id = GI.gym_id
          INNER JOIN gym_hours GH ON GH.gym_id = GI.gym_id;
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

    // request_id: 14
    // - ユーザー名を更新する
    //
    // クエリパラメータ：
    // - user_name：ユーザー名
    // - user_id：ユーザーID
    case 14:
      try{
        // クエリパラメータを取得
        const {user_name, user_id} = req.query;

        // user_idがないケース (※user_nameはなくても問題ないためnullチェック無し)
        if(user_id == null) {
          // エラーコード400, user_idがない旨を返信して終了
          res.status(400).send("user_idパラメータがありません");
          return;
        } else {
          // DB接続
          const client = await pool.connect();

          // ユーザー名を更新
          const result = await client.query(`
            UPDATE boulder
            SET user_name = $1
            WHERE user_id = $2;
          `, [user_name, user_id]);

          // DB接続を解放
          client.release();

          if(!result.rowCount) {
            res.status(400).send("データ更新に失敗しました");
            return;
          }
          res.status(200).send("データが正常に更新されました");
          return;
        }
      } catch(error) {
        console.error("データ更新エラー", error);
        res.status(500).send("サーバーエラーが発生しました");
      }
      break;

    // request_id: 15
    // - 自己紹介，または好きなジム欄の更新
    //
    // クエリパラメータ
    // - description: 自己紹介，または好きなジム
    // - user_id: ユーザーID
    // - type: 自己紹介(true)，または好きなジム(false)のいずれかを示す
    case 15:
      try{
        // 結果を受け取る用の変数
        var result;

        // クエリパラメータを取得
        const {description, user_id, type} = req.query;

        // user_idがないケース
        if(user_id == null) {
          // Errorコード400, user_idがない旨を返信して終了
          res.status(400).send("user_idパラメータが有りません");
          return;
        } else {
          // DB接続
          const client = await pool.connect();

          // 更新処理
          if(type == "true") {
            result = await client.query(`
              UPDATE boulder
              SET user_introduce = $1
              WHERE user_id = $2;
            `, [description, user_id]);
          } else {
            result = await client.query(`
              UPDATE boulder
              SET favorite_gym = $1
              WHERE user_id = $2;
            `, [description, user_id]);
          }

          // DB接続を解放
          client.release();

          if(!result.rowCount) {
            res.status(400).send("データ更新に失敗しました");
            return;
          }
          res.status(200).send("データが正常に更新されました");
          return;
        }
      } catch(error) {
        console.error("データ更新エラー", error);
        res.status(500).send("サーバーエラーが発生しました");
      }
      break;

    // request_id: 16
    // - 性別を更新する
    //
    // クエリパラメータ
    // - gender: 男性("1") , 女性("2"), 未選択("0")
    // - user_id: ユーザーID
    case 16:
      try{
        // クエリパラメータを取得
        const {gender, user_id} = req.query;
        // genderカラムはDBでINTEGER型
        // → そのため数値にキャスト
        const castedGender = gender ? parseInt(gender as string, 10) : 0;
        // user_idがないケース
        if(user_id == null) {
          // Errorコード400, user_idがない旨を返信して終了
          res.status(400).send("user_idパラメータが有りません");
          return;
        } else {
          // DB接続
          const client = await pool.connect();

          // 更新処理
          result = await client.query(`
            UPDATE boulder
            SET gender = $1
            WHERE user_id = $2;
          `, [castedGender, user_id]);

          // DB接続を解放
          client.release();

          if(!result.rowCount) {
            res.status(400).send("データ更新に失敗しました");
            return;
          }
          res.status(200).send("データが正常に更新されました");
          return;
        }
      } catch(error) {
        console.error("データ更新エラー", error);
        res.status(500).send("サーバーエラーが発生しました");
      }
      break;

    // request_id: 17
    // - ボル活開始日，または生年月日の更新
    //
    // クエリパラメータ
    // - user_id: ユーザーID
    // - update_date: 更新後の日程
    // - is_bouldering_debut: ボル活開始日(true), または生年月日(false)のいずれかを示す
    case 17:
      try{
        // 結果を受け取る用の変数
        var result;

        // クエリパラメータを取得
        const {user_id, update_date, is_bouldering_debut} = req.query;

        // user_idがないケース
        if(user_id == null) {
          // Errorコード400, user_idがない旨を返信して終了
          res.status(400).send("user_idパラメータが有りません");
          return;
        } else {
          // DB接続
          const client = await pool.connect();

          // 更新処理
          if(is_bouldering_debut == "true") {
            result = await client.query(`
              UPDATE boulder
              SET boul_start_date = $1
              WHERE user_id = $2;
            `, [update_date, user_id]);
          } else {
            result = await client.query(`
              UPDATE boulder
              SET birthday = $1
              WHERE user_id = $2;
            `, [update_date, user_id]);
          }

          // DB接続を解放
          client.release();

          if(!result.rowCount) {
            res.status(400).send("データ更新に失敗しました");
            return;
          }
          res.status(200).send("データが正常に更新されました");
          return;
        }
      } catch(error) {
        console.error("データ更新エラー", error);
        res.status(500).send("サーバーエラーが発生しました");
      }
      break;

    // request_id: 18
    // - ホームジムIDを更新する
    // - (エラーハンドリング)ジムID < 0 のケースでは、更新失敗(false)とする
    //
    // クエリパラメータ
    // - user_id: ユーザーID
    // - home_gym_id: 更新後のホームジムID
    case 18:
      try{
        // クエリパラメータを取得
        const {user_id, home_gym_id} = req.query;
        const casted_home_gym_id = (typeof home_gym_id === "string") ? parseInt(home_gym_id, 10) : 0;

        if(user_id == null) {    // user_idがないケース
          // Errorコード400, user_idがない旨を返信して終了
          res.status(400).send("user_idパラメータが有りません");
          return;
        } else if(casted_home_gym_id < 0) {    // home_gym_idに該当するジムがないケース
          // Errorコード400, user_idがない旨を返信して終了
          res.status(400).send("user_idパラメータが有りません");
          return;
        }
        else {
          // DB接続
          const client = await pool.connect();

          // 更新処理
          const result = await client.query(`
              UPDATE boulder
              SET home_gym_id = $1
              WHERE user_id = $2;
            `, [casted_home_gym_id, user_id]);

          // DB接続を解放
          client.release();

          if(!result.rowCount) {
            res.status(400).send("データ更新に失敗しました");
            return;
          }
          res.status(200).send("データが正常に更新されました");
          return;
        }
      } catch(error) {
        console.error("データ更新エラー", error);
        res.status(500).send("サーバーエラーが発生しました");
      }
      break;

    // request_id: 19
    // - ユーザーアイコンURLを更新する
    //
    // クエリパラメータ
    // - user_id: ユーザーID
    // - user_icon_url: 新しいユーザーアイコンURL
    case 19:
      try{
        // クエリパラメータを取得
        const { user_id, user_icon_url } = req.query;

        // 必須パラメータチェック
        if(!user_id || !user_icon_url) {
          res.status(400).send("user_id, またはuser_icon_urlパラメータが不足しています");
          return;
        }

        // DB接続
        const client = await pool.connect();

        // UPDATE実行
        const result = await client.query(`
          UPDATE boulder
          SET user_icon_url = $1
          WHERE user_id = $2;
        `, [user_icon_url, user_id]);

        // DB接続を解放
        client.release();

        // 更新成功チェック
        if(!result.rowCount) {
          res.status(400).send("データ更新に失敗しました");
          return;
        }

        res.status(200).send("ユーザーアイコンURLが正常に更新されました");
        return;
      } catch(error) {
        console.error("データ更新エラー：error");
        res.status(500).send("サーバーエラーが発生しました");
      }
      break;

    // request_id: 20 - 21
    // なし


    // request_id: 22
    // - 指定した月の「ボル活回数」「訪問したジム施設数」「週当たりのボルダリング活動数」を取得する
    // - どの"ユーザー"の, 今月から"何か月前"の情報を取得するか、を指定する必要がある
    // - 今月の情報を取得する場合は、months_agoは0で良い(0か月前)
    //
    // クエリパラメータ
    // - user_id: ユーザーID
    // - months_ago : 何か月前のデータを取得するかを指定する
    // - months_ago : 何か月前のデータを取得するかを指定する
    case 22:
      try{
        // クエリパラメータを取得
        const {user_id, months_ago} = req.query;
        const casted_months_ago = Number(months_ago) || 0;

        // months_agoを基準に開始日・終了日を計算
        const startDate = new Date();
        startDate.setMonth(startDate.getMonth() - casted_months_ago);
        startDate.setDate(1);   // その月の1日

        const endDate = new Date(startDate);
        endDate.setMonth(endDate.getMonth() + 1); // 翌月の1日

        if(user_id == null) {
          // Errorコード400, user_idがない旨を返信して終了
          res.status(400).send("user_idパラメータが有りません");
          return;
        } else {
          // DB接続
          const client = await pool.connect();

          // 1. ボル活回数
          const boulActivityCountsQuery = `
            SELECT COALESCE(SUM(daily_gym_count),0) AS total_visits
                FROM (
                  SELECT DATE(visited_date) AS visit_day, COUNT(DISTINCT gym_id) AS daily_gym_count
                  FROM boul_log_tweet
                  WHERE user_id = $1
                    AND visited_date >= $2
                    AND visited_date < $3
                  GROUP BY visit_day
                ) AS daily_counts;
          `;
          const boulActivityCountsResult = await client.query(boulActivityCountsQuery, [user_id, startDate.toISOString(), endDate.toISOString()]);
          const totalVisits = boulActivityCountsResult.rows[0]?.total_visits ?? 0;

          // 2. 訪問施設数
          const visitedGymCountsQuery = `
            SELECT COUNT(DISTINCT gym_id) AS total_gym_count
              FROM boul_log_tweet
              WHERE user_id = $1
                AND visited_date >= $2
                AND visited_date < $3;
          `;
          const visitedGymCountsResult = await client.query(visitedGymCountsQuery, [user_id, startDate.toISOString(), endDate.toISOString()]);
          const totalGyms = visitedGymCountsResult.rows[0]?.total_gym_count ?? 0;

          // 3. 週平均回数
          const weeklyVisitRateQuery = `
            SELECT TRUNC(COALESCE(SUM(daily_gym_count), 0) :: numeric / (EXTRACT(DAY FROM CURRENT_DATE):: numeric / 7), 1) AS weekly_visit_rate
            FROM (
              SELECT visited_date, COUNT(DISTINCT gym_id) AS daily_gym_count
              FROM boul_log_tweet
              WHERE user_id = $1
                AND visited_date >= $2
                AND visited_date < $3
              GROUP BY visited_date
            ) AS daily_counts;
          `;
          const weeklyVisitRateResult = await client.query(weeklyVisitRateQuery, [user_id, startDate.toISOString(), endDate.toISOString()]);
          const weeklyVisitRate = weeklyVisitRateResult.rows[0]?.weekly_visit_rate ?? 0;

          // 4. TOP5 の訪問ジム
          const topGymsQuery = `
            SELECT G.gym_name, B.gym_id, COUNT(*) AS visit_count, MAX(B.visited_date) AS latest_visit
            FROM boul_log_tweet B
            INNER JOIN gym_info G ON B.gym_id = G.gym_id
            WHERE B.user_id = $1
              AND B.visited_date >= $2
              AND B.visited_date < $3
            GROUP BY B.gym_id, G.gym_name
            ORDER BY visit_count DESC, latest_visit DESC
            LIMIT 5;
          `;
          const topGymsResult = await client.query(topGymsQuery, [user_id, startDate.toISOString(), endDate.toISOString()]);
          const topGyms = topGymsResult.rows.map(row => ({
            gym_id: row.gym_id,
            gym_name: row.gym_name,
            visit_count: row.visit_count
          }));

          // TOP5 に満たない場合、gym_name(ジム名),visit_count(訪問回数)共に「-」を追加
          while (topGyms.length < 5) {
            topGyms.push({ gym_id: "0", gym_name: "-", visit_count: "-" });
          }

          // DB接続を解放
          client.release();

          // まとめてJSON で返す
          res.status(200).json({
            total_visits: totalVisits,
            total_gym_count: totalGyms,
            weekly_visit_rate: weeklyVisitRate,
            top_gyms: topGyms
          });

          return;
        }
      } catch(error) {
        console.error("Error querying database: ", error);
        res.status(500).send("Error querying database");
      }
      break;

    // requestId: 23
    // - イキタイ登録しているジム情報を取得する
    //
    // クエリパラメータ
    // user_id: ユーザーID
    // gym_id: ジムを識別するID
    case 23:
      try{
        // クエリパラメータ取得
        const {user_id} = req.query;

        if(user_id === null){
          res.status(400).send("user_id, またはgym_idパラメータが必要です");
          return;
        } else {
          // DB接続
          const client = await pool.connect();

          // お気に入り登録しているジム情報（ジムカード）を取得(お気に入り登録した順番に取得)
          const result = await client.query(`
          SELECT
            GI.gym_id,
            GI.gym_name,
            GI.hp_link,
            GI.prefecture,
            GI.city,
            GI.address_line,
            GI.latitude,
            GI.longitude,
            GI.tel_no,
            GI.fee,
            GI.minimum_fee,
            GI.equipment_rental_fee,
            (SELECT COUNT(*) FROM wanna_go_relation WGR WHERE WGR.gym_id = GI.gym_id) AS ikitai_count,
            (SELECT COUNT(*) FROM boul_log_tweet BLT WHERE BLT.gym_id = GI.gym_id) AS boul_count,
            CT.is_bouldering_gym,
            CT.is_lead_gym,
            CT.is_speed_gym,
            GH.sun_open,
            GH.sun_close,
            GH.mon_open,
            GH.mon_close,
            GH.tue_open,
            GH.tue_close,
            GH.wed_open,
            GH.wed_close,
            GH.thu_open,
            GH.thu_close,
            GH.fri_open,
            GH.fri_close,
            GH.sat_open,
            GH.sat_close
          FROM wanna_go_relation WGR
          JOIN gym_info GI ON GI.gym_id = WGR.gym_id
          LEFT JOIN climbing_types CT ON CT.gym_id = GI.gym_id
          LEFT JOIN gym_hours GH ON GH.gym_id = GI.gym_id
          WHERE WGR.user_id = $1
          ORDER BY WGR.created_at DESC;
          `, [user_id]
          );

          // DB接続を解放
          client.release();

          if(result.rows.length > 0) {
            res.status(200).json(result.rows);
            return;
          } else if(result.rows.length === 0) {
            res.status(204).send("No Content");
            return;
          } else {
            res.status(500).send("Error querying database");
            return;
          }
        }
      } catch(error) {
        console.error("Error querying database: ", error);
        res.status(500).send("Error querying database");
      }
      break;


    // requestId: 24
    // - 特定のジム(ID)のツイートを取得する
    //
    // クエリパラメータ
    // - gymId : ジムを識別するID
    // - limit : ツイートを一度に読み込んで取得する数
    // - cursor : フロント側で取得している最も古いツイート日時
    case 24:
    // DB接続用変数
    let client;

    try {
        // クエリパラメータを取得
        const gym_id = req.query.gym_id ? parseInt(req.query.gym_id as string, 10) : NaN;
        const limit = req.query.limit ? parseInt(req.query.limit as string, 10) || 20 : 20;
        const cursor = req.query.cursor ? new Date(req.query.cursor as string) : null; // 修正箇所

        // gym_idがない(null)ケース
        if (isNaN(gym_id)) {
        res.status(400).send("gym_idパラメータが必要です");
        return;
        }

        // cursorのバリデーション
        if (cursor && isNaN(cursor.getTime())) {
        res.status(400).send("cursorの値が不正です");
        return;
        }

        // DB接続
        client = await pool.connect();

        // DBに投げるクエリを入れる変数
        let query;
        let params;

        if (cursor) {
        // カーソル(tweeted_date)を使ってページネーション
        query = `
            SELECT
            BLT.tweet_id,
            BLT.tweet_contents,
            BLT.visited_date,
            BLT.tweeted_date,
            BLT.liked_counts,
            BLT.movie_url,
            B.user_id,
            B.user_name,
            B.user_icon_url,
            GI.gym_id,
            GI.gym_name,
            GI.prefecture
            FROM
            boul_log_tweet AS BLT
            INNER JOIN
            boulder AS B ON BLT.user_id = B.user_id
            INNER JOIN
            gym_info AS GI ON BLT.gym_id = GI.gym_id
            WHERE GI.gym_id = $1
            AND BLT.tweeted_date < $2
            ORDER BY BLT.tweeted_date DESC
            LIMIT $3;
        `;
        params = [gym_id, cursor, limit];
        } else {
        // 最初の取得(カーソル無し)
        query = `
            SELECT
            BLT.tweet_id,
            BLT.tweet_contents,
            BLT.visited_date,
            BLT.tweeted_date,
            BLT.liked_counts,
            BLT.movie_url,
            B.user_id,
            B.user_name,
            B.user_icon_url,
            GI.gym_id,
            GI.gym_name,
            GI.prefecture
            FROM
            boul_log_tweet AS BLT
            INNER JOIN
            boulder AS B ON BLT.user_id = B.user_id
            INNER JOIN
            gym_info AS GI ON BLT.gym_id = GI.gym_id
            WHERE
            GI.gym_id = $1
            ORDER BY BLT.tweeted_date DESC
            LIMIT $2;
        `;
        params = [gym_id, limit];
        }

        // 特定のジムのツイートを最新準から時系列順に取得
        const result = await client.query(query, params);

        // 結果を返信
        res.status(200).json(result.rows);
    } catch (error) {
        console.error("Error querying database: ", error);
        res.status(500).send("Error querying database");
    } finally {
        // DB接続を解放
        if (client) {
        client.release();
        }
    }
    break;


// requestId: 25
// - 特定のジム(ID)の施設情報を取得する
//
// クエリパラメータ
// - gymId : ジムを識別するID
// - limit : ツイートを一度に読み込んで取得する数
// - cursor : フロント側で取得している最も古いツイート日時
case 25:
    let localClient : any;

  try {
    // クエリパラメータ取得
    const gym_id = req.query.gym_id ? parseInt(req.query.gym_id as string, 10) : NaN;

    // gym_idがない(null)ケース
    if (isNaN(gym_id)) {
      // エラーコード400とgym_idが送られてきていない旨を返信して終了
      res.status(400).send("gym_idパラメータが必要です");
      return;
    }

    // DB接続
    // client を関数スコープ外からではなく、ここだけで定義して使う
    localClient = await pool.connect();

    // お気に入り登録しているジム情報（ジムカード）を取得(お気に入り登録した順番に取得)
    const result = await localClient.query(`
    SELECT
        GI.gym_id,
        GI.gym_name,
        GI.hp_link,
        GI.prefecture,
        GI.city,
        GI.address_line,
        GI.latitude,
        GI.longitude,
        GI.tel_no,
        GI.fee,
        GI.minimum_fee,
        GI.equipment_rental_fee,
        (SELECT COUNT(*) FROM wanna_go_relation WGR WHERE WGR.gym_id = $1) AS ikitai_count,
        (SELECT COUNT(*) FROM boul_log_tweet BLT WHERE BLT.gym_id = $1) AS boul_count,
        CT.is_bouldering_gym,
        CT.is_lead_gym,
        CT.is_speed_gym,
        GH.sun_open,
        GH.sun_close,
        GH.mon_open,
        GH.mon_close,
        GH.tue_open,
        GH.tue_close,
        GH.wed_open,
        GH.wed_close,
        GH.thu_open,
        GH.thu_close,
        GH.fri_open,
        GH.fri_close,
        GH.sat_open,
        GH.sat_close
    FROM gym_info GI
    INNER JOIN climbing_types CT ON CT.gym_id = GI.gym_id
    INNER JOIN gym_hours GH ON GH.gym_id = GI.gym_id
    WHERE GI.gym_id = $1;
    `, [gym_id]);

    if (result.rows.length > 0) {
      // res.status(200).json(result.rows);
      res.status(200).json(result.rows[0]); // ← 配列の中の1件を返す
      return;
    } else {
      res.status(500).send("No data found for the given gym_id");
      return;
    }
  } catch (error) {
    console.error("Error querying database: ", error);
    res.status(500).send("Exception occurred while querying database");
  } finally {
    // 修正：clientがnullでない場合のみrelease
    if (localClient) {
      localClient.release();
    }
  }
  break;


    // requestId: 26
    // 概要：イキタイを登録した各ユーザーのID、ジムID,登録日を登録(INSERT)する
    // トリガ：イキタイ登録 押下時
    // クエリパラメータ
    // - user_id: ユーザID
    // - gym_id：ジムID
    case 26:
      try{
        // クエリパラメータを取得
        const {user_id, gym_id} = req.query;

        // パラメータがないケース
        if(!user_id || !gym_id) {
          // エラーコード400, パラメータがない旨を返信して終了
          res.status(400).send("user_id, またはgym_idパラメータがありません");
          return;
        }

        // DB接続
        const client = await pool.connect();

        // イキタイリレーションに登録する。
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
        ON CONFLICT (gym_id, user_id) DO NOTHING
        RETURNING *;
        `, [user_id, gym_id]);

        // DB接続を解放
        client.release();

        // 挿入が成功されたかを確認する
        if((result.rowCount ?? 0) > 0)  {
          res.status(200).send("データが正常に挿入されました");
        } else {
          res.status(400).send("データ挿入に失敗しました");
        }
      } catch(error) {
        console.error("データ挿入エラー", error);
        res.status(500).send("サーバーエラーが発生しました");
      }
    break;

    // requestId: 27
    // 概要：イキタイを登録した各ユーザーのID、ジムID,登録日をDBから削除する
    // トリガ：イキタイ登録 解除押下時
    // クエリパラメータ
    // - user_id: ユーザID
    // - gym_id：ジムID
    case 27:
      try{
        // クエリパラメータをh崇徳
        const {user_id, gym_id} = req.query;

        // パラメータがない場合、
        if(!user_id || !gym_id) {
          res.status(400).send("user_id またはgym_idパラメータがありません");
          return;
        }

        // DB接続
        const client = await pool.connect();

        // 特定のuser_id, gym_idレコードを削除
        const result = await client.query(`
          DELETE FROM wanna_go_relation
          WHERE user_id = $1
          AND gym_id = $2;
        `, [user_id, gym_id]);

        // DB接続を解放
        client.release();

        // 削除が成功した場合
        if((result.rowCount ?? 0) > 0) {
          res.status(200).send("データが正常に削除されました");
        } else {
          res.status(404).send("該当するデータが見つかりませんでした");
        }
      } catch(error) {
        console.error("データ削除エラー", error);
        res.status(500).send("サーバーエラーが発生しました");
      }
      break;

    // request_id: 28
    // ツイート本体 + 画像URLの削除(CloudStorageの画像本体は削除しない)
    case 28:
    let tweetDeleteClient: PoolClient | undefined;
    try {
        const { tweet_id, user_id, gym_id } = req.query;

        if (!tweet_id || !user_id || !gym_id) {
        res.status(400).send("tweet_id, user_id, gym_id のいずれかが不足しています");
        return;
        }

        tweetDeleteClient = await pool.connect();
        await tweetDeleteClient.query("BEGIN");

        // メディア情報削除
        await tweetDeleteClient.query(
        `DELETE FROM boul_log_tweet_media WHERE tweet_id = $1`,
        [tweet_id]
        );

        // ツイート本体削除
        const result = await tweetDeleteClient.query(
        `DELETE FROM boul_log_tweet WHERE tweet_id = $1 AND user_id = $2 AND gym_id = $3`,
        [tweet_id, user_id, gym_id]
        );

        await tweetDeleteClient.query("COMMIT");
        tweetDeleteClient.release();

        if ((result?.rowCount ?? 0) > 0) {
        res.status(200).send("ツイートとメディア情報を正常に削除しました");
        } else {
        res.status(404).send("該当するツイートが見つかりませんでした");
        }
    } catch (error) {
        if (tweetDeleteClient) {
        await tweetDeleteClient.query("ROLLBACK");
        tweetDeleteClient.release();
        }
        console.error("削除エラー:", error);
        res.status(500).send("ツイート削除中にサーバーエラーが発生しました");
    }
    break;

    // requestId：29
    // ツイート内容を更新する
    //
    // クエリパラメータ：
    // tweet_id：ツイートのID（必須）
    // tweet_contents：ツイート内容（省略可）
    // visited_date：ジム訪問日（省略可）
    // gym_id：ジムID（省略可）
    case 29:
      try {
        const { tweet_id, tweet_contents, visited_date, gym_id } = req.query;

        // tweet_id が無ければエラー
        if (!tweet_id) {
          res.status(400).send("tweet_id パラメータが必要です");
          return;
        }

        // 更新対象が1つもない場合
        if (!tweet_contents && !visited_date && !gym_id) {
          res.status(400).send("更新対象のパラメータが必要です");
          return;
        }

        // 動的にUPDATE文を組み立てる
        const fields = [];
        const values = [];
        let idx = 1;

        if (tweet_contents) {
          fields.push(`tweet_contents = $${idx++}`);
          values.push(tweet_contents);
        }
        if (visited_date) {
          fields.push(`visited_date = $${idx++}`);
          values.push(visited_date);
        }
        if (gym_id) {
          fields.push(`gym_id = $${idx++}`);
          values.push(gym_id);
        }

        values.push(tweet_id); // WHERE句用
        const setClause = fields.join(", ");

        // SQL文
        const sql = `
          UPDATE boul_log_tweet
          SET ${setClause}
          WHERE tweet_id = $${idx}
          RETURNING *;
        `;

        const client = await pool.connect();
        const result = await client.query(sql, values);
        client.release();

        if ((result.rowCount ?? 0) > 0) {
          res.status(200).json({
            message: "ツイートが正常に更新されました",
            updated: result.rows[0],
          });
        } else {
          res.status(404).send("指定されたツイートが見つかりませんでした");
        }
      } catch (error) {
        console.error("更新エラー:", error);
        res.status(500).send("サーバーエラーが発生しました");
      }
      break;


    // requestId：30
    // 指定ツイートIDとメディアURLに紐づく1件の画像・動画URLを削除する
    //
    // クエリパラメータ：
    // tweet_id: 対象ツイートのID
    // media_url: 削除対象の画像または動画URL
    case 30:
      try {
        const { tweet_id, media_url } = req.query;

        if (!tweet_id || !media_url) {
          res.status(400).send("tweet_idとmedia_urlの両方が必要です");
          return;
        }

        const client = await pool.connect();
        const result = await client.query(
          `DELETE FROM boul_log_tweet_media WHERE tweet_id = $1 AND media_url = $2`,
          [tweet_id, media_url]
        );
        client.release();

        res.status(200).json({
          message: "指定されたメディアを1件削除しました",
          deletedCount: result.rowCount
        });
      } catch (error) {
        console.error("個別メディア削除エラー:", error);
        res.status(500).send("サーバーエラーが発生しました");
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
