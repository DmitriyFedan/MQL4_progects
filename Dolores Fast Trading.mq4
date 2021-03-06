//+------------------------------------------------------------------+
//|                                         Dolores Fast Trading.mq4 |
//|                                                            fedan |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "fedan"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

   


class MAVal
  {

public:
  
public: 

  // MA  по средней цене
   double MMAval(int TF, int period, int bar)   
      {
         return (iMA(NULL, TF, period,0,MODE_SMA,PRICE_MEDIAN,bar));
      }
 
  // MA  по максимальной цене
   double HMAval(int TF, int period, int bar)   
      { 
         return (iMA(NULL, TF, period,0,MODE_SMA,PRICE_HIGH,bar));
      }
  
  // MA  по минимальной цене
  double LMAval(int TF, int period, int bar)   
      {
         return (iMA(NULL, TF, period,0,MODE_SMA,PRICE_LOW,bar));
      }
                    
  };
  
  class CriteryIdent
  {
      public:
         MAVal MA;
         
         bool FactUp;
         bool FactDown;
         /*double hMA5 = MA.HMAval(5,period_MA_fast,0);
         double lMA5 = MA.LMAval(5,period_MA_fast,0);
         double mMA5 = MA.MMAval(5,period_MA_slow,0);
         */ 
      public:
         
//****** Критерий восходящего тренда на 5 минутном графике (вариант с 3 МА)
         bool Up5MTrend() // int perFastMa, int perSlowMa
            {
               return ( (Ask > MA.HMAval(5, period_MA_fast,0))); //&& (MA.HMAval(5,period_MA_fast,0) > MA.MMAval(5,period_MA_slow,0 )));  
                          
            }
//****** Критерий нисходящего тренда на 5 минутном графике (вариант с 3 МА)
         bool Down5MTrend()
            {
               return ( (Bid < MA.LMAval(5,period_MA_fast,0)));// && (MA.LMAval(5,period_MA_fast,0) < MA.MMAval(5,period_MA_slow,0)));
                        
            }
            
//*****  критерий разрешающий открытие новых баров  (по колличеству разрешенных)   
         bool OpenNewOrders()
            {
                for (int i = 0; i <= OrdersTotal(); i ++ )
                  {
                   if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == true)
                     {
                        if (OrderMagicNumber() != magic_number) continue;
                        orders_count += 1.0;
                     }
                  }
                return (orders_count < max_orders_count);         
            }
            
//*****   критерий на закрытие открытых покупок (по пробитию )
         bool CloseOpenBuyLowMA()
            {
               return (Bid < MA.LMAval(5,period_MA_fast,0));
            }

//*****   критерий на закрытие открытых продаж (по пробитию )
         bool CloseOpenSellHighMA()
            {
               return (Ask> MA.HMAval(5,period_MA_fast,0));
            }
          
          
//******  критерий  защищающий от открытия ордеров до формирования  критерия нового тренда  Up or Down 5Trend
          void FactUpDownChanger()
            {
               if (FactUp == false && (Ask < MA.MMAval(5,period_MA_fast,0))) FactUp = true;
               if (FactDown == false && (Bid > MA.MMAval(5,period_MA_fast,0))) FactDown = true;  
            }  
            
//*****   метод возвращает показатель силы тренда ( по разнице между значениями MA )
         double TrendPower (int TF, int period, int count_bars)
            {
               double inner_counter = 0;
               for (int i = 1; i <= count_bars; i ++)
                  {
                     inner_counter += (MathAbs(MA.MMAval(TF, period,i) - MA.MMAval(TF,period,i+1))/ Point );
                  }
               return (inner_counter / count_bars); 
            }     
            

            
            
  };

//+------------------------------------------------------------------+
//|                                                      dolores.mq4 |
//|                                                            fedan |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "fedan"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

///========переменные================================
input int magic_number = 1000;
input double delta_ma_price = 2000;
double lot = 0.1;
double profit_value = 300;

int main_tf = 5;   // главный период  1 минута 

//============
bool work = true;

bool trend_up = false;        // тренд вверх
bool trend_down = false;      // тренд вниз 
bool low_delta = false;         
bool not_reversal = false;     
bool Open_B = false;
bool Open_S = false;
bool Close_B = false;
bool Close_S = false;

double orders_count = 0;                  // количество открытых ордеров  для счетчика
int max_orders_count = 1;             // максимально допустимое кол-во открытых ордеров
    
bool Open_New = false;               // временный критерий разрешает или запрещает открытие нового ордера

bool new_bar_m30 = false;             //  критерий нового бара на м30
double price_1bar_m30 = 0;             // цена первого бара на м30 
double price_1bar_main_tf = 0;         // цена первого бара на main_tf
       
//======= объявление индикаторов и связанных с ними переменными==========
double MA_1;
double MA_2;
double MA_3;
double MA_4;

//======параметры индикаторов=========
input int period_MA_1 = 10;
input int period_MA_2 = 10;
input int period_MA_3 = 10;
input int period_MA_4 = 10;


input int period_MA_fast =45;
input int period_MA_slow =90;


//=================================
int position = -1;
int tickets_array[3] = {0, 0, 0};    // массив для записи тикетов   в массиве 3 элемента



//=====преременные для реализации интерфейся===========
string Lable_names [6] = {"lable_1","lable_2","lable_3",                          
                               "lable_1_ans", "lable_2_ans", "lable_3_ans"};           // имена надписей 

string Lable_text [6] = {"DeltaMed 3 = ", "DeltaMed 5 = ", "DeltaMed 8 = ",                         
                                 "NONE", "NONE", "NONE"};                            // текст надписей
int x_distance = 1200;
int y_distance = 30;
     
//==================================================
//========= объявление экземпляров классов========== 

CriteryIdent Critery;



int OnInit()
  {
//---
   LableCreator ();           // создание лейблов и интерфейса происходит один раз при запуске 
//---
   return(INIT_SUCCEEDED);
  }

  
  
  
  
  
  
  
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void OnTick()
  {
  
   //Print( "MAHVAL= " + DoubleToString(MA.MAHval(60,20,0)));
   //Print( "MALVAL= " + DoubleToString(MA.MALval(60,20,0)));
//====обнуляемые и сбрасываемые переменные=========
     ///  каждый тик обнуляются 
   
   trend_up = false;
   trend_down = false;
   low_delta = false;
   not_reversal = false;
   Open_B = false;
   Open_S = false;
   Close_B = false;
   Close_S = false;
   Open_New = false;
   //position = -1;
   orders_count = 0.0;
   
  /*
       MA_1 = iMA(NULL, 1, period_MA_1, 0, MODE_SMA, PRICE_MEDIAN, 0);     // 1 min 
       MA_2 = iMA(NULL, 5, period_MA_2, 0, MODE_SMA,  PRICE_MEDIAN, 0);      // 5 min
       MA_3 = iMA(NULL, 15, period_MA_3, 0, MODE_SMA,  PRICE_MEDIAN, 0);      // 15 min
       MA_4 = iMA(NULL, 30, period_MA_4, 0, MODE_SMA,  PRICE_MEDIAN, 0);      // 30 min    
  */   
       
 // ========= вызов индикаторов =================================     
     
     
  /*
     MA_1 = iMA(NULL, main_tf, period_MA_fast, 0, MODE_SMA,  PRICE_LOW, 0);  // по  минимальным ценам баров 
     MA_2 = iMA(NULL, main_tf, period_MA_fast, 0, MODE_SMA, PRICE_HIGH, 0);  // по максимальным ценам баров
     MA_3 = iMA(NULL,main_tf, period_MA_slow, 0, MODE_SMA, PRICE_MEDIAN,0);  // по средним ценам баров
  */  

      
      
// =========== рабочие функции ================
 
      //===== новые добавления =====
      
      
      
      
      //=========================
      
      //CriteryIdentificationMA();
      //OrderSearching();              ///  ищем открытые ордера и определяем свободные позиции 
      //DeltaMACounter();              /// оцениваем  разницу между значениями MA  
      CriteryIdentification();         /// определяем критерии на открытие или закрытие 
      OpenNewOrders();                 /// открываем новые ордера 
      CloseAllOpenOrders();
      NewBar(main_tf);
   
  }
//+------------------------------------------------------------------+


/// ============ФУНКЦИИ==============
//===================================



// ===функции для определения критериев на открытие и закрытие =========



///=============функция слежения за ордерами =================

// проверяем если количество открытых ордеров по данному инструменту  
//меньше максимально-разрешенного то даем разрешение на открытие новых 

   
   
   
   
   
//============функция вычисления средненго изменения МА ==============
/*
double DeltaMACounter()
   {
      if (iOpen(NULL,main_tf,1) != price_1bar_main_tf )
         {
            price_1bar_main_tf = iOpen(NULL,main_tf,1);
            double deltaMA = 0;
            double counter = 0;
            int count = 4;                                     //  количество баров для нахождения среднего изменения МА
               for (int i = 0; i < count; i++)
                  {           
                     counter += (iMA(NULL,main_tf,3,0,MODE_SMA,PRICE_MEDIAN,i) -
                                  iMA(NULL,main_tf,3,0,MODE_SMA,PRICE_MEDIAN,i+1));     // определяем разницу 
                  }
            deltaMA = counter/count; 
            Print("DeltaMA = ", deltaMA);       // выводим среднее изменение значения МА за count  баров 
                                    
         } 
      return (deltaMA);            
   }  
 */  
// ===функции для определения критериев на открытие и закрытие =========


 



///  ==== ====отслеживает  открылся ли новый бар  в указанном периоде  ======================
bool NewBar(int Per)                              
   {
      if (iOpen(NULL, Per, 1) != price_1bar_m30)
         {
            price_1bar_m30 = iOpen(NULL, Per, 1); 
            
            
            /// ====== манипуляйии с интерфейсом========
            Print( DoubleToString(Critery.TrendPower(5,25,3),1));
            
            
            Lable_text[3] = DoubleToString(Critery.TrendPower(5,25,3),1);     // вносим значения силы тренда в массив(для вывода в интерфейс)
            Lable_text[4] = DoubleToString(Critery.TrendPower(5,25,4),1);
            Lable_text[5] = DoubleToString(Critery.TrendPower(5,25,5),1);
            LableValueChanger();            // обновляем интерфейс каждый новый бар;
           
           
           
            //Print (CrI.Down5MTrend());
            //Print (CrI.Up5MTrend());
            //Print (iFractals(NULL,main_tf,MODE_LOWER,3));
            //Print (iFractals(NULL,main_tf,MODE_UPPER,3));
           
            return (true);
         }
      return false;
   }



//======= определение критериев==========================

void CriteryIdentification()
  {
   
   Critery.FactUpDownChanger(); //  проверяем и обновляем
   // //////////Trend critery
   
   if (Critery.OpenNewOrders() == true)  //  если разрешено открывать новые ордера
      {  
        
        if (Critery.Up5MTrend()  && 
             Critery.FactUp &&
             Critery.TrendPower(main_tf,15,4) > 25)
            {
               Open_B = true;
               Open_S = false;
            }
        if (Critery.Down5MTrend() && 
            Critery.FactDown &&
            Critery.TrendPower(main_tf,15,4 )> 25)
            {
               Open_S = true;
               Open_B = false;
            }
       }
     
     /*
     if ( MAValue(1,period_MA_1,1) > MAValue(1,period_MA_1,2) && MAValue(1,period_MA_1,1) > MAValue(1,period_MA_1,3) &&
          MAValue(5,period_MA_1,1) > MAValue(5,period_MA_1,2) && MAValue(5,period_MA_1,1) > MAValue(5,period_MA_1,3))
     
         {
            trend_up = true;
            trend_down = false;
            Close_S = true; 
         }
      if ( MAValue(1,period_MA_1,1) < MAValue(1,period_MA_1,2) && MAValue(1,period_MA_1,1) < MAValue(1,period_MA_1,3) &&
          MAValue(5,period_MA_1,1) < MAValue(5,period_MA_1,2) && MAValue(5,period_MA_1,1) < MAValue(5,period_MA_1,3))
         {
            trend_up = false;
            trend_down = true;
            Close_B = true; 
         }
     
 
     
     
     
     if (trend_up == true && MAValue(main_tf,1,0)> MAValue(main_tf,1,1) &&  MAValue(main_tf,1,1)> MAValue(main_tf,1,2))
         {
          not_reversal = true;
         }
     if (trend_down == true && MAValue(main_tf,1,0)< MAValue(main_tf,1,1) &&  MAValue(main_tf,1,1)< MAValue(main_tf,1,2))
         {
         not_reversal = true;
         }    
     
     if (NewBar(main_tf) == true)
         {
          
            if (trend_up == true && Open_New == true ) Open_B = true;  //&& low_delta == true && not_reversal == true
            //if (trend_down == true && Open_New == true ) Open_S = true;  // && low_delta == true && not_reversal == true
         }
    
 */
 
 
 ///// ========= criteria  for closing orders //////      
   
   if (Critery.CloseOpenBuyLowMA()  || Critery.TrendPower(main_tf,15,4 )< 25) Close_B = true;
   if (Critery.CloseOpenSellHighMA() || Critery.TrendPower(main_tf,15,4 )< 25)  Close_S = true;
   
   
   
   
   for (int i = 0; i <= OrdersTotal(); i ++ )
         {
          if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) == true)
               {
                  if (OrderMagicNumber() != magic_number) continue;
                  if (OrderProfit() >=  profit_value)
                     {
                        Close_B = true;
                        Close_S = true;
                     }
                  
               }
         }
     
     
     
 /*
   if (Bid < MA_1 ) 
         {
            Close_B = true;
         }
    if (Ask > MA_2 ) 
         {
            Close_S = true;
         }
 */
     /*
    for (int i = 0; i < ArraySize(tickets_array); i++)    /// определяем  свободную позицию для записи тикета
         {
            if (tickets_array[i] == 0 ) 
            {
               position = i;
              // Print("position =" + position);
               break;
            }
         }
       
    
      if ( Bid > MA_2 && MA_1 > MA_3)
         {
            trend_up = true;
            Print("trend up");
         }
      if (Ask < MA_1 && MA_2 < MA_3) 
         {
            trend_down = true;
            Print("trend down");
         }
      if (trend_up == true && Open_New == true ) Open_B = true;   // && position >= 0
      if (trend_down == true && Open_New == true) Open_S = true;    // && position >=0
      */      
   }
  



//================ функция открытия ордеров=======================
void OpenNewOrders()
   {
      int attempt = 0;
      int magic = magic_number;         
      int TP = 0;
      int Ticket = 0;
      double real_lot = lot - (orders_count/100);
      if (Open_B == true)
         {
            while(attempt <= 5)
               {
                  Print(Symbol()+ "Попытка открыть ордер  Buy" );
                  RefreshRates();
                      Ticket = OrderSend(Symbol(), OP_BUY, real_lot, Ask, 3, 0, 0, "", magic_number, 0, Green);
                  if (Ticket > 0)                                                      
                     {
                        Critery.FactUp = false;
                        //Print (Symbol() + "Открыт ордер Buy " + Ticket);                       
                        tickets_array[0] = Ticket;
                        new_bar_m30 = false;                                    //  если  ордер открылся сбрасываем критерий новый бар 
                        break;                                                  // Выход из цикла открытия
                     }
                  if (Fun_Error(GetLastError())!= 0)
                  attempt +=1;
                  continue;                  // Обработка ошибок повторная попытка   дорабоать функцию обработки ошибок 
               }
            }
           if (Open_S == true)
               {
                while(attempt <=5)
                {
                  Print(Symbol()+ "Попытка открыть ордер  Sell" );
                  RefreshRates();
                      Ticket = OrderSend(Symbol(), OP_SELL, real_lot, Bid, 3,0,0, "", magic_number, 0, Blue);
                  if (Ticket > 0)
                     {
                        Critery.FactDown = false;
                        //Print(Symbol() + "Отркрыт ордер Sell" + Ticket);
                        tickets_array[0] = Ticket;
                        new_bar_m30 = false;                                    //  если  ордер открылся сбрасываем критерий новый бар 
                        break;
                     }
                 if (Fun_Error(GetLastError()) != 0)  
                 attempt+=1;
                 continue;
                }
               } 
         }   
     
//========Функция закрытия ордеров ==================================
//========1 вариант полное закрытие всех ордеров  по magic number====

void CloseAllOpenOrders()
   {
      if (Close_B == true)
         {
            for (int j = 0; j <= OrdersTotal(); j ++)
               {
                  if (OrderSelect(j, SELECT_BY_POS, MODE_TRADES) == true)
                     {
                        if (OrderMagicNumber() != magic_number) continue;
                        if (OrderType() == 0 )
                           {
                              if (OrderClose(OrderTicket(),OrderLots(),Bid, 5,Red) == true)
                                 {
                                    Print("BUY Order was CLOSED", OrderTicket());
                                 }
                              
                           }
                        }
                 }
           }
         if (Close_S == true)
            {
                for (int j = 0; j <= OrdersTotal(); j ++)
               {
                  if (OrderSelect(j, SELECT_BY_POS, MODE_TRADES) == true)
                     {
                        if (OrderMagicNumber() != magic_number) continue;
                        if (OrderType() == 1 )
                           {
                              if (OrderClose(OrderTicket(),OrderLots(),Ask, 5,Red) == true)
                                 {
                                    Print("SELL Order was CLOSED", OrderTicket());
                                 }
                              
                           }
                        }
                 }
           }
          return;
         }
     
  
//========== полезные функции =================================
// ======== вычисление различных показателей ===== =============


// ======= сила тренда в пунктах =============



//// ====== функция возвращает значение MA   на таймфрейме ТФ  , указанного периода 
double MAValue (int TF, int period, int bar)
   {
      double MAValue = iMA(NULL, TF, period, 0, MODE_SMA,PRICE_MEDIAN, bar);
      return MAValue;
   }







///=========  работа с интерфейсом ========================


// ======== Функция создает  необходимый интерфейс в мометн запуска программы==========
void LableCreator ()
   {
      x_distance = 1200;
      int inner_counter = 0;
      /// нужно прописать проверку наличия  лэйблов с такими названиями 
      while(inner_counter <= 5)
      {
         ObjectCreate(Lable_names[inner_counter],OBJ_LABEL,0,0,0);
         ObjectSetText(Lable_names[inner_counter],Lable_text[inner_counter],15,"Arial",Blue);
         ObjectSet(Lable_names[inner_counter],OBJPROP_CORNER,0);
         ObjectSet(Lable_names[inner_counter],OBJPROP_XDISTANCE,x_distance); 
         ObjectSet(Lable_names[inner_counter],OBJPROP_YDISTANCE,y_distance);
         y_distance += 30;
         inner_counter +=1;
         if(inner_counter ==3 )
            {
               y_distance = 30;
               x_distance = 1400;
            }     
      }  
      return;   
    }
void LableValueChanger()
   {
       int inner_counter = 3;
       while (inner_counter <6)
         {
            ObjectSetText(Lable_names[inner_counter],Lable_text[inner_counter],15,"Arial",Blue);
            inner_counter+=1;
         }
       return;
   }







//======== Функция обрабатывает некоторые ошибки =====================    
 int Fun_Error(int Error)                        
  {
   switch(Error)
     {                                          // Преодолимые ошибки            
      case  4: Alert("Торговый сервер занят. Пробуем ещё раз..");
         Sleep(3000);                           
         return(1);                             
      case 135:Alert("Цена изменилась. Пробуем ещё раз..");
         RefreshRates();                        
         return(1);                             
      case 136:Alert("Нет цен. Ждём новый тик..");
         while(RefreshRates()==false)           
            Sleep(30);                           
         return(1);                             
      case 137:Alert("Брокер занят. Пробуем ещё раз..");
         Sleep(3000);                           
         return(1);                             
      case 146:Alert("Подсистема торговли занята. Пробуем ещё..");
         Sleep(500);                            
         return(1);                             
      case 134:Alert("Недостаточно денег для совершения операции.");
         return(0);                             // Выход из функции
      default: Alert("Возникла ошибка ",Error); // Другие варианты   
         return(0);                             // Выход из функции
     }
     
  }