; Enemy.s : エネミー
;


; モジュール宣言
;
    .module Enemy

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include	"Game.inc"
    .include    "Player.inc"
    .include    "Enemy.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; エネミーを初期化する
;
_EnemyInitialize::
    
    ; レジスタの保存

    ; エネミーの登録
    call    EnemyEntry

    ; スプライトの初期化
    xor     a
    ld      (enemySprite), a

    ; レジスタの復帰
    
    ; 終了
    ret

; エネミーを更新する
;
_EnemyUpdate::
    
    ; レジスタの保存
    
    ; エネミーの走査
    ld      ix, #_enemy
    ld      b, #ENEMY_ENTRY
10$:
    push    bc

    ; エネミーの処理
    call    EnemyProc

    ; 次のエネミーへ
    ld      bc, #ENEMY_LENGTH
    add     ix, bc
    pop     bc
    djnz    10$

    ; レジスタの復帰
    
    ; 終了
    ret

; エネミーを描画する
;
_EnemyRender::

    ; レジスタの保存

    ; スプライトの描画
    ld      ix, #_enemy
    ld      a, (enemySprite)
    ld      e, a
    ld      d, #0x00
    ld      b, #ENEMY_ENTRY
10$:
    push    bc
    ld      l, ENEMY_SPRITE_L(ix)
    ld      h, ENEMY_SPRITE_H(ix)
    ld      a, h
    or      l
    jr      z, 12$
    call    20$
;   jr      12$
12$:
    ld      bc, #ENEMY_LENGTH
    add     ix, bc
    pop     bc
    djnz    10$
    jr      90$

    ; ひとつのスプライトの描画
20$:
    push    de
    push    hl
    ld      hl, #(_sprite + GAME_SPRITE_ENEMY)
    add     hl, de
    pop     de
    ex      de, hl
    ld      bc, #0x0000
    ld      a, ENEMY_POSITION_X_H(ix)
    cp      #0x80
    jr      nc, 21$
    ld      bc, #0x2080
21$:
    ld      a, ENEMY_POSITION_Y(ix)
    add     a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, ENEMY_POSITION_X_H(ix)
    add     a, b
    add     a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    or      c
    ld      (de), a
    inc     hl
;   inc     de
    pop     de
    ld      a, e
    add     a, #0x04
    ld      e, a
    cp      #(ENEMY_ENTRY * 0x04)
    jr      c, 29$
    ld      e, #0x00
29$:
    ret

    ; スプライトの更新
90$:
    ld      hl, #enemySprite
    ld      a, (hl)
    add     a, #0x04
    cp      #(ENEMY_ENTRY * 0x04)
    jr      c, 91$
    xor     a
91$:
    ld      (hl), a

    ; レジスタの復帰

    ; 終了
    ret

; エネミーを登録する
;
EnemyEntry:

    ; レジスタの保存

    ; エネミーの登録
    ld      ix, #_enemy
    ld      de, #0x3000
    ld      b, #ENEMY_ENTRY
10$:
    push    bc

    ; エネミーの選択
    push    de
    call    _SystemGetRandom
    and     #0x0e
    ld      e, a
    ld      d, #0x00
    ld      hl, #enemyDefault
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    push    ix
    pop     de
    ld      bc, #ENEMY_LENGTH
    ldir
    pop     de

    ; 位置の設定
    call    _SystemGetRandom
    ld      ENEMY_POSITION_X_H(ix), a
    ld      ENEMY_POSITION_Y(ix), d
    ld      a, d
    add     a, #0x0a
    ld      d, a

    ; スプライトの設定
    ld      c, e
    ld      b, #0x00
    ld      hl, #enemyColor
    add     hl, bc
    ld      a, (hl)
    add     a, a
    add     a, a
    ld      c, a
;   ld      b, #0x00
    ld      l, ENEMY_SPRITE_L(ix)
    ld      h, ENEMY_SPRITE_H(ix)
    add     hl, bc
    ld      ENEMY_SPRITE_L(ix), l
    ld      ENEMY_SPRITE_H(ix), h
    inc     e

    ; 次のエネミーへ
    ld      bc, #ENEMY_LENGTH
    add     ix, bc
    pop     bc
    djnz    10$

    ; 固定の敵の設定
    ld      hl, #enemyLargeDefault
    ld      de, #(_enemy + 0x01 * ENEMY_LENGTH)
    ld      bc, #ENEMY_LENGTH
    ldir
    ld      ix, #(_enemy + 0x01 * ENEMY_LENGTH)
    ld      ENEMY_POSITION_X_H(ix), #0x80
    ld      ENEMY_POSITION_Y(ix), #0x3a
    ld      hl, #(enemyLargeSprite + 0x0000 * 0x0004)
    ld      ENEMY_SPRITE_L(ix), l
    ld      ENEMY_SPRITE_H(ix), h

    ; レジスタの復帰

    ; 終了
    ret

; エネミーを処理する
;
EnemyProc:

    ; レジスタの保存

    ; 初期化
    ld      a, ENEMY_STATE(ix)
    or      a
    jr      nz, 09$

    ; 向きの変更
    call    _SystemGetRandom
    and     #0x40
    jr      z, 00$
    ld      a, ENEMY_SPEED_X_L(ix)
    cpl
    ld      l, a
    ld      a, ENEMY_SPEED_X_H(ix)
    cpl
    ld      h, a
    inc     hl
    ld      ENEMY_SPEED_X_L(ix), l
    ld      ENEMY_SPEED_X_H(ix), h
00$:

    ; 初期化の完了
    inc     ENEMY_STATE(ix)
09$:

    ; 接近
    ld      a, ENEMY_TYPE(ix)
    cp      #ENEMY_TYPE_LARGE
    jr      nz, 19$
    ld      l, ENEMY_SPEED_X_L(ix)
    ld      h, ENEMY_SPEED_X_H(ix)
    ld      de, #0x0002
    ld      a, (_player + PLAYER_POSITION_X_H)
    cp      ENEMY_POSITION_X_H(ix)
    jr      nc, 10$
    or      a
    sbc     hl, de
    jp      p, 18$
    ld      a, l
    cp      #-0xc0
    jr      nc, 18$
    ld      hl, #-0x00c0
    jr      18$
10$:
    or      a
    adc     hl, de
    jp      m, 18$
    ld      a, l
    cp      #0xc0
    jr      c, 18$
    ld      hl, #0x00c0
;   jr      18$
18$:
    ld      ENEMY_SPEED_X_L(ix), l
    ld      ENEMY_SPEED_X_H(ix), h
19$:

    ; 移動
    bit     #ENEMY_FLAG_STOP_BIT, ENEMY_FLAG(ix)
    jr      nz, 29$
    ld      l, ENEMY_POSITION_X_L(ix)
    ld      h, ENEMY_POSITION_X_H(ix)
    ld      e, ENEMY_SPEED_X_L(ix)
    ld      d, ENEMY_SPEED_X_H(ix)
    add     hl, de
    ld      ENEMY_POSITION_X_L(ix), l
    ld      ENEMY_POSITION_X_H(ix), h
29$:

    ; レジスタの復帰

    ; 終了
    ret

; エネミーとのヒット判定を行う
;
_EnemyHit::

    ; レジスタの保存
    push    bc
    push    ix

    ; de < Y/X 位置
    ; cf > 1 = ヒットした

    ; ヒット判定
    ld      ix, #_enemy
    ld      b, #ENEMY_ENTRY
10$:
    ld      a, e
    sub     ENEMY_POSITION_X_H(ix)
    jr      nc, 11$
    neg
11$:
    cp      ENEMY_SIZE_X(ix)
    jr      nc, 13$
    ld      a, d
    sub     ENEMY_POSITION_Y(ix)
    jr      nc, 12$
    neg
12$:
    cp      ENEMY_SIZE_Y(ix)
    jr      c, 18$
13$:
    push    bc
    ld      bc, #ENEMY_LENGTH
    add     ix, bc
    pop     bc
    djnz    10$
    or      a
    jr      19$
18$:
    set     #ENEMY_FLAG_STOP_BIT, ENEMY_FLAG(ix)
19$:
 
    ; レジスタの復帰
    pop     ix
    pop     bc

    ; 終了
    ret

; 定数の定義
;

; エネミーの初期値
;
enemyDefault:

    .dw     enemySmallDefault
    .dw     enemyMediumDefault
    .dw     enemyLargeDefault
    .dw     enemySmallDefault
    .dw     enemyMediumDefault
    .dw     enemyLargeDefault
    .dw     enemySmallDefault
    .dw     enemyMediumDefault

; エネミー（小）
;
enemySmallDefault:

    .db     ENEMY_TYPE_SMALL
    .db     ENEMY_STATE_NULL
    .db     ENEMY_FLAG_NULL
    .dw     ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .dw     0x0100; ENEMY_SPEED_NULL
    .db     0x05 + 0x04 ; ENEMY_SIZE_NULL
    .db     0x04 + 0x04 ; ENEMY_SIZE_NULL
    .dw     enemySmallSprite ; ENEMY_SPRITE_NULL
    .db     0x00, 0x00, 0x00, 0x00

enemySmallSprite:

    .db     0xf8 - 0x01, 0xf8, 0x40, VDP_COLOR_LIGHT_GREEN
    .db     0xf8 - 0x01, 0xf8, 0x40, VDP_COLOR_CYAN
    .db     0xf8 - 0x01, 0xf8, 0x40, VDP_COLOR_MAGENTA
    .db     0xf8 - 0x01, 0xf8, 0x40, VDP_COLOR_LIGHT_YELLOW

; エネミー（中）
;
enemyMediumDefault:

    .db     ENEMY_TYPE_MEDIUM
    .db     ENEMY_STATE_NULL
    .db     ENEMY_FLAG_NULL
    .dw     ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .dw     0x0080 ; ENEMY_SPEED_NULL
    .db     0x07 + 0x04 ; ENEMY_SIZE_NULL
    .db     0x04 + 0x04 ; ENEMY_SIZE_NULL
    .dw     enemyMediumSprite ; ENEMY_SPRITE_NULL
    .db     0x00, 0x00, 0x00, 0x00

enemyMediumSprite:

    .db     0xf8 - 0x01, 0xf8, 0x44, VDP_COLOR_LIGHT_GREEN
    .db     0xf8 - 0x01, 0xf8, 0x44, VDP_COLOR_CYAN
    .db     0xf8 - 0x01, 0xf8, 0x44, VDP_COLOR_MAGENTA
    .db     0xf8 - 0x01, 0xf8, 0x44, VDP_COLOR_LIGHT_YELLOW

; エネミー（大）
;
enemyLargeDefault:

    .db     ENEMY_TYPE_LARGE
    .db     ENEMY_STATE_NULL
    .db     ENEMY_FLAG_NULL
    .dw     ENEMY_POSITION_NULL
    .db     ENEMY_POSITION_NULL
    .dw     0x0000 ; ENEMY_SPEED_NULL
    .db     0x09 + 0x04 ; ENEMY_SIZE_NULL
    .db     0x04 + 0x04 ; ENEMY_SIZE_NULL
    .dw     enemyLargeSprite ; ENEMY_SPRITE_NULL
    .db     0x00, 0x00, 0x00, 0x00

enemyLargeSprite:

    .db     0xf8 - 0x01, 0xf8, 0x48, VDP_COLOR_LIGHT_GREEN
    .db     0xf8 - 0x01, 0xf8, 0x48, VDP_COLOR_CYAN
    .db     0xf8 - 0x01, 0xf8, 0x48, VDP_COLOR_MAGENTA
    .db     0xf8 - 0x01, 0xf8, 0x48, VDP_COLOR_LIGHT_YELLOW

; 色
;
enemyColor:

    .db     0x00 ; VDP_COLOR_LIGHT_GREEN
    .db     0x00 ; VDP_COLOR_LIGHT_GREEN
    .db     0x00 ; VDP_COLOR_LIGHT_GREEN
    .db     0x01 ; VDP_COLOR_CYAN
    .db     0x01 ; VDP_COLOR_CYAN
    .db     0x01 ; VDP_COLOR_CYAN
    .db     0x02 ; VDP_COLOR_MAGENTA
    .db     0x02 ; VDP_COLOR_MAGENTA
    .db     0x02 ; VDP_COLOR_MAGENTA
    .db     0x03 ; VDP_COLOR_LIGHT_YELLOW
    .db     0x03 ; VDP_COLOR_LIGHT_YELLOW
    .db     0x03 ; VDP_COLOR_LIGHT_YELLOW


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; エネミー
;
_enemy::
    
    .ds     ENEMY_LENGTH * ENEMY_ENTRY

; スプライト
;
enemySprite:

    .ds     0x01
