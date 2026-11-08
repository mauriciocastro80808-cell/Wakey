set -e
M=android/app/src/main/AndroidManifest.xml
for p in POST_NOTIFICATIONS SCHEDULE_EXACT_ALARM USE_EXACT_ALARM USE_FULL_SCREEN_INTENT WAKE_LOCK VIBRATE RECEIVE_BOOT_COMPLETED; do
  grep -q "android.permission.$p" $M || sed -i "s#<application#<uses-permission android:name=\"android.permission.$p\" />\n    <application#" $M
done
mkdir -p android/app/src/main/res/raw
python3 - <<'PY'
import wave,struct,math
sr=22050;fr=bytearray()
def tone(d,f):
    n=int(sr*d)
    for i in range(n):
        e=min(1,i/300,(n-i)/300);fr.extend(struct.pack('<h',int(13000*e*math.sin(2*math.pi*f*i/sr))))
def sil(d):fr.extend(b'\x00\x00'*int(sr*d))
while len(fr)<30*sr*2:
    for k in range(4):tone(.14,1300 if k%2 else 1000);sil(.1)
    sil(.7)
w=wave.open('android/app/src/main/res/raw/alarm.wav','wb');w.setnchannels(1);w.setsampwidth(2);w.setframerate(sr);w.writeframes(bytes(fr));w.close()
PY
