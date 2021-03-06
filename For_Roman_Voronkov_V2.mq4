//+------------------------------------------------------------------+
//|                                    Expert_for_Roman_Voronkov.mq4 |
//|                                                            fedan |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+


//| Expert initialization function                                   |
//+------------------------------------------------------------------+

//---

//======ПЕРЕМЕННЫЕ ДЛЯ РЕАЛИЗАЦИИ ЗАЩИТ============================== 
  
   bool Work = true;
   int Main_TF = 60;
   
   input int min_delta_for_open = 0;   //   минимальная разница в пунктах(открытие прошлой сессии - текущая) необходимая для открытия ордера
   
   input int magic_number = 100;    /* для идентификации робота открывшего ордер
                                    (для каждой валютной пары где будет использоваться робот
                                    нужно изменить этот номер на уникальный например:
                                    eur//usd  magic_number = 100, 
                                    gbp//usd  magic_number = 101)
                                    eur//jpy  magic_number = 102)
                                    */

//================ параметры ==============
input bool open_orders_in_session_1 = true;   // разрешение на открытие ордеров в сессии
input bool partial_closing_1 = true;            // разрешение на частичное закрытие ордеров
input double lot_1b = 0.16;                          // лот для открытия 
input double lot_1s = 0.16;  
                   
input bool open_orders_in_session_2 = true;
input bool partial_closing_2 = true;
input double lot_2b = 0.16; 
input double lot_2s = 0.16;  



input bool open_orders_in_session_3 = true;
input bool partial_closing_3 = true;
input double lot_3b = 0.16;
input double lot_3s = 0.16;  


input bool open_orders_in_session_4 = true;
input bool partial_closing_4 = true;
input double lot_4b = 0.16;
input double lot_4s = 0.16;  


input bool open_orders_in_session_5 = true;
input bool partial_closing_5 = true;
input double lot_5b = 0.16;
input double lot_5s = 0.16;  


input bool open_orders_in_session_6 = true;
input bool partial_closing_6 = true;
input double lot_6b = 0.16;
input double lot_6s = 0.16;  


input bool open_orders_in_session_7 = true;
input bool partial_closing_7 = true;
input double lot_7b = 0.16;
input double lot_7s = 0.16;  


input bool open_orders_in_session_8 = true;
input bool partial_closing_8 = true;
input double lot_8b = 0.16;
input double lot_8s = 0.16;  

  
 //===== различные переменные  =============================
 
 double price_open_1 = 0;
 
 
 double TP = 0;
 
 int Total = 0;
 int Ticket = -1;   

 int Type = -1;
 
 bool Ans; 
//===== идентификация сессий =============================  
 int current_hour = 0;                  // текущий час  
 int current_session = 0;               // номер текущей сессии
   
 double previous_session_price = 0;     // цена открытия предыдущей сессии
 double current_session_price = 0;      // цена открытия текущей сессии



//=========== Критерии-флаги для открытия и закрытия=================   
  
 bool Open_B = false;
 bool Open_S = false;
   
 bool Close_B = false;
 bool Close_S = false;
 
 int Tickets_array [8] = {0, 0, 0, 0, 0, 0, 0, 0};                    /// колличество элементов в массиве ( количество сеесий-ордеров -1)
 int magic_numbers [8] = {101, 102, 103, 104, 105, 106, 107, 108};     // массив мэджик чисел для распознования ордеров
   
 bool open_orders_in_sessions[8] ;                // массив  разрешения открытия ордеров в сессии 
 bool partial_closing_orders_in_sessions [8] ;     // массив  разрешения частичного закрытия ордеров в сессии 
 
 double lots_array_b [8]; 
 double lots_array_s [8];
 
void OnInit()
{
         
         lots_array_b [0] = lot_1b;
         lots_array_b [1] = lot_2b;
         lots_array_b [2] = lot_3b;
         lots_array_b [3] = lot_4b;
         lots_array_b [4] = lot_5b;
         lots_array_b [5] = lot_6b;
         lots_array_b [6] = lot_7b;
         lots_array_b [7] = lot_8b;
         
         lots_array_s [0] = lot_1b;
         lots_array_s [1] = lot_2s;
         lots_array_s [2] = lot_3s;
         lots_array_s [3] = lot_4s;
         lots_array_s [4] = lot_5s;
         lots_array_s [5] = lot_6s;
         lots_array_s [6] = lot_7s;
         lots_array_s [7] = lot_8s;
         
         
         partial_closing_orders_in_sessions [0] = partial_closing_1;
         partial_closing_orders_in_sessions [1] = partial_closing_2;
         partial_closing_orders_in_sessions [2] = partial_closing_3;
         partial_closing_orders_in_sessions [3] = partial_closing_4;
         partial_closing_orders_in_sessions [4] = partial_closing_5;
         partial_closing_orders_in_sessions [5] = partial_closing_6;
         partial_closing_orders_in_sessions [6] = partial_closing_7;
         partial_closing_orders_in_sessions [7] = partial_closing_8;
         
         open_orders_in_sessions[0] = open_orders_in_session_1;
         open_orders_in_sessions[1] = open_orders_in_session_2;
         open_orders_in_sessions[2] = open_orders_in_session_3;
         open_orders_in_sessions[3] = open_orders_in_session_4;
         open_orders_in_sessions[4] = open_orders_in_session_5;
         open_orders_in_sessions[5] = open_orders_in_session_6;
         open_orders_in_sessions[6] = open_orders_in_session_7;
         open_orders_in_sessions[7] = open_orders_in_session_8;
   }
///=========интерфейс=====================================  







//========================================================

 void OnTick()
  {
   
   
///=======Обнуляемые и сбрасываемые переменные=====================   

                   
   Ticket = -1;
   Ans = false;
   
   Open_B = false;
   Open_S = false;
   
   Close_B = false;
   Close_S = false;
   
  
//=================================================================
   
//======разделение на торговые сессии==============\
  if (price_open_1 != iOpen(NULL,Main_TF,1))
    {
     price_open_1 = iOpen(NULL,Main_TF,1);
     current_hour = TimeHour(iTime(NULL, Main_TF,0));
      switch (TimeHour(iTime(NULL, Main_TF,0)))
         {
         case 0:
            current_session = 1;
            Print("Сессия 1" + "Час = " + current_hour);
            New_session();
            break;
         case 3:
            current_session = 2;
            Print("Сессия 2" + "Час = " + current_hour);
            New_session();
            break;
         case 6:
            current_session = 3;
            Print("Сессия 3" + "Час = " + current_hour);
            New_session();
            break;
         case 9:
            current_session = 4;
            Print("Сессия 4" + "Час = " + current_hour);
            New_session();
            break;
         case 12: 
            current_session = 5;
            Print("Сессия 5" + "Час = " + current_hour);
            New_session();
            break;
         case 15:
            current_session = 6;
            Print("Сессия 6" + "Час = " + current_hour);
            New_session();
            break;
         case 18:
            current_session = 7;
            Print("Сессия 7" + "Час = " + current_hour);
            New_session();
            break;
         case 21:
            current_session = 8;
            Print("Сессия 8" + "Час = " + current_hour);
            New_session();
            break;
         default:
            break;
           }
     }
   if (partial_closing_orders_in_sessions[current_session-1] == false)
      {
         if (OrderSelect(Tickets_array[current_session-1], SELECT_BY_TICKET)== true)
            {
               if (OrderType()==0)
                  {
                     if (Bid >= previous_session_price) 
                        {
                           Close_B=true;
                           Print(Symbol(),"Закрываем Ордер", OrderTicket(),"по смоделированному ТР");
                           Clossing_open_orders(OrderTicket(),OrderLots(),current_session-1);
                        }
                     
                  }
               
               if (OrderType()==1)
                  {
                     if (Ask <= previous_session_price)
                        {
                           Close_S=true;
                           Print(Symbol(),"Закрываем Ордер", OrderTicket(),"по смоделированному ТР");
                           Clossing_open_orders(OrderTicket(), OrderLots(),current_session-1);
                        }
                  }
            }
      }
 // Print(GetLastError());
   
 //=================================================
   
   
///== После этого разделителя не пишем ничего кроме функций=======  

 return;
  }
//+------------------------------------------------------------------+


////-=========функции=====================
void New_session()
   {
      Print("into New_session");
      Changin_sessions();           // определяем цены открытия сессий (так же поиск при запуске)
      Orders_partial_closing();  // отправляем ордера на частичное закрытие 
      Critery_identification ();  // смотрим критерии на открытие новых
      if (open_orders_in_sessions[current_session-1] == true) Opening_new_orders();   // проверяем разрешение на открытие в данной сессии и открываем если разрешено    
      searching_lost_orders();   // ищем и закрываем ордера по какой либо причине выпавшие из контролирующего массива
   
   }


// ============функция  находит значение цен открытия текущей и предыдущей сессии=========
// =========так же инициализирует эти параметры при запуске============================== 
void Changin_sessions()
   {
      Print("into Changing_session");
      if (previous_session_price!=0 )
         {
            previous_session_price = current_session_price;
            current_session_price = iOpen(NULL,Main_TF,0); 
            Print("сработало первое условие Changin_sessions() цена предыдушей сессии определена как:" + previous_session_price );
         }
       
       else if (previous_session_price == 0 && current_session != 0)
         {
           previous_session_price = iOpen(NULL,Main_TF,(6 + current_hour - current_session * 3));
           current_session_price = iOpen(NULL,Main_TF,0);
           Print("сработало второе условие Changin_sessions() цена предыдушей сессии определена как:" + previous_session_price );
         } 
      else
         Print("Если эта запись видна функция Changin_sessions работает не корректно ");         
   }  
     

//==========функция поиска ордеров=================
void Order_searching()
   {
      Print("ищем ордера закрывшиеся по смоделированным ТР");
      Total=0;                                     // Количество ордеров
      for(int i=0; i<= ArraySize(Tickets_array); i++)          // Цикл перебора ордер
        {
         if (Tickets_array[i] !=0 && OrderSelect(Tickets_array[i], SELECT_BY_TICKET,MODE_TRADES)!= true)
            {
               //Print("ищем ордера закрывшиеся по ТР2");
               if (OrderClosePrice()!= 0) Tickets_array[i] = 0;
            }
        }
   }

//==========функция поиска и закрытия ордеров по частям============

void Orders_partial_closing()
   {     Print("попали в partialclosing");
         for (int i = 0; i <= ArraySize(Tickets_array); i++ )
            {
               if (OrderSelect(Tickets_array[i], SELECT_BY_TICKET) == true && 
                                Tickets_array[i] != 0  )
                  {
                   Print("попали в partialclosing part2");
                   if (OrderType() == 0) 
                     {
                        Close_B = true;
                        Clossing_open_orders(Tickets_array[i], lots_array_b[i]/8, i);
                     }
                   if (OrderType() == 1) 
                     {
                        Close_S = true;
                        Clossing_open_orders(Tickets_array[i], lots_array_s[i]/8, i);
                     }
                  }  
            }
    }

     
 //======= функция проверяет критериии========
 void Critery_identification()
   {
      if (previous_session_price > current_session_price + min_delta_for_open * Point) Open_B = true;
      if (previous_session_price < current_session_price - min_delta_for_open * Point) Open_S = true;
   }
 
//======= функция закрывает ордера ======== 
  void Clossing_open_orders(int Order_Ticket, double part, int num)
   {
     Print ("in the clossing orders function");
     if (partial_closing_orders_in_sessions[num] == false) part = OrderLots();
     if (Close_B == true && OrderSelect(Order_Ticket,SELECT_BY_TICKET)==true)
      {
      while(true)
         {
            Print (Symbol()+ "Попытка закрыть ордер  Buy" );
            RefreshRates();
            Ans =  OrderClose(Order_Ticket, part, Bid, 2, Red);
            if (Ans == true)
               {
                  Print (Symbol()+ "Закрыт ордер Buy" + Order_Ticket);
                  Close_B = false;
                  break;
               }
            if (Fun_Error(GetLastError())!= 0)  break;  
         }
      }
     if (Close_S == true && OrderSelect(Order_Ticket,SELECT_BY_TICKET)==true)
      {
      while(true)
         {
            Print(Symbol() + "Попытка закрыть ордер Sell");
            RefreshRates();
            Ans = OrderClose(Order_Ticket, part, Ask, 2, Red);
            if (Ans == true)
               {
                  Print (Symbol()+ "Закрыт ордер Sell" + Order_Ticket);
                  Close_S = false;
                  break;
               }
            if (Fun_Error(GetLastError())!= 0) break;
         }
      }                                                     
      
                                                                      
     Tickets_array[num] = 0;                                //так как после частичного закрытия  тикет ордера изменился
     for (int j = 0; j<= OrdersTotal(); j++)                // итерируемся по открытым ордерам и ищем остаток от исходного ордера                
      {
         if (OrderSelect(j, SELECT_BY_POS) == true)
            {
               if (OrderMagicNumber() != magic_numbers[num]) continue; 
               Tickets_array[num] = OrderTicket();                          // добавляем его новый тикет в массив на нужное положение 
            }
      }
      return;
   }
 
//======= функция открывает ордера по соответсвующим критериям ======== 
  void Opening_new_orders()
   {  
      TP = 0;
      int magic = magic_numbers[current_session-1];         
      if (Open_B == true)
         {
         while(true)
            {
               Print(Symbol()+ "Попытка открыть ордер  Buy" );
               RefreshRates();
                   Ticket = OrderSend(Symbol(),OP_BUY,lots_array_b[current_session-1],Ask,2,                  //Открытие Buy
                                0,TP,"",
                                magic,0,Green);
               if (Ticket > 0)                                                      
                  {
                     Print (Symbol() + "Открыт ордер Buy " + Ticket);
                     Tickets_array[current_session-1] = Ticket;
                     break;                                                  // Выход из цикла открытия
                  }
               if (Fun_Error(GetLastError())!= 0)
               
               break;                  // Обработка ошибок повторная попытка
            }
         }
        if (Open_S == true)
            {
             while(true)
             {
               Print(Symbol()+ "Попытка открыть ордер  Sell" );
               RefreshRates();
                   Ticket = OrderSend(Symbol(),OP_SELL,lots_array_s[current_session-1],Bid,2,                   //Открытие Buy
                                0,TP,"",
                                magic,0,Blue);
               if (Ticket > 0)
                  {
                     Print(Symbol() + "Отркрыт ордер Sell" + Ticket);
                     Tickets_array[current_session-1] = Ticket;
                     break;
                  }
              if (Fun_Error(GetLastError()) != 0)  
              break;
             }
            }
        
     }
     
   // =======функция поиска ордеров выпавших из  цикла=============
   void searching_lost_orders()
      {  
        // Print("ищем потерянные ордера1");
         for (int l=0; l <= OrdersTotal(); l ++)
            {
               if (OrderSelect(l,SELECT_BY_POS == true))
                  {
                     //Print("ищем потерянные ордера2");
                     if ((OrderMagicNumber() >= magic_number) && (OrderMagicNumber() <= (magic_number +9)))
                        {
                           //Print("ищем потерянные ордера3");
                           for (int j =0; j <= ArraySize(Tickets_array); j++)
                              {
                                 //Print("ищем потерянные ордера4");
                                 if (OrderTicket() == Tickets_array[j]) 
                                    {
                                    return;
                                    }
                                 
                              }
                           Print( Symbol()," Найден потерянный ордер", OrderTicket(), " Закрываем");
                           if (OrderType() ==0) Close_B=true;
                           if (OrderType() ==1 )Close_S=true;
                           Clossing_open_orders(OrderTicket(),OrderLots(),9);
                           return;
                        }
                  }
            }
        return;    
      }
 //================ИНТЕРФЕЙС==========================
 
     
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
            Sleep(1);                           
         return(1);                             
      case 137:Alert("Брокер занят. Пробуем ещё раз..");
         Sleep(3000);                           
         return(1);                             
      case 146:Alert("Подсистема торговли занята. Пробуем ещё..");
         Sleep(500);                            
         return(1);                             
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