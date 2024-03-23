; Title.s : タイトル
;


; モジュール宣言
;
    .module Title

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "App.inc"
    .include    "Sound.inc"
    .include	"Title.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; タイトルを初期化する
;
_TitleInitialize::
    
    ; レジスタの保存
    
    ; スプライトのクリア
    call    _SystemClearSprite

    ; パターンジェネレータの設定
    ld      a, #((APP_PATTERN_GENERATOR_TABLE + 0x0000) >> 11)
    ld      (_videoRegister + VDP_R4), a

    ; カラーテーブルの設定
    ld      a, #((APP_COLOR_TABLE + 0x0000) >> 6)
    ld      (_videoRegister + VDP_R3), a

    ; パターンネームのクリア
    xor     a
    call    _SystemClearPatternName

    ; パターンネームの転送
    ld      a, #PATTERN_NAME_TRANSFER_0300
    ld      (_patternNameTransfer), a

    ; サウンドの停止
    call    _SoundStop

    ; 描画の開始
    ld      hl, #(_videoRegister + VDP_R1)
    set     #VDP_R1_BL, (hl)
    
    ; 状態の設定
    ld      a, #TITLE_STATE_LOOP
    ld      (titleState), a
    ld      a, #APP_STATE_TITLE_UPDATE
    ld      (_appState), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; タイトルを更新する
;
_TitleUpdate::
    
    ; レジスタの保存
    
    ; スプライトのクリア
    call    _SystemClearSprite

    ; 状態別の処理
    ld      hl, #10$
    push    hl
    ld      a, (titleState)
    and     #0xf0
    rrca
    rrca
    rrca
    ld      e, a
    ld      d, #0x00
    ld      hl, #titleProc
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    jp      (hl)
;   pop     hl
10$:

    ; レジスタの復帰
    
    ; 終了
    ret

; 何もしない
;
TitleNull:

    ; レジスタの保存

    ; レジスタの復帰

    ; 終了
    ret

; タイトルを待機する
;
TitleLoop:

    ; レジスタの保存

    ; 初期化
    ld      a, (titleState)
    and     #0x0f
    jr      nz, 09$

    ; フレームの設定
    xor     a
    ld      (titleFrame), a

    ; ロゴの描画
    call    TitlePrintLogoPatternName

    ; スコアの描画
    call    TitlePrintScore

    ; OPLL の描画
    call    TitlePrintOpll

    ; BGM の再生
    ld      a, #SOUND_BGM_TITLE
    call    _SoundPlayBgm

    ; 初期化の完了
    ld      hl, #titleState
    inc     (hl)
09$:

    ; スペースキーの押下
    ld      a, (_input + INPUT_BUTTON_SPACE)
    dec     a
    jr      nz, 10$

    ; 状態の更新
    ld      a, #TITLE_STATE_START
    ld      (titleState), a
10$:

    ; フレームの更新
    ld      hl, #titleFrame
    inc     (hl)

    ; ロゴのスプライトの描画
    call    TitlePrintLogoSprite

    ; HIT SPACE BAR の描画
    call    TitlePrintHitSpaceBar

    ; パターンネームの転送
    ld      a, #PATTERN_NAME_TRANSFER_0300
    ld      (_patternNameTransfer), a

    ; レジスタの復帰

    ; 終了
    ret

; タイトルをスタートする
;
TitleStart:

    ; レジスタの保存

    ; 初期化
    ld      a, (titleState)
    and     #0x0f
    jr      nz, 09$

    ; サウンドの停止
    call    _SoundStop

    ; SE の再生
    ld      a, #SOUND_SE_BOOT
    call    _SoundPlaySe

    ; 初期化の完了
    ld      hl, #titleState
    inc     (hl)
09$:

    ; フレームの更新
    ld      hl, #titleFrame
    ld      a, (hl)
    add     a, #0x08
    ld      (hl), a

    ; 再生の監視
    call    _SoundIsPlaySe
    jr      c, 19$

    ; パターンネームのクリア
    xor     a
    call    _SystemClearPatternName

    ; 状態の更新
    ld      a, #APP_STATE_GAME_INITIALIZE
    ld      (_appState), a
19$:

    ; ロゴのスプライトの描画
    call    TitlePrintLogoSprite

    ; HIT SPACE BAR の描画
    call    TitlePrintHitSpaceBar

    ; パターンネームの転送
    ld      a, #PATTERN_NAME_TRANSFER_0300
    ld      (_patternNameTransfer), a

    ; レジスタの復帰

    ; 終了
    ret

; ロゴを描画する
;
TitlePrintLogoPatternName:

    ; レジスタの保存

    ; パターンネームの描画
    ld      hl, #titleLogoPatternName
    ld      de, #(_patternName + 0x0069)
    ld      b, #0x0f
10$:
    push    bc
    ld      bc, #0x000e
    ldir
    ex      de, hl
    ld      bc, #(0x0020 - 0x000e)
    add     hl, bc
    ex      de, hl
    pop     bc
    djnz    10$

    ; レジスタの復帰

    ; 終了
    ret

TitlePrintLogoSprite:

    ; レジスタの保存

    ; スプライトの描画
    ld      hl, #titleLogoSprite
    ld      de, #(_sprite + TITLE_SPRITE_LOGO)
    ld      bc, #(0x0010 * 0x0004)
    ldir

    ; レジスタの復帰

    ; 終了
    ret

; スコアを描画する
;
TitlePrintScore:

    ; レジスタの保存

    ; パターンネームの描画
    ld      hl, #titleScorePatternName
    ld      de, #(_patternName + 0x000c)
    ld      bc, #0x0003
    ldir
    ld      hl, #(_patternName + 0x0010)
    ld      de, #(_appScore + APP_SCORE_1000)
    ld      b, #(APP_SCORE_LENGTH - 0x01)
10$:
    ld      a, (de)
    or      a
    jr      nz, 11$
    ld      (hl), #0x10
    inc     de
    inc     hl
    djnz    10$
11$:
    inc     b
12$:
    ld      a, (de)
    add     a, #0x10
    ld      (hl), a
    inc     de
    inc     hl
    djnz    12$

    ; レジスタの復帰

    ; 終了
    ret

; HIT SPACE BAR を描画する
;
TitlePrintHitSpaceBar:

    ; レジスタの保存

    ; HIT SPACE BAR の描画
    ld      a, (titleFrame)
    and     #0x20
    rrca
    ld      e, a
    ld      d, #0x00
    ld      hl, #titleHitSpaceBarPatternName
    add     hl, de
    ld      de, #(_patternName + 0x0288)
    ld      bc, #0x0010
    ldir

    ; レジスタの復帰

    ; 終了
    ret

; OPLL を描画する
;
TitlePrintOpll:

    ; レジスタの保存

    ; OPLL の描画
    ld      a, (_slot + SLOT_OPLL)
    cp      #0xff
    jr      z, 19$
    ld      hl, #(_patternName + 0x02a1)
    ld      a, #0xc0
    ld      (hl), a
    inc     a
    inc     hl
    ld      (hl), a
    inc     a
    ld      de, #0x001f
    add     hl, de
    ld      (hl), a
    inc     a
    inc     hl
    ld      (hl), a
19$:

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

; 状態別の処理
;
titleProc:
    
    .dw     TitleNull
    .dw     TitleLoop
    .dw     TitleStart

; ロゴ
;
titleLogoPatternName:

    .db     0xd0, 0xd0, 0xd0, 0xd0, 0xd0, 0xd0, 0xd0, 0xd0, 0xd0, 0xd0, 0xd0, 0xd0, 0xd1, 0xd2
    .db     0xd3, 0xd3, 0xd3, 0xd3, 0xd3, 0xd3, 0xd3, 0xd3, 0xd3, 0xd3, 0xd4, 0xd5, 0xd6, 0xd7
    .db     0xd8, 0xd8, 0xd8, 0xd8, 0xd8, 0xd8, 0xd8, 0xd8, 0xd9, 0xda, 0xdb, 0xdc, 0xdd, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xe0, 0xe1, 0xe2, 0xe3, 0xe4, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xe5, 0xe6, 0xe7, 0xe8, 0xe9, 0xea, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xeb, 0xec, 0xed, 0xee, 0xef, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0xe0, 0xe1, 0xe2, 0xe3, 0xe4, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0xe5, 0xe6, 0xe7, 0xe8, 0xe9, 0xea, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0xeb, 0xec, 0xed, 0xee, 0xef, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0xe0, 0xe1, 0xe2, 0xe3, 0xe4, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0xe5, 0xe6, 0xe7, 0xe8, 0xe9, 0xea, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0x00, 0xeb, 0xec, 0xed, 0xee, 0xef, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    .db     0x00, 0xf0, 0xf1, 0xf2, 0xf3, 0xf4, 0xf5, 0xf5, 0xf5, 0xf5, 0xf5, 0xf5, 0xf5, 0xf5
    .db     0xf6, 0xf7, 0xf8, 0xf9, 0xfa, 0xfa, 0xfa, 0xfa, 0xfa, 0xfa, 0xfa, 0xfa, 0xfa, 0xfa
    .db     0xfb, 0xfc, 0xfd, 0xfd, 0xfd, 0xfd, 0xfd, 0xfd, 0xfd, 0xfd, 0xfd, 0xfd, 0xfd, 0xfd

titleLogoSprite:

    .db     0x06 + 0x08 - 0x01, 0xb4, 0x50, VDP_COLOR_BLACK
    .db     0x15 + 0x08 - 0x01, 0xaa, 0x50, VDP_COLOR_BLACK
    .db     0x24 + 0x08 - 0x01, 0xa0, 0x50, VDP_COLOR_BLACK
    .db     0x33 + 0x08 - 0x01, 0x96, 0x50, VDP_COLOR_BLACK
    .db     0x42 + 0x08 - 0x01, 0x8c, 0x50, VDP_COLOR_BLACK
    .db     0x51 + 0x08 - 0x01, 0x82, 0x50, VDP_COLOR_BLACK
    .db     0x60 + 0x08 - 0x01, 0x78, 0x50, VDP_COLOR_BLACK
    .db     0x28 + 0x08 - 0x01, 0x78, 0x54, VDP_COLOR_BLACK
    .db     0x37 + 0x08 - 0x01, 0x6e, 0x54, VDP_COLOR_BLACK
    .db     0x46 + 0x08 - 0x01, 0x64, 0x54, VDP_COLOR_BLACK
    .db     0x55 + 0x08 - 0x01, 0x5a, 0x54, VDP_COLOR_BLACK
    .db     0x64 + 0x08 - 0x01, 0x50, 0x54, VDP_COLOR_BLACK
    .db     0x73 + 0x08 - 0x01, 0x46, 0x54, VDP_COLOR_BLACK
    .db     0x82 + 0x08 - 0x01, 0x3c, 0x54, VDP_COLOR_BLACK
    .db     0x33 + 0x08 - 0x01, 0xa6, 0x58, VDP_COLOR_BLACK
    .db     0x55 + 0x08 - 0x01, 0x4a, 0x58, VDP_COLOR_BLACK

; スコア
;
titleScorePatternName:

    .db     0x34, 0x2f, 0x30

; HIT SPACE BAR
;
titleHitSpaceBarPatternName:

    .db     0x00, 0x28, 0x29, 0x34, 0x00, 0x33, 0x30, 0x21, 0x23, 0x25, 0x00, 0x22, 0x21, 0x32, 0x00, 0x00
    .db     0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; 状態
;
titleState:
    
    .ds     1

; フレーム
;
titleFrame:

    .ds     1
