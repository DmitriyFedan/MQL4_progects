//--------------------------------------------------------------------
// tradingexpert.mq4 
// Предназначен для использования в качестве примера в учебнике MQL4.
//--------------------------------------------------------------------
#property copyright "Copyright © Book, 2007"
#property link      "http://AutoGraf.dp.ua"
//--------------------------------------------------------------- 1 --
   // Численные значения для H4 GBP USD - MA 20  MA3 34,  Period MA_FLAT=17, Fact_point=25, TP_value=1300, TF240, Delta_MA_FLAT=0.0014
   // Численные значения для H4 GBP JPY - MA1 15, MA2 15,  MA3 54,  Period MA_FLAT=10, Fact_point=50, TP_value=1250, TF240, Delta_MA_FLAT=0.06
   
   
//f// 6499	2648.64	17	15.86	155.80	146.87	9.56%	0.00000000	Period_Fast_MA=29 	Period_Slow_MA=47 	MACD_Fast_EMA=24 	MACD_Slow_EMA=68 	Fact_point=150 	TP_value=3000 	SL_value=-200 	Delta_MAprice_open=1.1 	Delta_MAprice_close=7.1 	bar_MACD_1=7 	bar_MACD_2=9	Period_MA_FLAT=40 	MACD_SMA=9 	Delta_MA_FLAT=0.4 	Delta_MA_FLAT_2=0.4 	MA_Fast_bar=0 	MA_Slow_bar=0 	Shift_MA_Fast=0 	Shift_MA_Slow=0 	Shift_MA_FLAT=0 	LOT=0.1 	magic_number=102
//  4886	2622.27	18	14.40	145.68	179.61	12.07%	0.00000000	Period_Fast_MA=30 	Period_Slow_MA=45 	MACD_Fast_EMA=26 	MACD_Slow_EMA=60 	Fact_point=150 	TP_value=3000 	SL_value=-200 	Delta_MAprice_open=1.1 	Delta_MAprice_close=4.5 	bar_MACD_1=2 	bar_MACD_2=14	Period_MA_FLAT=40 	MACD_SMA=9 	Delta_MA_FLAT=0.4 	Delta_MA_FLAT_2=0.4 	MA_Fast_bar=0 	MA_Slow_bar=0 	Shift_MA_Fast=0 	Shift_MA_Slow=0 	Shift_MA_FLAT=0 	LOT=0.1 	magic_number=102

   
bool Work=true;                    // Эксперт будет работать.
string Symb;                       // Название финанс. инструмента
//--------------------------------------------------------------- 2 --
// ------------ВХОДНЫЕ ДАННЫЕ----------------------------------------
 
input   int    Period_Fast_MA=29;      // период МА1 красная 
input   int    Period_Slow_MA=47;           // Период МА3 зеленая                                      /// пртестить плывущий  тр  от  МА тоесть если разница                      
input   int    MACD_Fast_EMA= 24;    // Период MAСВ 
input   int    MACD_Slow_EMA=68;      // период МАCD   
input   int    MACD_SMA=9;               // период MACD
input   int    Fact_point=150;          // Пунктов для критерия Fact_up  Fact_dn
input   int    TP_value=3000;            // Значене ТР  
input   int    SL_value=-200;              //Значение для SL
input   double Delta_MAprice_open=1.1;    
input   double Delta_MAprice_close=7.1;
input   int    bar_MACD_1 = 7;        
input   int    bar_MACD_2 = 9;
input   int    MA_Fast_bar=0;            // номер бара для  МА быстрой
input   int    MA_Slow_bar=0;            // номер бара для МА Медленной
input   int    Shift_MA_Fast=0;
input   int    Shift_MA_Slow=0;
input   int    Shift_MA_FLAT=0;
input double    LOT = 0.1;                     // используемый лот
int       TF_H1=60;
int       TF_H4=240; 
int       TF_D1=1440;                         // таймфорейм d
input int       magic_number=101;

bool 
     lable_1_create=true,
     lable_2_create=true,
     lable_3_create=true,
     lable_4_create=true,
     lable_5_create=true;
     
double number =1.5;     
       
double price_open_1 = 0;                      // 
int  FLAT_last_value= 0;                      // 


string GV_Fact_up="GV_Fact_up_GBPGPY";
string GV_Fact_dn="GV_Fact_dn_GBPGPY"; 
 
double       Fact_up;
double       Fact_dn;         
//-----------------------------------------------------------------
//-------------- основной код-------------------------------------

int start()
  {                      
   int
   Total,                           // Количество ордеров в окне 
   Tip=-1,                          // Тип выбран. ордера (B=0,S=1)
   Ticket;                          // Номер ордера
   double
   MA_1,                          // Значен. МА_1 fast
   MA_2,                          // Значен. МА_2 fast
   MA_3,                            // значен. МА_3 slow                        
   Lot,                             // Колич. лотов в выбран.ордере
   Price,                           // Цена выбранного ордера
   SL,                              // SL выбранного ордера 
   TP;                              // TP выбранного ордера
   bool
   Ans  =false,                     // Ответ сервера после закрытия
   Cls_B=false,                     // Критерий для закрытия  Buy
   Cls_S=false,                     // Критерий для закрытия  Sell
   Opn_B=false,                     // Критерий для открытия  Buy
   Opn_S=false,                     // Критерий для открытия  Sell
   Trend_Up=false,
   Trend_Down=false,
   Trend_Up_MACD=false,
   Trend_Down_MACD=false;
                            
    Fact_up= GlobalVariableGet(GV_Fact_up);
    Fact_dn= GlobalVariableGet(GV_Fact_dn);                           
   
         
//--------------------------------------------------------------- 3 --
//--------------- Предварит.обработка-----------------------------
   if(Bars < Period_Slow_MA)                       // Недостаточно баров
     {
      Alert("Недостаточно баров в окне. Эксперт не работает.");
      return;                                   // Выход из start()
     }
   if(Work==false)                              // Критическая ошибка
     {
      Alert("Критическая ошибка. Эксперт не работает.");
      return;                                   // Выход из start()
     }
//--------------------------------------------------------------- 
//-------------------УЧЕТ ОРДЕРОВ--------------------------------
   Symb=Symbol();                               // Название фин.инстр.
   Total=0;                                     // Количество ордеров
   for(int i=1; i<=OrdersTotal(); i++)          // Цикл перебора ордер
     {
      if (OrderSelect(i-1,SELECT_BY_POS)==true) // Если есть следующий
        {                                       // Анализ ордеров:
         if (OrderMagicNumber()!=magic_number)continue;      //  если ордер открыт не нашим экспертом
         Total++;                               // Счётчик рыночн. орд
         if (Total>1)                           // Не более 1 орд
           {
            Alert("более 1 рыночных ордеров. Эксперт не работает.");
            return;                             // Выход из start()
           }
         Ticket=OrderTicket();                  // Номер выбранн. орд.
         Tip   =OrderType();                    // Тип выбранного орд.
         Price =OrderOpenPrice();               // Цена выбранн. орд.
         SL    =OrderStopLoss();                // SL выбранного орд.
         TP    =OrderTakeProfit();              // TP выбранного орд.
         Lot   =OrderLots();                    // Количество лотов
        }
     }
//--------------------------------------------------------------- 
//----------------ВЫЗОВ ИНДИКАТОРОВ------------------------------

   MA_1=iMA(NULL,TF_H4,Period_Fast_MA,Shift_MA_Fast,MODE_SMA,PRICE_LOW,MA_Fast_bar);   // МА_1 быстрая по  минимумам цен  основной таймфрейм
   MA_2=iMA(NULL,TF_H4,Period_Fast_MA,Shift_MA_Fast,MODE_SMA,PRICE_HIGH,MA_Fast_bar);  // МА_2 быстрая по максимума цен  основной таймфрейм 
   
   MA_3=iMA(NULL,TF_H4,Period_Slow_MA,Shift_MA_Slow,MODE_SMA,PRICE_MEDIAN,MA_Slow_bar);       // MA_3 медленная по медиане цен
   
//-----------------------------------------------------------------
//--------------КРИТЕРИИ-------------------------------------------

//Критерии на покупку
    // Восходящий тренд  
   if (MACD_value(TF_D1,bar_MACD_1) > MACD_value(TF_D1,bar_MACD_2))                  Trend_Up_MACD= true;
   if (Ask> MA_1 && Ask>MA_2 && MA_2>MA_3 && MA_1>MA_3)                              Trend_Up= true;  
   if (MathAbs(MA_2-Ask) <Delta_MAprice_open && Total==0 )                           Opn_B=true;   
   if (Ask<MA_1- Fact_point*Point&& Total==0)                                        
    {
    Fact_up=20;
    GlobalVariableSet(GV_Fact_up, Fact_up);
    } 
                                                      
   

//Критерии на продажу
    // Нисходящий тренд      
   if ( MACD_value(TF_D1,bar_MACD_1)< MACD_value(TF_D1,bar_MACD_2))                  Trend_Down_MACD=true;
   if (Bid<MA_1 && Bid< MA_2 && MA_1<MA_3 && MA_2<MA_3)                              Trend_Down= true;   
   if (MathAbs(MA_1-Bid) <Delta_MAprice_open && Total==0 )                           Opn_S=true;                              
   if (Bid> MA_2+Fact_point*Point && Total==0)                                       
   {
    Fact_dn=20; 
    GlobalVariableSet(GV_Fact_dn,Fact_dn);
   }

  
 
  
// Критерии на закрытие покупки
   if ( (Tip==0 && Bid < MA_1) || (Tip==0 && MathAbs(MA_2 -Bid) > Delta_MAprice_close))              Cls_B= true;
   
  

// Критерии на закрытие продажи 
   if ( (Tip ==1 && Ask > MA_2 ) || (Tip==1 && MathAbs(MA_1-Ask)> Delta_MAprice_close))                Cls_S=true;
   
 
      
//Критерии ФЛЭТА
   
//Здесь должны быть критерии флета
 
 /// --------создание текстовой метки по критерию флет  --------
/*  
  if (FLAT_last_value!=FLAT)
  {
   FLAT_last_value=FLAT;
  string string_number = (DoubleToString(number,1));   // преобразование номера из тип число  в тип строка      ---- last using  -- ---
   string name_lable= ("flat");                         // текст   метки 
   StringAdd(name_lable,string_number);                 // добавление номера к тексту метки       
   ObjectCreate(name_lable,OBJ_TEXT,0,iTime(NULL,PERIOD_H4,0),iLow(NULL,TF_H4,0)-500*Point);          // объявение текстовой метки 
   string text_lable_FLAT= "Fl";
   if (FLAT==0) text_lable_FLAT="fE";
   if (FLAT==1) text_lable_FLAT="fS"; 
   ObjectSetText(name_lable,text_lable_FLAT,10,"Arial",Red);
   Alert (GetLastError());                                             // запрос последней ошибки 
   number=number+1;                                                    // увеличение счетчика номера на 1 
  }

*/

  
// -- - -- - - ИНдикация и коммуникация- - - - -

string name_lable_1 ="Trend status";
string name_lable_2 = "Fact Up status"; 
string name_lable_3 = "Opn";
string name_lable_4 = "FLAT";
string name_lable_5 = "Fact Down status";

if (lable_1_create==true)                    //  создание лейбла показывающего статус Trend    если он еще не существует 
{   
ObjectCreate(name_lable_1,OBJ_LABEL,0,0,0);
lable_1_create=false; 
ObjectSet(name_lable_1,OBJPROP_CORNER,0);
ObjectSet(name_lable_1,OBJPROP_XDISTANCE,1600); 
ObjectSet(name_lable_1,OBJPROP_YDISTANCE,20); 
}

if (lable_2_create==true)                     // создание лейбла показывающего статус Fact    если он еще не существует
{
 ObjectCreate(name_lable_2,OBJ_LABEL,0,0,0);
 lable_2_create=false;
 ObjectSet(name_lable_2,OBJPROP_CORNER,0);
ObjectSet(name_lable_2,OBJPROP_XDISTANCE,1600); 
ObjectSet(name_lable_2,OBJPROP_YDISTANCE,40); 
 }
 
 if (lable_3_create==true)                     // создание лейбла показывающего статус opn    если он еще не существует
{
 ObjectCreate(name_lable_3,OBJ_LABEL,0,0,0);
 lable_3_create=false;
 ObjectSet(name_lable_3,OBJPROP_CORNER,0);
ObjectSet(name_lable_3,OBJPROP_XDISTANCE,1600); 
ObjectSet(name_lable_3,OBJPROP_YDISTANCE,80); 
 }
 
 if (lable_4_create==true)                     // создание лейбла показывающего статус FLAT    если он еще не существует
{
 ObjectCreate(name_lable_4,OBJ_LABEL,0,0,0);
 lable_4_create=false;
 ObjectSet(name_lable_4,OBJPROP_CORNER,0);
ObjectSet(name_lable_4,OBJPROP_XDISTANCE,1600); 
ObjectSet(name_lable_4,OBJPROP_YDISTANCE,100); 
 }

if (lable_5_create==true)                     // создание лейбла показывающего статус FLAT    если он еще не существует
{
 ObjectCreate(name_lable_5,OBJ_LABEL,0,0,0);
 lable_5_create=false;
 ObjectSet(name_lable_5,OBJPROP_CORNER,0);
ObjectSet(name_lable_5,OBJPROP_XDISTANCE,1600); 
ObjectSet(name_lable_5,OBJPROP_YDISTANCE,60); 
}

 
 
  
 
 if (iOpen(NULL,TF_H4,1)!= price_open_1)
  {
   price_open_1= iOpen(NULL,TF_H4,1);
   
   string text_lable_1 = "Trend NOT DETECTED";
   string text_lable_2 = "Fact Up - FALSE";
   string text_lable_3 = "Opn NOT DETECTED";
   string text_lable_4 = "Trend MACD NOT DETECTED";
   string text_lable_5 = "Fact Down - FALSE";
   if( Trend_Up==true)   text_lable_1="Trend Up";
   if( Trend_Down==true) text_lable_1="Trend Down";
   if (Fact_up==20)      text_lable_2="Fact Up - TRUE";
   if (Fact_dn==20)      text_lable_5="Fact Down -TRUE";
   if (Opn_B==true)      text_lable_3="Opn Buy";
   if (Opn_S==true)      text_lable_3="Opn Sell";
   if (Trend_Up_MACD==true)   text_lable_4="Trend MACD UP";
   if (Trend_Down_MACD==true) text_lable_4="Trend MACD DOWN";
     
   ObjectSetText(name_lable_1,text_lable_1,10,"Arial",Black);
   ObjectSetText(name_lable_2,text_lable_2,10,"Arial",Black);
   ObjectSetText(name_lable_3,text_lable_3,10,"Arial",Black);
   ObjectSetText(name_lable_4,text_lable_4,10,"Arial",Black);
   ObjectSetText(name_lable_5,text_lable_5,10,"Arial",Black);
        
 Alert(GetLastError());
   }
            
//---------------------------------------------------------------
//------------ЗАКРЫТИЕ ОРДЕРОВ-----------------------------------

   while(true)                                  // Цикл закрытия орд.
     {
      if ((Tip==0 && Cls_B==true ))     // Открыт ордер Buy..
        {                                       
         Alert("Попытка закрыть Buy ",Ticket,". Ожидание ответа..");
         RefreshRates();                        // Обновление данных
         Ans=OrderClose(Ticket,Lot,Bid,2,Red);      // Закрытие Buy
         if (Ans==true)                         // Получилось :)
           {    
            Alert ("Закрыт ордер Buy ",Ticket);
            break;                              // Выход из цикла закр
           }
         if (Fun_Error(GetLastError())==1)      // Обработка ошибок
            continue;                           // Повторная попытка
         return;                                // Выход из start()
        }
 
      if ((Tip==1 && Cls_S==true) )                // Открыт ордер Sell..
        {                                       // и есть критерий закр
         Alert("Попытка закрыть Sell ",Ticket,". Ожидание ответа..");
         RefreshRates();                        // Обновление данных
         Ans=OrderClose(Ticket,Lot,Ask,2,Red);      // Закрытие Sell
         if (Ans==true)                         // Получилось :)
           {
            Alert ("Закрыт ордер Sell ",Ticket);
            break;                              // Выход из цикла закр
           }
         if (Fun_Error(GetLastError())==1)      // Обработка ошибок
            continue;                           // Повторная попытка
         return;                                // Выход из start()
        }
      break;                                    // Выход из while
     }
     
//---------------------------------------------------------------  
//----------------ОТКРЫТИЕ ОРДЕРОВ-------------------------------

// ---------------------- открытие ордеров на покупку --------------------
   while(true)                                  
     {
     if (Total==0  && Trend_Up==true && Opn_B==true && Fact_up==20  && Trend_Up_MACD==true)            // критерий откр. Buy  // Открытых орд. нет +    
        {                                       
         RefreshRates();                           // Обновление данных
         SL=MA_1-SL_value*Point;                    // Вычисление SL откр.
         TP=Ask+TP_value*Point;                    // Вычисление TP откр.
         Fact_up=10;
         GlobalVariableSet(GV_Fact_up,Fact_up);
         
         Alert("Попытка открыть Buy. Ожидание ответа..");
         Ticket=OrderSend(Symb,OP_BUY,LOT,Ask,2,SL,TP,"",magic_number,0,Green);//Открытие Buy
         if (Ticket > 0)                        // Получилось :)
           {
            Alert ("Открыт ордер Buy ",Ticket);
            return;                             // Выход из start()
           }
         if (Fun_Error(GetLastError())==1)      // Обработка ошибок
            continue;                           // Повторная попытка
        return;                                // Выход из start()
        }
    
 // ------------------- открытие ордеров на продажу ---------------  
    
       if ( Total==0  && Trend_Down==true && Opn_S==true && Fact_dn==20  && Trend_Down_MACD==true )              // Открытых орд. нет +     
        {                                       
         RefreshRates();                        // Обновление данных
         SL=MA_2+SL_value*Point;                    // Вычисление SL откр.
         TP=Bid-TP_value*Point;                    // Вычисление TP откр.
         Fact_dn=10;
         GlobalVariableSet(GV_Fact_dn, Fact_dn);
         
         
         Alert("Попытка открыть Sell. Ожидание ответа..");
         Ticket=OrderSend(Symb,OP_SELL,LOT,Bid,2,SL,TP,"",magic_number,0,Blue);//Открытие Sel
         if (Ticket > 0)                        // Получилось :)
           {
            Alert ("Открыт ордер Sell ",Ticket);
            return;                             // Выход из start()
           }
         if (Fun_Error(GetLastError())==1)      // Обработка ошибок
            continue;                           // Повторная попытка
         return;                                // Выход из start()
        }
      break;                                    // Выход из while
     }
       
//--------------------------------------------------------------- 9 --
   return;                                      // Выход из start()
  }
//-------------------------------------------------------------- 10 --
int Fun_Error(int Error)                        // Ф-ия обработ ошибок
  {
   switch(Error)
     {                                          // Преодолимые ошибки            
      case  4: Alert("Торговый сервер занят. Пробуем ещё раз..");
         Sleep(3000);                           // Простое решение
         return(1);                             // Выход из функции
      case 135:Alert("Цена изменилась. Пробуем ещё раз..");
         RefreshRates();                        // Обновим данные
         return(1);                             // Выход из функции
      case 136:Alert("Нет цен. Ждём новый тик..");
         while(RefreshRates()==false)           // До нового тика
            Sleep(1);                           // Задержка в цикле
         return(1);                             // Выход из функции
      case 137:Alert("Брокер занят. Пробуем ещё раз..");
         Sleep(3000);                           // Простое решение
         return(1);                             // Выход из функции
      case 146:Alert("Подсистема торговли занята. Пробуем ещё..");
         Sleep(500);                            // Простое решение
         return(1);                             // Выход из функции
         // Критические ошибки
      case  2: Alert("Общая ошибка.");
         return(0);                             // Выход из функции
      case  5: Alert("Старая версия терминала.");
         Work=false;                            // Больше не работать
         return(0);                             // Выход из функции
      case 64: Alert("Счет заблокирован.");
         Work=false;                            // Больше не работать
         return(0);                             // Выход из функции
      case 133:Alert("Торговля запрещена.");
         return(0);                             // Выход из функции
      case 134:Alert("Недостаточно денег для совершения операции.");
         return(0);                             // Выход из функции
      default: Alert("Возникла ошибка ",Error); // Другие варианты   
         return(0);                             // Выход из функции
     }
  }
//-------------------------------------------------------------- 11 --
double Median_price_range(int a )             // Функция расчета средней цены в диапазоне баров от 1 до а
 {
   double Median_summ;
   double Median_g_bar;
   for (int g=1; g<=a; g++)
      {
       Median_g_bar = ((High[g]+Low[g])/2);
       Median_summ +=  Median_g_bar; 
       if (g==a)Median_summ /=a;
      }
     return(Median_summ);
  }

double MA_value( int a_TF, int b_Per,int c_Bar )            // Функция возвращает значение МА_FLAT  на баре номер а
 {
 double MA_value = iMA (NULL,a_TF,b_Per,Shift_MA_FLAT,MODE_SMA,PRICE_MEDIAN,c_Bar);
  return (MA_value);
 }
 
double MACD_value(int a_TF, int b_Bar)
  {
   double MACD_value = iMACD(NULL,a_TF,MACD_Fast_EMA,MACD_Slow_EMA,MACD_SMA,PRICE_MEDIAN,MODE_MAIN,b_Bar);
   return (MACD_value);
  }
//------------------------------------------