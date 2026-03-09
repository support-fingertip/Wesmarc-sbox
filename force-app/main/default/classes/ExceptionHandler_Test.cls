@isTest
public class ExceptionHandler_Test {

  public static testmethod void test1(){
        Exception ex = new DMLException();
        ex.setMessage('dd');
        ExceptionHandler.addLog(ex,'test');
        ExceptionHandler.addLog(1,'test','test','test','test');
        ExceptionHandler.addLog(ex);
      ExceptionHandler.addLog(ex, 'data', 'className', 'recordId');
    }

}