; Enemy.inc : エネミー
;


; マクロの定義
;

; エネミー
ENEMY_TYPE                      =   0x00
ENEMY_STATE                     =   0x01
ENEMY_FLAG                      =   0x02
ENEMY_POSITION_X_L              =   0x03
ENEMY_POSITION_X_H              =   0x04
ENEMY_POSITION_Y                =   0x05
ENEMY_SPEED_X_L                 =   0x06
ENEMY_SPEED_X_H                 =   0x07
ENEMY_SIZE_X                    =   0x08
ENEMY_SIZE_Y                    =   0x09
ENEMY_SPRITE_L                  =   0x0a
ENEMY_SPRITE_H                  =   0x0b
ENEMY_LENGTH                    =   0x10
ENEMY_ENTRY                     =   0x0c

; 種類
ENEMY_TYPE_SMALL                =   0x00
ENEMY_TYPE_MEDIUM               =   0x01
ENEMY_TYPE_LARGE                =   0x02

; 状態
ENEMY_STATE_NULL                =   0x00

; フラグ
ENEMY_FLAG_NULL                 =   0x00
ENEMY_FLAG_STOP_BIT             =   0x00
ENEMY_FLAG_STOP                 =   (1 << ENEMY_FLAG_STOP_BIT)

; 位置
ENEMY_POSITION_NULL             =   0x00

; 速度
ENEMY_SPEED_NULL                =   0x00

; 大きさ
ENEMY_SIZE_NULL                 =   0x00

; スプライト
ENEMY_SPRITE_NULL               =   0x00

; 外部関数宣言
;

    .globl  _EnemyInitialize
    .globl  _EnemyUpdate
    .globl  _EnemyRender
    .globl  _EnemyHit

; 外部変数宣言
;

    .globl  _enemy

