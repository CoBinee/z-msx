; Game.inc : ゲーム
;


; マクロの定義
;

; 状態
GAME_STATE_NULL                 =   0x00
GAME_STATE_START                =   0x10
GAME_STATE_PLAY                 =   0x20
GAME_STATE_OVER                 =   0x30
GAME_STATE_CLEAR                =   0x40
GAME_STATE_RESULT               =   0x50

; スプライト
GAME_SPRITE_NULL                =   0x00
GAME_SPRITE_BOMB                =   0x00
GAME_SPRITE_BACK                =   0x10
GAME_SPRITE_PLAYER              =   0x20
GAME_SPRITE_ENEMY               =   0x30

; ゲーム
GAME_REQUEST                    =   0x00
GAME_FLAG                       =   0x01
GAME_FRAME                      =   0x02
GAME_TRANSFER                   =   0x03
GAME_TIME_1000                  =   0x04
GAME_TIME_0100                  =   0x05
GAME_TIME_0010                  =   0x06
GAME_TIME_0001                  =   0x07
GAME_BONUS_1000                 =   0x08
GAME_BONUS_0100                 =   0x09
GAME_BONUS_0010                 =   0x0a
GAME_BONUS_0001                 =   0x0b
GAME_SCORE_1000                 =   0x0c
GAME_SCORE_0100                 =   0x0d
GAME_SCORE_0010                 =   0x0e
GAME_SCORE_0001                 =   0x0f
GAME_LENGTH                     =   0x10

; リクエスト
GAME_REQUEST_NULL               =   0x00
GAME_REQUEST_OVER_BIT           =   0x00
GAME_REQUEST_OVER               =   (1 << GAME_REQUEST_OVER_BIT)
GAME_REQUEST_CLEAR_BIT          =   0x01
GAME_REQUEST_CLEAR              =   (1 << GAME_REQUEST_CLEAR_BIT)

; フラグ
GAME_FLAG_NULL                  =   0x00
GAME_FLAG_JUST_BIT              =   0x00
GAME_FLAG_JUST                  =   (1 << GAME_FLAG_JUST_BIT)
GAME_FLAG_TOP_BIT               =   0x01
GAME_FLAG_TOP                   =   (1 << GAME_FLAG_TOP_BIT)

; フレーム
GAME_FRAME_NULL                 =   0x00

; 時間
GAME_TIME_NULL                  =   0x00
GAME_TIME_LENGTH                =   0x04

; ボーナス
GAME_BONUS_NULL                 =   0x00
GAME_BONUS_LENGTH               =   0x04

; スコア
GAME_SCORE_NULL                 =   0x00
GAME_SCORE_LENGTH               =   0x04

; 外部関数宣言
;

    .globl  _GameInitialize
    .globl  _GameUpdate

; 外部変数宣言
;

    .globl  _game
