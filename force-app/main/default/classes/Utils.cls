public with sharing class Utils {
    public static String formatTime(Long ms) {
        Integer seconds = Integer.valueOf(ms/1000);

        Integer minutes = Integer.valueOf(Math.floor(seconds / 60));
        Integer modSeconds = Math.mod(seconds, 60);

        String minutesStr = minutes == 0 ? '' : String.valueOf(minutes);

    
        return minutesStr + ':' + String.valueOf(modSeconds).leftPad(2,'0');
    }
}