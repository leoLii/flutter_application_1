// 首頁：極光 + 機器人
const String homeSvgHasRobot = r'''
<svg width="553.082989px" height="932.25px" viewBox="0 0 553.082989 932.25" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="lg1" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop stop-color="#3E69A3" offset="0%"/><stop stop-color="#0F2533" offset="100%"/>
    </linearGradient>
    <radialGradient id="auroraA" cx="50%" cy="40%" r="50%">
      <stop stop-color="#A7C7E7" stop-opacity=".55" offset="0%"/>
      <stop stop-color="#A7C7E7" stop-opacity=".18" offset="58%"/>
      <stop stop-color="#3E69A3" stop-opacity="0" offset="100%"/>
    </radialGradient>
    <radialGradient id="auroraB" cx="62%" cy="58%" r="52%">
      <stop stop-color="#76C0AE" stop-opacity=".32" offset="0%"/>
      <stop stop-color="#76C0AE" stop-opacity=".12" offset="72%"/>
      <stop stop-color="#3E69A3" stop-opacity="0" offset="100%"/>
    </radialGradient>
    <radialGradient id="auroraC" cx="37%" cy="63%" r="48%">
      <stop stop-color="#CAB8A2" stop-opacity=".22" offset="0%"/>
      <stop stop-color="#CAB8A2" stop-opacity=".10" offset="70%"/>
      <stop stop-color="#3E69A3" stop-opacity="0" offset="100%"/>
    </radialGradient>
    <radialGradient id="botCore" cx="45%" cy="40%" r="65%">
      <stop stop-color="#2D5C74" offset="0%"/>
      <stop stop-color="#233F40" offset="100%"/>
    </radialGradient>
  </defs>
  <g fill="none" fill-rule="evenodd">
    <g transform="translate(62,0)">
      <rect fill="#3E69A3" x="0" y="0" width="430" height="932" rx="40"/>
      <path d="M0,432.25 L430,432.25 L430,892.25 C430,914.34 412.09,932.25 390,932.25 L40,932.25 C17.91,932.25 0,914.34 0,892.25 L0,432.25 Z" fill="url(#lg1)"/>
    </g>
    <ellipse fill="url(#auroraA)" cx="261.5" cy="401" rx="220" ry="200"/>
    <ellipse fill="url(#auroraB)" transform="translate(315,485) rotate(-12) translate(-315,-485)" cx="315" cy="485" rx="212" ry="182"/>
    <ellipse fill="url(#auroraC)" transform="translate(218,528) rotate(14) translate(-218,-528)" cx="218" cy="528" rx="188" ry="162"/>
    <g transform="translate(225,380)">
      <ellipse fill="url(#botCore)" rx="52" ry="53.5" cx="52" cy="53.5"/>
      <ellipse fill="#A7C7E7" opacity=".08" rx="30.7" ry="23.2" cx="41.85" cy="39.93"/>
      <rect fill="#F6F6F4" x="34" y="45.4" width="9.64" height="19.83" rx="4.82"/>
      <rect fill="#F6F6F4" x="59.86" y="45.4" width="9.64" height="19.83" rx="4.82"/>
    </g>
    <rect stroke-opacity="0.2" stroke="#FFFFFF" fill-opacity="0.1" fill="#FFFFFF" x="364.48291" y="26"  width="105" height="37" rx="14"/>
    <rect stroke-opacity="0.2" stroke="#FFFFFF" fill-opacity="0.1" fill="#FFFFFF" x="224.48291" y="511" width="105" height="45" rx="14"/>
  </g>
</svg>
''';

// 登入頁（無文字版）：卡片高度 240、按鈕 y=186、分隔線 y=176
const String authSvgNoTextsCard240 = r'''
<svg width="553.082989px" height="932.25px" viewBox="0 0 553.082989 932.25" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <linearGradient id="g1" x1="0%" y1="0%" x2="0%" y2="100%"><stop stop-color="#3E69A3" offset="0%"/><stop stop-color="#0F2533" offset="100%"/></linearGradient>
    <radialGradient id="rg2" cx="50%" cy="40%" r="49.0806045%" fx="50%" fy="40%" gradientTransform="translate(0.5,0.4) scale(0.9169,1) translate(-0.5,-0.4)">
      <stop stop-color="#A7C7E7" stop-opacity="0.55" offset="0%"/><stop stop-color="#A7C7E7" stop-opacity="0.18" offset="60%"/><stop stop-color="#3E69A3" stop-opacity="0" offset="100%"/>
    </radialGradient>
    <radialGradient id="rg3" cx="60%" cy="55%" r="46.2365591%" fx="60%" fy="55%" gradientTransform="translate(0.6,0.55) scale(0.8651,1) translate(-0.6,-0.55)">
      <stop stop-color="#76C0AE" stop-opacity="0.4" offset="0%"/><stop stop-color="#76C0AE" stop-opacity="0.1" offset="70%"/><stop stop-color="#3E69A3" stop-opacity="0" offset="100%"/>
    </radialGradient>
    <radialGradient id="rg4" cx="40%" cy="58%" r="43.9161677%" fx="40%" fy="58%" gradientTransform="translate(0.4,0.58) scale(0.8653,1) translate(-0.4,-0.58)">
      <stop stop-color="#CAB8A2" stop-opacity="0.3" offset="0%"/><stop stop-color="#CAB8A2" stop-opacity="0.1" offset="70%"/><stop stop-color="#3E69A3" stop-opacity="0" offset="100%"/>
    </radialGradient>
    <linearGradient id="softStroke" x1="0%" y1="0%" x2="0%" y2="100%"><stop stop-color="#FFFFFF" stop-opacity="0.12" offset="0%"/><stop stop-color="#FFFFFF" stop-opacity="0.06" offset="100%"/></linearGradient>
  </defs>
  <g fill="none" fill-rule="evenodd">
    <g transform="translate(62,0)">
      <rect fill="#3E69A3" x="0" y="0" width="430" height="932" rx="40"/>
      <path d="M0,432.25 L430,432.25 L430,892.25 C430,914.34139 412.09139,932.25 390,932.25 L40,932.25 C17.90861,932.25 0,914.34139 0,892.25 L0,432.25 Z" fill="url(#g1)"/>
    </g>
    <ellipse fill="url(#rg2)" cx="261.5" cy="401.5" rx="216.5" ry="198.5"/>
    <ellipse fill="url(#rg3)" transform="translate(311.7705,483.1076) rotate(-12) translate(-311.7705,-483.1076)" cx="311.770466" cy="483.107613" rx="208.384557" ry="180.276872"/>
    <ellipse fill="url(#rg4)" transform="translate(220.6628,527.6922) rotate(14) translate(-220.6628,-527.6922)" cx="220.662799" cy="527.692216" rx="187.061486" ry="161.861493"/>
    <g transform="translate(96.4829,320)">
      <rect stroke-opacity="0.12" stroke="#FFFFFF" fill-opacity="0.06" fill="#FFFFFF" x="0" y="0" width="370" height="240" rx="18"/>
      <rect stroke-opacity="0.18" stroke="#FFFFFF" fill="url(#softStroke)" x="16" y="44"  width="338" height="44" rx="12"/>
      <rect stroke-opacity="0.18" stroke="#FFFFFF" fill="url(#softStroke)" x="16" y="114" width="338" height="44" rx="12"/>
      <rect fill="#A7C7E7" x="16" y="186" width="338" height="40" rx="12"/>
      <!-- 上方細分隔線由 Flutter 疊加 (y=176) -->
    </g>
  </g>
</svg>
''';

// 返回箭頭 / Apple / Facebook / Google
const String backArrowPath = r'''
<svg viewBox="0 0 33 28" xmlns="http://www.w3.org/2000/svg">
  <path d="M118.014917,45.9808752 L89.6365881,45.9808752 L102.586292,34.6886655 C102.992919,34.334099 103.029545,33.7232303 102.668124,33.3243153 C102.306627,32.9255115 101.684138,32.8895061 101.277359,33.2440725 L86.3306161,46.2776327 C86.1203099,46.4610714 86,46.7238999 86,46.9999663 C86,47.2760327 86.12031,47.5388613 86.3306161,47.7222999 L101.277397,60.7559343 C101.465062,60.9195718 101.69869,61 101.931485,61 C102.203062,61 102.473542,60.8904634 102.668162,60.6756544 C103.029583,60.2767394 102.992957,59.6659077 102.58633,59.3112671 L89.5157112,47.9136738 L118.014917,47.9136738 C118.558977,47.9136738 119,47.4809782 119,46.9472745 C119,46.4135338 118.558977,45.9808752 118.014917,45.9808752 Z"
        fill="#FFFFFF" fill-rule="nonzero" transform="translate(-86,-33)"/>
</svg>
''';

const String appleWhitePath = r'''
<svg viewBox="0 0 28 28" xmlns="http://www.w3.org/2000/svg">
  <path d="M221,576 C228.732,576 235,582.268 235,590 C235,597.732 228.732,604 221,604 C213.268,604 207,597.732 207,590 C207,582.268 213.268,576 221,576 Z M223.808,585.0416 C223.5968,585.0416 223.3904,585.08 223.1888,585.1568 C222.9872,585.2336 222.7472,585.3488 222.4688,585.5024 C222.2096,585.656 221.9504,585.7616 221.6912,585.8192 C221.432,585.8768 221.24,585.9056 221.1152,585.9056 C221.0096,585.9056 220.8608,585.8744 220.6688,585.812 C220.4768,585.7496 220.232,585.6368 219.9344,585.4736 C219.656,585.3296 219.3872,585.2312 219.128,585.1784 C218.8688,585.1256 218.6336,585.0992 218.4224,585.0992 C217.4624,585.0992 216.656,585.512 216.0032,586.3376 C215.3696,587.1632 215.0528,588.224 215.0528,589.52 C215.0528,590.9216 215.4704,592.3472 216.3056,593.7968 C217.1408,595.2656 217.9904,596 218.8544,596 C219.152,596 219.5312,595.9088 219.992,595.7264 C220.4336,595.5344 220.8368,595.4384 221.2016,595.4384 C221.5664,595.4384 221.9936,595.5296 222.4832,595.712 C223.0112,595.8944 223.4096,595.9856 223.6784,595.9856 C224.3984,595.9856 225.128,595.4288 225.8672,594.3152 C226.3472,593.576 226.6976,592.8656 226.9184,592.184 C226.4096,592.0208 225.9584,591.6608 225.5648,591.104 C225.1712,590.5376 224.9744,589.904 224.9744,589.2032 C224.9744,588.5696 225.1616,587.984 225.536,587.4464 C225.7376,587.1584 226.0592,586.8224 226.5008,586.4384 C226.2032,586.064 225.9104,585.7808 225.6224,585.5888 C225.0848,585.224 224.48,585.0416 223.808,585.0416 L223.808,585.0416 Z"
        fill="#FFFFFF" fill-rule="nonzero" transform="translate(-207,-576)"/>
</svg>
''';

const String facebookBluePath = r'''
<svg viewBox="0 0 28 28" xmlns="http://www.w3.org/2000/svg">
  <path d="M281,576 C273.268014,576 267,582.268014 267,590 C267,597.731986 273.268014,604 281,604 C288.731986,604 295,597.731986 295,590 C295,586.286969 293.525004,582.726014 290.899495,580.100505 C288.273986,577.474996 284.713031,576 281,576 Z M284.877288,589.698644 L282.409492,589.698644 L282.409492,599.332542 L279.028136,599.332542 L279.028136,589.691525 L276.743051,589.691525 L276.743051,586.844068 L278.722034,586.844068 L278.722034,584.497288 C278.722034,583.998983 278.622373,580.667458 282.886441,580.667458 L285.242712,580.667458 L285.242712,583.514915 L283.372881,583.514915 C282.64678,583.514915 282.423729,583.711864 282.423729,584.449831 L282.423729,586.846441 L285.254576,586.846441 L284.877288,589.698644 Z"
        fill="#0866FF" fill-rule="nonzero" transform="translate(-267,-576)"/>
</svg>
''';

const String googleGGroup = r'''
<svg viewBox="0 0 26 26" xmlns="http://www.w3.org/2000/svg">
  <g fill-rule="nonzero">
    <path d="M5.44043983,13.0058182 C5.44043983,12.1611554 5.58509667,11.3514096 5.83949317,10.5915456 L1.36344497,7.24448577 C0.464198089,9.03170841 -0.00281368911,11.0051179 0,13.0058182 C0,15.0759074 0.490515806,17.029606 1.36178225,18.7638253 L5.834505,15.4101146 C5.57439636,14.6352131 5.44187022,13.8232097 5.44210256,13.0058182" fill="#FFB900"></path>
    <path d="M13.3017905,5.32071617 C15.1756784,5.32071617 16.8683296,5.96917783 18.1985074,7.03332005 L22.067662,3.25062701 C19.630105,1.15087448 16.519031,-0.00279580738 13.3017905,0 C8.04592554,0 3.52830929,2.94302341 1.36344497,7.24448577 L5.84281861,10.5915456 C6.87370638,7.52548582 9.81339926,5.32071617 13.3017905,5.32071617" fill="#FE2B25"></path>
    <path d="M13.3017905,20.6909203 C9.81173653,20.6909203 6.87204366,18.4861507 5.83949317,15.4200909 L1.36344497,18.7671507 C3.52664657,23.0686131 8.04426282,26.0116314 13.3017905,26.0116314 C16.5457615,26.0116314 19.643413,24.8843057 21.9678986,22.7693231 L17.7179807,19.5536183 C16.5208207,20.2935297 15.0110689,20.6909203 13.3017905,20.6909203" fill="#00AB47"></path>
    <path d="M26,13.0058182 C26,12.2376406 25.8769586,11.4096049 25.6957218,10.6414273 L13.3017905,10.6414273 L13.3017905,15.6661738 L20.4348688,15.6661738 C20.118751,17.2870156 19.1326158,18.6988858 17.7196434,19.5536183 L21.9678986,22.7709858 C24.4104376,20.5512516 26,17.2457599 26,13.0058182" fill="#1F87FC"></path>
  </g>
</svg>
''';

// 主諮商頁：包裝成 553 畫布（與其他頁一致）
const String sessionSvgWrapped = r'''
<svg width="553.082989px" height="932.25px" viewBox="0 0 553.082989 932.25" xmlns="http://www.w3.org/2000/svg">
  <rect fill="#0C1C24" x="0" y="0" width="553.082989" height="932.25"/>
  <g transform="translate(62,0)">
    <defs>
      <linearGradient x1="0%" y1="0%" x2="0%" y2="100%" id="linearGradient-9gdwsgu9yo-1">
        <stop stop-color="#3E69A3" offset="0%"></stop>
        <stop stop-color="#0F2533" offset="100%"></stop>
      </linearGradient>
      <radialGradient cx="50%" cy="50%" fx="50%" fy="50%" r="50%" gradientTransform="translate(0.5, 0.5), scale(1, 0.9677), translate(-0.5, -0.5)" id="radialGradient-9gdwsgu9yo-2">
        <stop stop-color="#A7C7E7" stop-opacity="0" offset="0%"></stop>
        <stop stop-color="#7FB3D5" stop-opacity="0.22" offset="45%"></stop>
        <stop stop-color="#76C0AE" stop-opacity="0.28" offset="60%"></stop>
        <stop stop-color="#CAB8A2" stop-opacity="0.22" offset="75%"></stop>
        <stop stop-color="#CB6052" stop-opacity="0.18" offset="88%"></stop>
        <stop stop-color="#A7C7E7" stop-opacity="0" offset="100%"></stop>
      </radialGradient>
      <radialGradient cx="50%" cy="50%" fx="50%" fy="50%" r="59.119725%" gradientTransform="translate(0.5, 0.5), scale(0.8457, 1), translate(-0.5, -0.5)" id="radialGradient-9gdwsgu9yo-3">
        <stop stop-color="#A7C7E7" stop-opacity="0" offset="0%"></stop>
        <stop stop-color="#7FB3D5" stop-opacity="0.22" offset="45%"></stop>
        <stop stop-color="#76C0AE" stop-opacity="0.28" offset="60%"></stop>
        <stop stop-color="#CAB8A2" stop-opacity="0.22" offset="75%"></stop>
        <stop stop-color="#CB6052" stop-opacity="0.18" offset="88%"></stop>
        <stop stop-color="#A7C7E7" stop-opacity="0" offset="100%"></stop>
      </radialGradient>
      <radialGradient cx="45%" cy="40%" fx="45%" fy="40%" r="65%" gradientTransform="translate(0.45, 0.4), scale(1, 0.972), translate(-0.45, -0.4)" id="radialGradient-9gdwsgu9yo-5">
        <stop stop-color="#3E69A3" offset="0%"></stop>
        <stop stop-color="#233F40" offset="100%"></stop>
      </radialGradient>
    </defs>
    <g stroke="none" fill="none" fill-rule="evenodd">
      <g>
        <rect fill="#3E69A3" x="0" y="0" width="430" height="932" rx="40"></rect>
        <path d="M0,432.25 L430,432.25 L430,892.25 C430,914.34139 412.09139,932.25 390,932.25 L40,932.25 C17.90861,932.25 0,914.34139 0,892.25 L0,432.25 Z" fill="url(#linearGradient-9gdwsgu9yo-1)"></path>
      </g>
      <g transform="translate(115.2575, 19.9871)">
        <g>
          <ellipse fill="url(#radialGradient-9gdwsgu9yo-2)" cx="100.716321" cy="92.2614541" rx="74.7115241" ry="77.2060127"></ellipse>
          <ellipse fill="url(#radialGradient-9gdwsgu9yo-3)" opacity="0.7" transform="translate(100.7425, 92.5129) rotate(-18) translate(-100.7425, -92.5129)" cx="100.742472" cy="92.5129241" rx="83.0930863" ry="70.2752645"></ellipse>
          <ellipse fill="url(#radialGradient-9gdwsgu9yo-4)" opacity="0.6" transform="translate(100.7425, 92.5129) rotate(22) translate(-100.7425, -92.5129)" cx="100.742472" cy="92.5129241" rx="78.3227526" ry="66.833241"></ellipse>
        </g>
        <g transform="translate(48.7425, 38.0129)">
          <ellipse fill="url(#radialGradient-9gdwsgu9yo-5)" cx="52" cy="53.5" rx="52" ry="53.5"></ellipse>
          <ellipse fill="#A7C7E7" opacity="0.08" cx="41.8536585" cy="39.9292683" rx="30.6926829" ry="23.2268293"></ellipse>
          <rect fill="#F6F6F4" x="33.9902439" y="45.4097561" width="9.63902439" height="19.8341463" rx="4.8195122"></rect>
          <rect fill="#F6F6F4" x="59.8634146" y="45.4097561" width="9.63902439" height="19.8341463" rx="4.8195122"></rect>
        </g>
      </g>
      <g transform="translate(185, 836)">
        <circle fill-opacity="0.08" fill="#FFFFFF" cx="30.5" cy="30.5" r="30.5"></circle>
        <circle fill-opacity="0.10" fill="#FFFFFF" cx="30" cy="31" r="25"></circle>
        <circle fill="#EAF0F6" opacity="0.95" cx="30.5" cy="30.5" r="15.5"></circle>
        <circle stroke="#A7C7E7" stroke-width="4" opacity="0.7" cx="30.5" cy="30.5" r="20.5"></circle>
        <circle stroke="#76C0AE" stroke-width="4" opacity="0.45" cx="30.5" cy="30.5" r="24.5"></circle>
      </g>
    </g>
  </g>
</svg>
''';
